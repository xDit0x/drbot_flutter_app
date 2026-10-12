import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/domain/entities/medications/prescription.dart';
import 'package:flutter_learning/domain/entities/medications/medication.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrescriptionPage extends StatelessWidget
{
  const PrescriptionPage({super.key});

  String get _monthKey
  {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,  '0')}';
  }


  Future<void> _dispense
  (
    BuildContext context
    , {
      required String patientUid,
      required Prescription prescription,
    } 
  ) async
  {
    final confirmed = await showDialog<bool>
    (
      context: context, 
      builder: (dialogContext) => AlertDialog
      (
        title: const Text('Dispensar medicamento'),
        content: const Text('¿Quieres registrar la dispensación de este medicamento para este mes?'),
        actions: 
        [
          TextButton
          (
            onPressed: () => Navigator.pop(dialogContext, false), 
            child: const Text('Cancelar'),
          ),
          FilledButton
          (
            onPressed: () => Navigator.pop(dialogContext, true), 
            child: const Text('Confirmar')
          )
        ],
      )
    );

    if(confirmed != true || !context.mounted) { return; }

    final prescriptionRef = FirebaseFirestore.instance
        .collection('Prescriptions')
        .doc(prescription.medicationId)
        .collection('Users')
        .doc(patientUid)
        .collection('PatientPrescriptions')
        .doc(prescription.id);
    final dispensationRef = prescriptionRef.collection('Dispensations').doc(_monthKey);
    try 
    {
      await FirebaseFirestore.instance.runTransaction((transaction) async
      {
        final existing = await transaction.get(dispensationRef);

        if(existing.exists)
        {
          throw StateError('Este medicamento ya se dispensó este mes.');
        }

        transaction.set(dispensationRef, 
        {
          'patientUid': patientUid,
          'monthKey': _monthKey,
          'dispensedAt': FieldValue.serverTimestamp()
        });
      });

      if(context.mounted)
      {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispensa registrada')));
        try
        {
          await _generatePrescriptionPdf(
            patientUid: patientUid,
            prescription: prescription,
            dispensedMonth: _monthKey,
          );
        }
        catch (e)
        {
          if(context.mounted)
          {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('La dispensación se guardó, pero no se pudo generar el documento: $e')),
            );
          }
        }
      }
    } 
    catch (e) 
    {
      if(context.mounted)
      {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo registrar la dispensación')));
      }
    }
  }

  Future<void> _generatePrescriptionPdf({
    required String patientUid,
    required Prescription prescription,
    required String dispensedMonth,
  }) async {
    final document = pw.Document();
    final startDate = prescription.startDate.trim();
    final endDate = prescription.endDate.trim();
    var doctorName = 'No disponible';
    if (prescription.doctorId.isNotEmpty) {
      final doctorSnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(prescription.doctorId)
          .get();
      final fetchedDoctorName =
          (doctorSnapshot.data()?['name'] ?? '').toString().trim();
      if (fetchedDoctorName.isNotEmpty) {
        doctorName = fetchedDoctorName;
      }
    }
    final generatedAt = DateTime.now();
    final generatedAtText =
        '${generatedAt.day}/${generatedAt.month}/${generatedAt.year} '
        '${generatedAt.hour.toString().padLeft(2, '0')}:'
        '${generatedAt.minute.toString().padLeft(2, '0')}';

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            'Receta virtual y justificante de dispensación',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Generado: $generatedAtText'),
          pw.Text('Mes de dispensación: $dispensedMonth'),
          pw.SizedBox(height: 20),
          pw.Text('Datos del paciente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Expediente del paciente: $patientUid'),
          pw.SizedBox(height: 16),
          pw.Text('Medicamento prescrito', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Medicamento: ${prescription.medicationName}'),
          if (prescription.cimaNregistro.isNotEmpty)
            pw.Text('Registro CIMA: ${prescription.cimaNregistro}'),
          if (prescription.activeIngredients.isNotEmpty)
            pw.Text('Principio activo: ${prescription.activeIngredients}'),
          pw.Text('Dosis: ${prescription.dose}'),
          pw.Text('Frecuencia: ${prescription.frequency}'),
          pw.Text('Vía: ${prescription.route.isEmpty ? 'No indicada' : prescription.route}'),
          pw.Text('Inicio de la toma: ${startDate.isEmpty ? 'Crónico' : startDate}'),
          pw.Text('Fin de la toma: ${endDate.isEmpty ? 'Crónico' : endDate}'),
          if (prescription.instructions.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('Instrucciones: ${prescription.instructions}'),
          ],
          pw.SizedBox(height: 16),
          pw.Text('M\u00E9dico prescriptor: $doctorName'),
          pw.Text('Identificador de la cita: ${prescription.appointmentId}'),
        ],
      ),
    );
    await Printing.layoutPdf(
      name: 'receta_${prescription.medicationId}_$dispensedMonth.pdf',
      onLayout: (format) async => document.save(),
    );
  }

  @override
  Widget build(BuildContext context)
  {
    final patientUid = FirebaseAuth.instance.currentUser?.uid;

    if(patientUid == null)
    {
      return const Center(child: Text('Inicia sesión para consultar tus medicamentos.'));
    }

    final prescriptionsQuery = FirebaseFirestore.instance
        .collectionGroup('PatientPrescriptions')
        .where('patientUid', isEqualTo: patientUid);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>
    (
      stream: prescriptionsQuery.snapshots(), 
      builder: (context, snapshot)
      {
        if(snapshot.hasError)
        {
          return Center(
            child: Text('No se pudieron cargar tus prescripciones: ${snapshot.error}'),
          );
        }

        if(!snapshot.hasData)
        {
          return const Center(child: CircularProgressIndicator());
        }

        final prescriptions = snapshot.data!.docs.map((doc) => Prescription.fromMap(doc.id, doc.data())).where((prescription) => prescription.status == 'active').toList();

        final medications = Medication.groupPrescriptions(prescriptions);

        if(medications.isEmpty)
        {
          return const Center(child: Text('No tienes medicamentos prescriptos actualmente'));
        }

        return ListView
        (
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: 
          [
            Text('Medicación prescrita', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 12),
            for(final medication in medications)
              _MedicationCard
              (
                medication: medication,
                prescriptions: prescriptions.where((item) => item.medicationId == medication.id).toList(),
                patientUid: patientUid,
                monthKey: _monthKey,
                onDispense: (prescription) => _dispense(
                  context,
                  patientUid: patientUid,
                  prescription: prescription,
                )
              )
          ],
        );
      }
    );
  }
}

