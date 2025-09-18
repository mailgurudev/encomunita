import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true, // Ensures Material 3 is used

  scaffoldBackgroundColor: const Color(0xFFEFFAF1), // 🌿 Very light mint green

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4CAF50), // 🌱 Green seed
    brightness: Brightness.light,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50), // Primary green
      foregroundColor: Colors.white, // Text color
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
    ),
  ),
);