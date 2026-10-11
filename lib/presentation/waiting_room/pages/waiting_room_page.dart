import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning/domain/entities/appointments/appointment.dart';
import 'package:flutter_learning/domain/entities/appointments/check_in_request.dart';

import 'package:flutter_learning/domain/usecases/appointments/check_in_appointment.dart';
import 'package:flutter_learning/domain/usecases/appointments/get_appointments.dart';
import 'package:flutter_learning/presentation/waiting_room/widgets/check_in_signature_dialog.dart';
import 'package:flutter_learning/service_locator.dart';

class WaitingRoomPage extends StatefulWidget {
  const WaitingRoomPage({super.key});

  @override
  State<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  late Future<Either> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = sl<GetAppointmentsUseCase>().call();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _checkIn(Appointment appointment) async {
    final bytes = await showDialog<Uint8List>(
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(150),
      context: context,
      builder: (dialogContext) => CheckInSignatureDialog(
        appointment: appointment,
        dialogContext: dialogContext,
      ),
    );

    if (bytes == null || !mounted) return;

    final result = await sl<CheckInAppointmentUseCase>().call(
      params: CheckInRequest(
        appointmentId: appointment.id,
        signatureBytes: bytes,
      ),
    );

    if (!mounted) return;

    result.fold((l) => _showMessage(l.toString()), (r) {
      HapticFeedback.mediumImpact();
      _showMessage('Check-in realizado. Ya estás en la sala de espera.');
      setState(_load);
    });
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('No se pudieron cargar tus citas.'));
        }

        return snapshot.data!.fold(
          (error) => Center(child: Text(error.toString())),
          (data) {
            final all = (data as List).cast<Appointment>();
            final appointments =
                all
                    .where(
                      (a) =>
                          a.status == AppointmentStatus.scheduled ||
                          a.status == AppointmentStatus.checkedIn ||
                          a.status == AppointmentStatus.inConsultation,
                    )
                    .toList()
                  ..sort((a, b) {
                    if (a.date == null) return 1;
                    if (b.date == null) return -1;
                    return a.date!.compareTo(b.date!);
                  });

            if (appointments.isEmpty) {
              return const Center(
                child: Text('No tienes citas en sala de espera'),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 100),
              children: [
                const Icon(Icons.watch_later),
                const SizedBox(height: 12),
                for (final appointment in appointments)
                  _buildAppointmentCard(appointment),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final date = appointment.date;
    final checkedIn =
        appointment.status == AppointmentStatus.checkedIn ||
        appointment.status == AppointmentStatus.inConsultation;

    final dateText = date == null
        ? 'Fecha no disponible'
        : '${date.day}/${date.month}/${date.year} '
              '${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    final roomText = (appointment.roomLabel?.trim().isNotEmpty ?? false)
        ? 'Sala: ${appointment.roomLabel}, ${appointment.roomCode}'
        : 'Sala por asignar';

    final queueText = appointment.queueNumber != null
        ? 'Le quedan ${appointment.queueNumber! - 1} personas'
        : 'Turno por asignar';

    return Card(
      child: ListTile(
        title: Text(
          appointment.specialty.isEmpty ? 'Cita médica' : appointment.specialty,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          '${appointment.doctorName.isEmpty ? 'Médico no indicado' : appointment.doctorName}\n'
          '$dateText\n'
          '$roomText \n'
          '$queueText\n'
          '${checkedIn ? 'Check-in realizado' : 'Pendiente de check-in'}',
        ),
        isThreeLine: false,
        trailing: checkedIn
            ? const Icon(Icons.check_circle, color: Colors.green)
            : (date != null && _isToday(date))
            ? FilledButton(
                onPressed: () => _checkIn(appointment),
                child: const Text('Check-in'),
              )
            : Column(
                children: [
                  const Text(
                    'Check In',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),

                  const Text(
                    'Disponible el día de la cita',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}
