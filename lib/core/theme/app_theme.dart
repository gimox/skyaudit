import 'package:flutter/material.dart';

class SkyTheme {
  static const Color timBlue = Color(0xFF003399);
  static const Color timRed = Color(0xFFE4010B);
  static const Color background = Color(0xFFF4F4F4);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'TIMSans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: timBlue,
        primary: timBlue,
        secondary: timRed,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: timBlue,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: timBlue, fontWeight: FontWeight.bold),
      ),
    );
  }
}
