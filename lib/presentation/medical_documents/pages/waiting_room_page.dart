import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/core/utils/date_time_keys.dart';

class WaitingRoomPage extends StatefulWidget
{
  const WaitingRoomPage({super.key});

  @override
  State<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage>
{
  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _future;

  @override
  void initState()
  {
    super.initState();
    _future = _loadAppointments();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _loadAppointments() async
  {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) { return []; }

    final result = await FirebaseFirestore.instance.collection('Users').doc(uid).collection('appointments').get();

    final appointments = result.docs.where((doc)
    {
      final status = doc.data()['status'];
      return status != 'completed' && status != 'cancelled';
    }).toList();

    appointments.sort((a, b)
    {
      final dataA = _dateOf(a.data()['date']) ?? DateTime(9999);
      final dataB = _dateOf(b.data()['date']) ?? DateTime(9999);
      return dataA.compareTo(dataB);
    });

    return appointments;
  }

  DateTime? _dateOf(dynamic value)
  {
    if(value is Timestamp) { return value.toDate(); }
    if (value is DateTime) { return value; }
    if (value is String) { return DateTime.tryParse(value); }
    return null;
  }
 
  bool _isToday(DateTime date)
  {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
 
  Future<void> _checkIn
  (
    QueryDocumentSnapshot<Map<String, dynamic>> appoinment) async
    {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) { return; }

      final data = appoinment.data();
      final doctorId = data['doctorId']?.toString();
      final date = _dateOf(data['date']);


      if (doctorId == null || date == null)
      {
        _showMessage('La cita no tiene médico o fecha asignados');
        return;
      }    

      final slotId = data['slotId']?.toString().isNotEmpty == true ? data['slotId'].toString() : '${doctorId}_${date.dateKey}_${date.timeKey}';

      final firestore = FirebaseFirestore.instance;
      final appoinmentRef = appoinment.reference;
      final slotRef = firestore.collection('Slots').doc(slotId);

      try
      {
        final batch = firestore.batch();

        batch.update(appoinmentRef, { 'status': 'checkedIn', 'checkInAt': FieldValue.serverTimestamp()});
        batch.update(slotRef, {'status': 'checkedIn','checkInAt': FieldValue.serverTimestamp()});
        await batch.commit();

        if(!mounted) { return; }

        setState(() { _future = _loadAppointments(); });

        _showMessage('Chek-in realizado. Ya estás en la sala de espera.');
      }
      on FirebaseException catch (e)
      {
        _showMessage('No se puede hacer el check-in');
      }
    }

    void _showMessage(String text)
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }

    @override
    Widget build(BuildContext context)
    {
      return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      (
        future: _future,
        builder: (context, snapshot)
        {
          if(snapshot.connectionState == ConnectionState.waiting)
          {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError)
          {
            return const Center(child: Text('No se pudieron cargar tus citas.'));
          }

          final appoinments = snapshot.data ?? [];

          if(appoinments.isEmpty)
          {
            return const Center(child: Text('No tienes citas pendientes'));
          }

          return ListView
          (
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children:
            [
              const Text('Sala de espera', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              for(final appointment in appoinments)
                _buildAppointmentsCard(appointment)
            ],
          );
        }
      );
    }

    Widget _buildAppointmentsCard (QueryDocumentSnapshot<Map<String, dynamic>> appoinment)
    {
      final data = appoinment.data();
      final date = _dateOf(data['date']);
      final checkIn = data['status'] == 'checkedIn';

      return Card
      (
        child: ListTile
        (
          title: Text(data['specialty']?.toString() ?? 'Cita médica'),
          subtitle: Text(
            '${data['doctorName'] ?? 'Médico no indicado'}\n'
            '${date == null ? 'Fecha no disponible' : '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'}\n'
            '${checkIn ? 'Check-in realizado' : 'Pendiente de check-in'}\n'
          ),
          isThreeLine: true,
          trailing: checkIn ? const Icon(Icons.check_circle, color: Colors.green) : date != null
          && _isToday(date) ? FilledButton(onPressed: () => _checkIn(appoinment), child: const Text('Check-in')) : const Text('Disponible el día de la cita'),
        ),
      );
    }
}