import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/domain/entities/appointments/appointment.dart';
import 'package:flutter_learning/domain/usecases/appointments/get_appointments.dart';
import 'package:flutter_learning/domain/usecases/appointments/remove_appointment.dart';
import 'package:flutter_learning/service_locator.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  late Future<Either> _future;

  Future<void> _removeAppointment(
    BuildContext btnCtx,
    Appointment appointment,
  ) async {
    final RenderBox button = btnCtx.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(btnCtx).context.findRenderObject()! as RenderBox;
    final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);

    const gap = 8.0;

    var position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy,
      overlay.size.width - button.size.width,
      overlay.size.height - button.size.height,
    );
    final confirm = await showMenu<bool>(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      popUpAnimationStyle: AnimationStyle(
        curve: Curves.fastOutSlowIn,
        duration: Duration(milliseconds: 150),
      ),
      context: btnCtx,
      position: position,
      items: [
        PopupMenuItem(
          value: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.delete_rounded, color: Colors.red, size: 26),
              const SizedBox(width: 8),
              // Text(
              //   '¿Confirmar eliminación?',
              //   style: TextStyle(
              //     color: Theme.of(context).colorScheme.inverseSurface,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
            ],
          ),
        ),
      ],
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
          if (items.isEmpty) {
            return const Center(
              child: Text(
                "Sin citas programadas para su persona.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            );
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 72),
                  children: [
                    for (final appointment in items)
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
                                'Dr/Dra.${appointment.doctorName.trimLeft()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
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
                            child: Builder(
                              builder: (btnCtx) => IconButton(
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  _removeAppointment(btnCtx, appointment);
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
