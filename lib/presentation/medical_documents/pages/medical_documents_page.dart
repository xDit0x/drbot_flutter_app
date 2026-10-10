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

      final records = result.docs .map((doc) => doc.data()).where((data) => (data['medicalReport'] ?? '').toString().trim().isNotEmpty).toList();

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

      document.addPage
      (
        pw.MultiPage
        (
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header
            (
              level: 0,
              child: pw.Text('Informe de atención'),
            ),
            pw.Text('Fecha: ${_formatDate(record['date'])}'),
            pw.SizedBox(height: 8),
            pw.Text('Médico: ${record['doctorName'] ?? 'No indicado'}'),
            pw.SizedBox(height: 8),
            pw.Text('Diagnóstico principal: ${record['principalDisease'] ?? 'No indicado'}'),
            pw.SizedBox(height: 20),
            pw.Text('Resumen e indicaciones', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
            pw.SizedBox(height: 8),
            pw.Text(record['medicalReport'].toString()),
          ],
        )
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
            return const Center(child: Text('Todavía no hay enfermedades registradas en citas cerradas'));
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