import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color orange = Color(0xFFFF6B00);
  static const Color orangeLight = Color(0xFFFF8A65);
  static const Color orangeDark = Color(0xFFE64A19);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF212121);
  
  // Background Colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);
  static const Color surfaceDark = Color(0xFF212121);
  
  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF757575);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFCF6679);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient Colors
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orangeLight, orange, orangeDark],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, Color(0xFF0A0A0A)],
  );

  static const Color onPrimary = Colors.white;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Colors.white;
  static const Color onError = Colors.black;
} 