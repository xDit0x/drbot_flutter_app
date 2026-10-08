import 'package:flutter/material.dart';

enum SnackbarRootType {
  ok(Colors.green, Icons.check_outlined),
  warning(Colors.amber, Icons.warning_amber_outlined),
  bad(Colors.red, Icons.error_outline);

  final Color color;
  final IconData icon;
  const SnackbarRootType(this.color, this.icon);
}

/// Helper para mostrar SnackBars con el estilo de la app.
/// Uso: `SnackbarRoot.show(context, 'Guardado', selection: SnackBarRootSelection.ok)`
class SnackbarRoot {
  const SnackbarRoot._();

  static void show(
    BuildContext context,
    String message, {
    SnackbarRootType selection = SnackbarRootType.bad,
    Widget? leading,
    Widget? trailing,
  }) {
    final contentChildren = <Widget>[
      leading ?? Icon(selection.icon, color: Colors.white),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
    if (trailing != null) contentChildren.add(trailing);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: contentChildren),
        backgroundColor: selection.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
