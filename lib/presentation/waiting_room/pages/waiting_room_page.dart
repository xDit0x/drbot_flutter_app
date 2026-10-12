import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning/domain/entities/appointments/appointment.dart';
import 'package:flutter_learning/domain/entities/appointments/check_in_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_learning/core/utils/date_time_keys.dart';
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

  // No tocar

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
                for (final (i, appointment) in appointments.indexed)
                  _buildAppointmentCard(appointment, isFirst: i == 0),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(
    Appointment appointment, {
    required bool isFirst,
  }) {
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

    Widget _buildQueuePosition(Appointment appointment) {
      final queueNumber = appointment.queueNumber;

      if (queueNumber == null) {
        return const Text('Turno por asignar');
      }

      final doctorId = appointment.doctorId;
      final centerCode =
          appointment.centerCode ?? appointment.medicalCenter.code;
      final date = appointment.date;

      if (doctorId == null ||
          doctorId.isEmpty ||
          centerCode.isEmpty ||
          date == null) {
        return Text(
          'Le quedan ${queueNumber - 1} personas delante',
          style: TextStyle(fontSize: isFirst ? 18 : 14),
        );
      }

      final queueId = '${doctorId}_${centerCode}_${date.dateKey}';

      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Queues')
            .doc(queueId)
            .snapshots(),
        builder: (context, snapshot) {
          final completedCount =
              (snapshot.data?.data()?['completedCount'] as num?)?.toInt() ?? 0;
          final peopleAhead = (queueNumber - completedCount - 1).clamp(
            0,
            queueNumber - 1,
          );

          return Row(
            children: [
              Text('Le quedan', style: TextStyle(fontSize: isFirst ? 16 : 14)),
              Text(
                '\t$peopleAhead\t',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isFirst ? 16 : 14,
                ),
              ),
              Text(
                'personas delante.',
                style: TextStyle(fontSize: isFirst ? 16 : 14),
              ),
            ],
          );
        },
      );
    }

    return Column(
      children: [
        ?isFirst ? null : SizedBox(height: 6),
        Card(
          shadowColor: Theme.of(context).colorScheme.inversePrimary
              .withAlpha(150),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: ListTile(
            title: isFirst
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 12,
                        children: [
                          Icon(
                            Icons.navigate_next,
                            color: Theme.of(context).colorScheme.inverseSurface
                                .withAlpha(150),
                            size: 24,
                          ),
                          Text(
                            "Próxima cita",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Container(
                        color: Theme.of(context).colorScheme.inverseSurface
                            .withAlpha(150),
                        height: 1,
                      ),
                      SizedBox(height: 12),
                    ],
                  )
                : null,
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.specialty.isEmpty
                      ? 'Cita médica'
                      : appointment.specialty,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isFirst ? 22 : 18,
                  ),
                ),
                Text(
                  '${appointment.doctorName.isEmpty ? 'Médico no indicado' : appointment.doctorName}\n'
                  '$dateText\n'
                  '$roomText \n',
                  style: TextStyle(
                    fontSize: isFirst ? 20 : 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                _buildQueuePosition(appointment),
                Text(
                  checkedIn ? 'Check-in realizado' : 'Pendiente de check-in',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isFirst ? 18 : 14,
                  ),
                ),
              ],
            ),
            isThreeLine: false,
            trailing: Container(
              padding: checkedIn
                  ? EdgeInsets.fromLTRB(0, 0, 35, 0)
                  : EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: checkedIn
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 35,
                    )
                  : (date != null && _isToday(date))
                  ? FilledButton(
                      style: FilledButton.styleFrom(),
                      onPressed: () => _checkIn(appointment),
                      child: const Text(
                        'Check-in',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          'Check-In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isFirst ? 18 : 14,
                          ),
                        ),

                        Text(
                          'Disponible el día de la cita',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: isFirst ? 16 : 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        SizedBox(height: 12),
        ?isFirst
            ? Container(
                width: 300,
                height: 1,
                color: Theme.of(context).colorScheme.inverseSurface
                    .withAlpha(50),
              )
            : null,
        SizedBox(height: 10),
        ?isFirst
            ? Container(
                child: Column(
                  children: [
                    Text(
                      'Siguientes citas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    // Container(
                    //   width: 220,
                    //   height: 1,
                    //   color: Theme.of(context).colorScheme.inverseSurface
                    //       .withAlpha(150),
                    // ),
                    SizedBox(height: 4),
                  ],
                ),
              )
            : null,
      ],
    );
  }
}
