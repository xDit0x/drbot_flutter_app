import 'package:flutter/material.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.lightBackground,
      onSurface: Colors.black,
      surfaceContainer: AppColors.lightContainer,
      surfaceContainerHigh: AppColors.lightContainerHigh,
      inverseSurface: const Color(0xFF1C1C1E),
      onInverseSurface: Colors.white,
      error: Colors.red,
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.darkGrey,
      unselectedLabelColor: AppColors.grey,
      indicatorColor: AppColors.primary,
      labelStyle: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.bold),
    ),

    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    brightness: Brightness.light,
    fontFamily: 'Satoshi',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      hintStyle: TextStyle(
        color: Color(0xff383838),
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.w700),
      contentPadding: EdgeInsets.all(25),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black, width: 1.8),
      ),
    ),

    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        elevation: 0,
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );
  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: Colors.white,
      surface: AppColors.darkBackground, // negro puro, como pides
      onSurface: Colors.white,
      surfaceContainer: AppColors.darkContainer,
      surfaceContainerHigh: AppColors.darkContainerHigh,
      inverseSurface: AppColors.inverseDark,
      onInverseSurface: Colors.black,
      error: const Color(0xFFFF453A), // rojo sistema iOS en dark
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: AppColors.grey,
      indicatorColor: AppColors.primary,
      labelStyle: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.bold),
    ),
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    brightness: Brightness.dark,
    fontFamily: 'Satoshi',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      hintStyle: TextStyle(
        color: Color(0xffA7A7A7),
        fontWeight: FontWeight.w500,
      ),
      contentPadding: EdgeInsets.all(30),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.white, width: 0.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.white, width: 0.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        elevation: 0,
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );
}
