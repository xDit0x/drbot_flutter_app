import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/domain/entities/appointments/appointment.dart';
import 'package:flutter_learning/domain/usecases/appointments/get_appointments.dart';
import 'package:flutter_learning/domain/usecases/appointments/remove_appointment.dart';
import 'package:flutter_learning/presentation/appointments/widgets/remove_confirmation_dialog.dart';
import 'package:flutter_learning/service_locator.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  late Future<Either> _future;

  Future<void> _removeAppointment(Appointment appointment) async {
    final confirm = await showDialog<bool>(
      animationStyle: AnimationStyle(
        duration: Duration(milliseconds: 250),
        reverseCurve: Curves.fastOutSlowIn,
      ),
      barrierColor: Colors.black.withAlpha(150),
      context: context,
      builder: (dialogContext) => RemoveConfirmationDialog(
        context: context,
        appointment: appointment,
        dialogContext: dialogContext,
      ),
    );

    if (confirm != true) return;

    final result = await sl<RemoveAppointmentUseCase>().call(
      params: appointment.id,
    );
    if (!mounted) return;

    result.fold(
      (l) => SnackbarRoot.show(
        context,
        l.toString(),
        selection: SnackbarRootType.bad,
      ),
      (r) {
        SnackbarRoot.show(
          context,
          'Cita eliminada',
          selection: SnackbarRootType.ok,
        );
        setState(_load); // recarga el FutureBuilder
      },
    );
  }

  void _showMedicalReport(Appointment appointment) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Informe de atención'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Diagnóstico principal', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(appointment.principalDisease ?? 'No indicado'),
              const SizedBox(height: 16),
              const Text('Resumen e indicaciones', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(appointment.medicalReport ?? 'No hay informe disponible.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = sl<GetAppointmentsUseCase>().call();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 1.4,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error inesperado: ${snapshot.error}'));
        }

        return snapshot.data!.fold((l) => Center(child: Text(l.toString())), (
          r,
        ) {
          final items = (r as List).cast<Appointment>();
          final openAppointments = items.where((appointment) => appointment.status != AppointmentStatus.completed).toList();
          if (openAppointments.isEmpty) {
            return const Center(
              child: Text(
                "No tienes citas pendientes.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            );
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.access_alarm),
                    const Text(
                      ' Citas programadas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.62,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 72),
                  children: [
                    for (final appointment in openAppointments)
                      Card(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: ListTile(
                          leading: Icon(
                            Icons.arrow_right,
                            color: Theme.of(context).colorScheme.inverseSurface,
                          ),
                          title: Text(
                            appointment.specialty,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.date == null
                                    ? 'Fecha por confirmar'
                                    : '${appointment.date!.hour}:${appointment.date!.minute} - ${appointment.date!.day}/${appointment.date!.month}/${appointment.date!.year}',
                                overflow: TextOverflow.visible,
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                '${appointment.doctorName.trimLeft()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text('Estado: ' + appointment.status.label),
                              if (appointment.status == AppointmentStatus.completed)
                                TextButton(
                                  onPressed: () => _showMedicalReport(appointment),
                                  child: const Text('Ver informe de atención'),
                                ),
                            ],
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                            ),
                            child: IconButton(
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                _removeAppointment(appointment);
                              },
                              icon: const Icon(
                                size: 26,
                                Icons.delete_rounded,
                                color: Color.fromARGB(255, 255, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
