import 'package:flutter/material.dart';

class AppColors {
  // Marca Apple (azul sistema)
  static const primary = Color.fromARGB(255, 60, 193, 200);
  static const primaryDark = Color.fromARGB(255, 49, 160, 166);

  static const grey = Color(0xffBEBEBE);
  static const darkGrey = Color(0xff343434);

  // Light estilo iOS: fondo gris agrupado + tarjetas blancas
  static const lightBackground = Color.fromARGB(255, 248, 248, 245);
  static const lightContainer = Color(0xFFFFFFFF);
  static const lightContainerHigh = Color(0xFFE5E5EA);

  // Dark estilo iOS: NEGRO puro + tarjetas gris oscuro
  static const darkBackground = Color.fromARGB(255, 23, 23, 23);
  static const darkContainer = Color.fromARGB(255, 30, 30, 32);
  static const darkContainerHigh = Color.fromARGB(255, 51, 51, 54);
  static const inverseDark = Color(0xFFF2F2F7);

  static const mildAllergySeverity = Colors.amberAccent;
  static const moderateAllergySeverity = Colors.deepOrangeAccent;
  static const severeAllergySeverity = Colors.redAccent;
}
