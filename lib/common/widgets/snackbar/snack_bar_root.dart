import 'package:flutter/material.dart';

enum SnackBarRootSelection {
  ok(Colors.greenAccent),
  warning(Colors.amberAccent),
  bad(Colors.redAccent);

  final Color color;
  const SnackBarRootSelection(this.color);
}

class SnackbarRoot extends StatelessWidget {
  final String message;
  final Widget? leading;
  final Widget? trailing;
  final SnackBarRootSelection selection;

  const SnackbarRoot({
    super.key,
    required this.message,
    this.leading,
    this.trailing,
    required this.selection,
  });

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: selection.color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
