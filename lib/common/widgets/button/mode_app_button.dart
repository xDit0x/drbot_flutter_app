import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_learning/common/helpers/is_dark_mode.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_svg/svg.dart';

class ModeButton extends StatelessWidget {
  final ThemeMode themeMode;
  final ThemeMode currentThemeMode;
  final VoidCallback onTap;
  final String iconPath;

  const ModeButton({
    super.key,
    required this.themeMode,
    required this.currentThemeMode,
    required this.onTap,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = themeMode == currentThemeMode;
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.symmetric(
                vertical: BorderSide(
                  color: context.isDarkMode
                      ? AppColors.darkGrey
                      : AppColors.grey,
                  width: 1.2,
                ),
                horizontal: BorderSide(
                  color: context.isDarkMode
                      ? AppColors.darkGrey
                      : AppColors.grey,
                  width: 1.2,
                ),
              ),
              color: isSelected
                  ? (context.isDarkMode ? AppColors.grey : AppColors.darkGrey)
                  : (context.isDarkMode
                        ? Color(0xff30393C).withAlpha(135)
                        : Color.fromARGB(255, 202, 213, 216).withAlpha(135)),
            ),
            child: Padding(
              padding: isSelected ? EdgeInsets.all(25) : EdgeInsets.all(27),
              child: SvgPicture.asset(
                iconPath,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? (context.isDarkMode ? Colors.black : Colors.white)
                      : (context.isDarkMode
                            ? Colors.amber.withAlpha(150)
                            : Colors.amber),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
