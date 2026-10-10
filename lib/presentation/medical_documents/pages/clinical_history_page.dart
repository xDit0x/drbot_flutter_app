import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClinicalHistoryPage extends StatelessWidget
{
  const ClinicalHistoryPage({super.key});

  Future<List<Map<String, dynamic>>> _loadHistory() async
  {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if(uid == null) { return[]; }
    
    final result = await FirebaseFirestore.instance.collection('Users').doc(uid).collection('appointments').where('status', isEqualTo: 'completed').get();

    final records = result.docs .map((doc) => doc.data()).where((data) => (data['principalDisease'] ?? '').toString().trim().isNotEmpty).toList();
  

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

  @override
  Widget build(BuildContext)
  {
    return FutureBuilder<List<Map<String, dynamic>>>(future: _loadHistory(), builder: (context, snapshot)
    {
      if (snapshot.connectionState == ConnectionState.waiting) 
      {
          return const CircularProgressIndicator();
      }
      if (snapshot.hasError) 
      {
          return Center(child: Text('No se ha podido cargar el historial clínico}'));
      }

      final records = snapshot.data ?? [];

      if(records.isEmpty)
      {
        return const Center(child: Text('Todavía no hay enfermedades registradas en citas cerradas'));
      }

      return ListView
      (
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children:
        [
          const Text('Historial clínico', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          for (final record in records)
            Card
            (
              child: ListTile
              (
                leading: const Icon(Icons.medical_information_outlined),
                title: Text(record['principalDisease'].toString()),
                subtitle: Text
                (
                  'Detectada en la cita del ${_formatDate(record['date'])}'
                  '${record['doctorName'] == null ? '' : '\nMédico: ${record['doctorName']}'}',
                ),
                isThreeLine: record['doctorName'] != null,
              ),
            ),
          ],
      );
    }
    );
  } 
}