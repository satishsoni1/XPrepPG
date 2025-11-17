// lib/theme.dart
import 'package:flutter/material.dart';

class Brand {
  static const primary = Color(0xFFE4380C);
  static const accent = Color(0xFFFF7A00);
  static const yellow = Color(0xFFFFCC00);
  static const dark = Color(0xFF222222);
  static const muted = Color(0xFF6F7C86);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Brand.primary, primary: Brand.primary, secondary: Brand.accent),
      primaryColor: Brand.primary,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(backgroundColor: Brand.primary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: Brand.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: Brand.accent)),
    );
  }
}
