import 'package:flutter/material.dart';
import 'color_palette.dart';

class AppTheme {
  // 🌞 LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
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
      backgroundColor: ColorPalette.primary,
      foregroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: ColorPalette.surface,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ColorPalette.primary,
      foregroundColor: Colors.white,
    ),
    dividerColor: Colors.grey.shade300,
  );

  // 🌙 DARK THEME
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
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
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.primaryLight,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorPalette.primaryLight),
      ),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ColorPalette.primaryLight,
      foregroundColor: Colors.white,
    ),
    dividerColor: Colors.white24,
  );
}