class _MedicationCard extends StatelessWidget
{
  const _MedicationCard(
    {
      required this.medication,
      required this.prescriptions,
      required this.patientUid,
      required this.monthKey,
      required this.onDispense
    });

    final Medication medication;
    final List<Prescription> prescriptions;
    final String patientUid;
    final String monthKey;
    final ValueChanged<Prescription> onDispense;

    @override
    Widget build(BuildContext context) 
    {
      return Card
      (
        margin: const EdgeInsets.only(bottom: 12),
        child: ExpansionTile
        (
          title: Text(medication.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: medication.activeIngredients.isEmpty ? null : Text('Principio activo: ${medication.activeIngredients}'),
          children: 
          [
            for(final prescription in prescriptions)
            _PrescriptionDetails
            (
              prescription: prescription,
              patientUid: patientUid,
              monthKey: monthKey,
              onDispense: () => onDispense(prescription)
            )
          ],
        ),
      );
    }

}

class _PrescriptionDetails extends StatelessWidget
{
  const _PrescriptionDetails(
  {
    required this.prescription,
    required this.patientUid,
    required this.monthKey,
    required this.onDispense
  });

  final Prescription prescription;
  final String patientUid;
  final String monthKey;
  final VoidCallback onDispense;

  @override
  Widget build(BuildContext context)
  {
    final dispensationsRef = FirebaseFirestore.instance
    .collection('Prescriptions').doc(prescription.medicationId)
    .collection('Users').doc(patientUid)
    .collection('PatientPrescriptions').doc(prescription.id)
    .collection('Dispensations');

    return Padding
    (
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column
      (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: 
        [
          if(prescription.dose.isNotEmpty)
            Text('Dosis: ${prescription.dose}'),
          if(prescription.frequency.isNotEmpty)
            Text('Frecuencia: ${prescription.frequency}'),
          if(prescription.route.isNotEmpty)
            Text('Vía: ${prescription.route}'),
          if(prescription.startDate.isNotEmpty || prescription.endDate.isNotEmpty)
            Text
            (
              'Tratamiento: '
              '${prescription.startDate.isEmpty ? '-' : prescription.startDate}'
              ' - '
              '${prescription.endDate.isEmpty ? 'crónico' : prescription.endDate}'
            ),
          if(prescription.instructions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Instrucciones: ${prescription.instructions}')
          ],
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: dispensationsRef.snapshots(),
            builder: (context, snapshot)
            {
              if (snapshot.hasError)
              {
                return const Text('No se pudo consultar la dispensación');
              }

              if (!snapshot.hasData)
              {
                return const LinearProgressIndicator();
              }

              if (snapshot.data!.docs.any((doc) => doc.id == monthKey))
              {
                return Chip(
                  avatar: const Icon(Icons.check_circle, color: Colors.green),
                  label: Text('Dispensado este mes ($monthKey)'),
                );
              }

              return Align
              (
                alignment: Alignment.centerLeft,
                child: FilledButton.icon
                (
                  onPressed: onDispense, 
                  icon: const Icon(Icons.medication),
                  label: const Text('Registrar dispensación del mes')
                ),
              );
            }
          )
        ],
      ),
    );
  }
}
