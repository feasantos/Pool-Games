import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1B5E20);
  static const Color accent = Color(0xFFFDD835);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFFF5F5F5);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textLight,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: textLight),
        ),
      );
}
