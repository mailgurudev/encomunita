import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors - Warm & Friendly
  static const Color primaryCoral = Color(0xFFFF6B6B);      // Warm coral-red
  static const Color primaryTeal = Color(0xFF4ECDC4);       // Fresh teal
  static const Color primaryDeep = Color(0xFF45B7AF);       // Deep teal

  // Secondary Colors - Supporting Palette
  static const Color accentOrange = Color(0xFFFFE66D);      // Sunny yellow-orange
  static const Color accentPurple = Color(0xFF9B72CF);      // Friendly purple
  static const Color accentBlue = Color(0xFF74A9E6);        // Calm blue

  // Neutral Colors - Professional & Clean
  static const Color neutralDark = Color(0xFF2D3748);       // Dark charcoal
  static const Color neutralMedium = Color(0xFF718096);     // Medium gray
  static const Color neutralLight = Color(0xFFF7FAFC);      // Light background
  static const Color neutralWhite = Color(0xFFFFFFFF);      // Pure white

  // Semantic Colors - Safety & Trust
  static const Color success = Color(0xFF68D391);           // Success green
  static const Color warning = Color(0xFFFBD38D);           // Warning amber
  static const Color error = Color(0xFFFC8181);             // Error red
  static const Color info = Color(0xFF90CDF4);              // Info blue

  // Background Colors - Warm & Welcoming
  static const Color backgroundPrimary = Color(0xFFFFFDFD); // Slightly warm white
  static const Color backgroundSecondary = Color(0xFFF8F9FA); // Cool gray
  static const Color backgroundAccent = Color(0xFFFFF5F5);  // Very light coral
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryCoral,
        brightness: Brightness.light,
        primary: AppColors.primaryCoral,
        secondary: AppColors.primaryTeal,
        tertiary: AppColors.accentOrange,
        surface: AppColors.backgroundPrimary,
        onPrimary: AppColors.neutralWhite,
        onSecondary: AppColors.neutralWhite,
        onSurface: AppColors.neutralDark,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryCoral,
        foregroundColor: AppColors.neutralWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.neutralWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCoral,
          foregroundColor: AppColors.neutralWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryCoral,
          side: const BorderSide(color: AppColors.primaryCoral, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryCoral,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.neutralWhite,
        elevation: 2,
        shadowColor: AppColors.neutralMedium.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutralLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryCoral, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: AppColors.neutralMedium,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          color: AppColors.neutralDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.neutralWhite,
        selectedItemColor: AppColors.primaryCoral,
        unselectedItemColor: AppColors.neutralMedium,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: AppColors.neutralWhite,
        elevation: 4,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundAccent,
        labelStyle: const TextStyle(
          color: AppColors.primaryCoral,
          fontWeight: FontWeight.w500,
        ),
        selectedColor: AppColors.primaryCoral,
        disabledColor: AppColors.neutralLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
    );
  }
}