import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning/domain/entities/appointments/appointment.dart';

class RemoveConfirmationDialog extends StatelessWidget {
  final BuildContext context;
  final BuildContext dialogContext;
  late final scheme = Theme.of(context).colorScheme;
  final Appointment appointment;
  RemoveConfirmationDialog({
    super.key,
    required this.context,
    required this.appointment,
    required this.dialogContext,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Eliminar cita',
            style: TextStyle(
              fontSize: 32,
              color: scheme.inverseSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 130,
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.red,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '¿Desea eliminar la siguiente cita?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer.withAlpha(100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  appointment.specialty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.inverseSurface,
                  ),
                ),
                Text(
                  appointment.date == null
                      ? 'Fecha por confirmar'
                      : '${appointment.date!.hour}:${appointment.date!.minute} - ${appointment.date!.day}/${appointment.date!.month}/${appointment.date!.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Dr/Dra. ${appointment.doctorName.trimLeft()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Column(
          spacing: 4,
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 13),
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.pop(dialogContext, true);
              },
              child: Row(
                spacing: 3,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.delete, color: scheme.inverseSurface, weight: 4),
                  Text(
                    'Eliminar',
                    style: TextStyle(
                      color: scheme.inverseSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(dialogContext, false);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 52, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: scheme.surfaceContainer,
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: scheme.inverseSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
