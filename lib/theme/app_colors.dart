import 'package:flutter/material.dart';

/// App color palette for DishaAjyoti
/// Primary: Blue shades
/// Accent: Orange shades
/// Text: Black
class AppColors {
  AppColors._();

  // Primary Colors (Blue)
  static const Color primaryBlue = Color(0xFF0066CC);
  static const Color mediumBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE6F2FF);
  static const Color darkBlue = Color(0xFF003366);

  // Accent Colors (Orange)
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color darkOrange = Color(0xFFFF8C42);
  static const Color lightOrange = Color(0xFFFFF3E0);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF424242);

  // Status Colors
  static const Color success = Color(0xFF06A77D);
  static const Color error = Color(0xFFE63946);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, mediumBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [primaryOrange, darkOrange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [mediumBlue, primaryOrange],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.2);
}
