import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning/core/utils/date_time_keys.dart';
import 'package:flutter_learning/domain/entities/appointments/appointment.dart';
import 'package:signature/signature.dart';

class CheckInSignatureDialog extends StatefulWidget {
  final BuildContext dialogContext;
  final Appointment appointment;

  const CheckInSignatureDialog({
    super.key,
    required this.appointment,
    required this.dialogContext,
  });

  @override
  State<CheckInSignatureDialog> createState() => _CheckInSignatureDialogState();
}

class _CheckInSignatureDialogState extends State<CheckInSignatureDialog> {
  late final SignatureController _controller;
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _controller.addListener(() {
      final isEmpty = _controller.isEmpty;
      if (isEmpty != _isEmpty) {
        setState(() => _isEmpty = isEmpty);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final navigator = Navigator.of(widget.dialogContext);
    final bytes = await _controller.toPngBytes();
    if (bytes == null) return;
    HapticFeedback.heavyImpact();
    navigator.pop(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appointment = widget.appointment;
    final padWidth = (MediaQuery.of(context).size.width - 120).clamp(
      200.0,
      320.0,
    );

    return AlertDialog(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Firma de check-in',
            style: TextStyle(
              fontSize: 28,
              color: scheme.inverseSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 130,
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: scheme.primary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Firme en el recuadro para confirmar su asistencia.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer.withAlpha(100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${appointment.specialty} · ${appointment.doctorName.trimLeft()}\n ${appointment.date?.day} de ${appointment.date?.monthName} del ${appointment.date?.year} a las ${appointment.date?.hour}:${appointment.date?.minute.toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.inverseSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: padWidth,
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Signature(
                  controller: _controller,
                  width: padWidth,
                  height: 180,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isEmpty
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      _controller.clear();
                    },
              child: const Text('Limpiar'),
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
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              onPressed: _isEmpty ? null : _confirm,
              child: Row(
                spacing: 3,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: scheme.inverseSurface,
                  ),
                  Text(
                    'Confirmar check-in',
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
                Navigator.pop(widget.dialogContext);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 52,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: scheme.surfaceContainer,
                ),
                child: Text(
                  'Volver',
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
