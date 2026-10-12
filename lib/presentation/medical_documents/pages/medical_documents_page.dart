import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MedicalDocumentsPage extends StatelessWidget
{
    const MedicalDocumentsPage({super.key});

    Future<List<Map<String, dynamic>>> _loadReports() async
    {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if(uid == null) { return[]; }
      
      final result = await FirebaseFirestore.instance.collection('Users').doc(uid).collection('appointments').where('status', isEqualTo: 'completed').get();

      final records = result.docs
          .map((doc) => {...doc.data(), 'appointmentId': doc.id, 'patientUid': uid})
          .where((data) => (data['medicalReport'] ?? '').toString().trim().isNotEmpty)
          .toList();

      records.sort((a, b) => _dateOf(b['date']).compareTo(_dateOf(a['date'])));
      return records;
    }

    static DateTime _dateOf(dynamic value)
    {
      if (value is Timestamp) { return value.toDate(); }
      if (value is DateTime) { return value; }
      if (value is String) { return DateTime.tryParse(value) ?? DateTime(0);}
      return DateTime(0);
    }

    static String _formatDate(dynamic value)
    {
      final date = _dateOf(value);
      if (date.year == 0) { return 'Fecha no disponible';}
      return '${date.day}/${date.month}/${date.year}';
    }

    Future<void> _downloadReport(Map<String, dynamic> record) async
    {
      final document = pw.Document();
      final center = record['medicalCenter'] is Map
          ? Map<String, dynamic>.from(record['medicalCenter'] as Map)
          : <String, dynamic>{};
      final patientUid = (record['patientUid'] ?? '').toString();
      final appointmentId = (record['appointmentId'] ?? '').toString();
      final appointmentDate = _dateOf(record['date']);
      final appointmentTime = appointmentDate.year == 0
          ? 'No disponible'
          : '${appointmentDate.hour.toString().padLeft(2, '0')}:${appointmentDate.minute.toString().padLeft(2, '0')}';
      final location = [
        center['municipality'],
        center['province'],
        center['region'],
      ]
          .where((value) => value != null && value.toString().trim().isNotEmpty)
          .join(', ');
      final prescriptionDocs = patientUid.isEmpty || appointmentId.isEmpty
          ? <QueryDocumentSnapshot<Map<String, dynamic>>>[]
          : (await FirebaseFirestore.instance
                  .collectionGroup('PatientPrescriptions')
                  .where('patientUid', isEqualTo: patientUid)
                  .where('appointmentId', isEqualTo: appointmentId)
                  .get())
              .docs;

      final prescriptionWidgets = <pw.Widget>[];
      for (final prescriptionDoc in prescriptionDocs) {
        final prescription = prescriptionDoc.data();
        final startDate = (prescription['startDate'] ?? '').toString().trim();
        final endDate = (prescription['endDate'] ?? '').toString().trim();
        final status = (prescription['status'] ?? '').toString();
        final statusLabel = status == 'active'
            ? 'Activo'
            : status == 'discontinued'
                ? 'Retirado'
                : status.isEmpty
                    ? 'No indicado'
                    : status;

        prescriptionWidgets.add(
          pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  (prescription['medicationName'] ?? 'Medicamento').toString(),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('ID del medicamento: ${prescription['medicationId'] ?? 'No disponible'}'),
                pw.Text('Dosis: ${prescription['dose'] ?? 'No indicada'}'),
                pw.Text('Frecuencia: ${prescription['frequency'] ?? 'No indicada'}'),
                pw.Text('Vía: ${prescription['route'] ?? 'No indicada'}'),
                pw.Text('Inicio de la toma: ${startDate.isEmpty ? 'Crónico' : startDate}'),
                pw.Text('Fin de la toma: ${endDate.isEmpty ? 'Crónico' : endDate}'),
                pw.Text('Estado: $statusLabel'),
              ],
            ),
          ),
        );
      }

      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text('Informe de atención de la cita'),
            ),
            pw.Text('Fecha de la cita: ${_formatDate(record['date'])}'),
            pw.Text('Hora de la cita: $appointmentTime'),
            pw.Text('Identificador de la cita: $appointmentId'),
            pw.Text('Expediente del paciente: $patientUid'),
            pw.SizedBox(height: 18),
            pw.Text(
              'Datos de la cita',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Médico: ${record['doctorName'] ?? 'No indicado'}'),
            pw.Text('Especialidad: ${record['specialty'] ?? 'No indicada'}'),
            pw.Text('Centro: ${center['name'] ?? 'No indicado'}'),
            pw.Text('Ubicación: ${location.isEmpty ? 'No indicada' : location}'),
            pw.SizedBox(height: 18),
            pw.Text(
              'Diagnóstico principal',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.SizedBox(height: 6),
            pw.Text((record['principalDisease'] ?? 'No indicado').toString()),
            pw.SizedBox(height: 12),
            pw.Text(
              'Resumen e indicaciones',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.SizedBox(height: 6),
            pw.Text((record['medicalReport'] ?? 'No indicado').toString()),
            pw.SizedBox(height: 18),
            pw.Text(
              'Prescripciones de la cita',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.SizedBox(height: 6),
            if (prescriptionWidgets.isEmpty)
              pw.Text('No hay prescripciones guardadas para esta cita.'),
            ...prescriptionWidgets,
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => document.save());
    }

    @override
    Widget build(BuildContext context) 
    {
      return FutureBuilder<List<Map<String, dynamic>>>
      (
        future: _loadReports(), 
        builder: (context, snapshot)
        {
          if (snapshot.connectionState == ConnectionState.waiting) 
          {
              return const CircularProgressIndicator();
          }
          if (snapshot.hasError) 
          {
              return Center(child: Text('No se ha podido cargar el historial clínico'));
          }

          final reports = snapshot.data ?? [];

          if(reports.isEmpty)
          {
            return const Center(child: Text('Todavía no hay documentos del historial clínico'));
          }
        
          return ListView
          (
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: 
            [
              const Text('Documentos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              for(final report in reports)
                Card
                (
                  child: ListTile
                  (
                    leading: const Icon(Icons.description_outlined),
                    title: Text(report['principalDisease'] ?? 'Informe médico'),
                    subtitle: Text('Cita del ${_formatDate(report['date'])}'),
                    trailing: IconButton
                    (
                      tooltip: 'Descargar PDF', 
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () async
                      {
                        try {
                          await _downloadReport(report);
                        } 
                        catch (_) 
                        {
                          if(!context.mounted) {return; }
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo generar el PDF')));
                        }
                      },
                    ),
                  ),
                )
            ],
          );
      }
    );
  }
}
