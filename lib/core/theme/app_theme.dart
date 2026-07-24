// core/theme/app_theme.dart
import 'package:flutter/material.dart';

/// Centralized theme configuration for the MediQuick application.
/// Provides consistent colors, text styles, and ThemeData
/// used throughout the app.
class AppTheme {
  AppTheme._(); // Prevent instantiation

  // ─── Brand Colors ────────────────────────────────────────
  static const Color primaryColor = Color(0xFF7FA1C3);
  static const Color primaryDark = Color(0xFF6482AD);
  static const Color scaffoldBackground = Color(0xFFF5F6FA);
  static const Color scaffoldBackgroundAlt = Color(0xFFF5EDED);
  static const Color white = Colors.white;

  // ─── Accent Colors ───────────────────────────────────────
  static const Color accentTeal = Colors.teal;
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentOrange = Color(0xFFFF9800);

  // ─── Text Colors ─────────────────────────────────────────
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // ─── Shadows ─────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.grey.shade200,
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ];

  // ─── Border Radius ───────────────────────────────────────
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // ─── ThemeData ───────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackground,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }
}
