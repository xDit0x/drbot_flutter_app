import 'package:flutter/material.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double? height;

  const BasicAppButton({
    required this.onPressed,
    required this.title,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(height ?? 80),
        backgroundColor: AppColors.primary,
      ),
      autofocus: true,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontFamily: "Satoshi",
          fontWeight: FontWeight.bold,
          fontSize: 18,
          shadows: List.filled(
            5,
            Shadow(
              color: AppColors.darkGrey,
              offset: Offset.fromDirection(4, 0.1),
              blurRadius: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
