import 'package:flutter/material.dart';
import 'color_palette.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: ColorPalette.primary,
    colorScheme: const ColorScheme.light(
      primary: ColorPalette.primary,
      secondary: ColorPalette.secondary,
      background: ColorPalette.background,
      surface: ColorPalette.surface,
      onSurface: ColorPalette.onSurface,
    ),
    scaffoldBackgroundColor: ColorPalette.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorPalette.surface,
      foregroundColor: ColorPalette.onSurface,
      elevation: 1,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorPalette.primary),
      ),
      filled: true,
      fillColor: ColorPalette.surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: ColorPalette.primaryLight,
    colorScheme: const ColorScheme.dark(
      primary: ColorPalette.primaryLight,
      secondary: ColorPalette.secondary,
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 1,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}