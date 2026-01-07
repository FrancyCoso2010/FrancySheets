import 'package:flutter/material.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6C63FF),
    brightness: Brightness.dark,
    surface: const Color(0xFF121212),
    surfaceContainerHighest: const Color(0xFF1E1E1E),
    onSurface: Colors.white,
    onSurfaceVariant: Colors.grey.shade400,
    outline: Colors.grey.shade600.withOpacity(0.5),
    primaryContainer: const Color(0xFF4A4477),
    onPrimaryContainer: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF5B4C9C),
    foregroundColor: Colors.white,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF1E1E1E),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
    ),
    hintStyle: TextStyle(color: Colors.grey.shade500),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    contentTextStyle: const TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);