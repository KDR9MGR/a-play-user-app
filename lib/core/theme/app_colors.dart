import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFFD700);      // Golden yellow for primary actions
  static const Color secondary = Color(0xFF64748B);    // Slate gray for secondary elements
  
  // Background Colors
  static const Color background = Color(0xFF000000);   // Pure black background
  static const Color surface = Color(0xFF121212);      // Slightly lighter black for surfaces
  static const Color surfaceDark = Color(0xFF0F0F0F);  // Even darker surface for elevated cards
  static const Color cardColor = Color(0xFF1E1E1E);    // Dark gray for cards
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);  // Pure white for primary text
  static const Color textSecondary = Color(0xFFE2E8F0); // Light gray for secondary text
  static const Color textMuted = Color(0xFF94A3B8);    // Muted gray for disabled text
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);      // Material green
  static const Color error = Color(0xFFEF4444);        // Red for errors
  static const Color warning = Color(0xFFFFA726);      // Orange for warnings
  static const Color info = Color(0xFF2196F3);         // Blue for info
  
  // Border & Divider
  static const Color border = Color(0xFF2C2C2C);       // Dark gray for borders
  static const Color divider = Color(0xFF2A2A2A);      // Divider color for separations
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xffFF4600),                                 // Golden yellow
    Color(0xFFB03100),                                 // Darker golden
  ];
  
  // Overlay Colors
  static final Color overlay30 = Colors.black.withValues(alpha: 0.3);
  static final Color overlay50 = Colors.black.withValues(alpha: 0.5);
  static final Color overlay70 = Colors.black.withValues(alpha: 0.7);

  // Additional UI Colors
  static const Color surfaceContainerHighest = Color(0xFF2C2C2C); // For elevated containers
  static const Color surfaceContainerHigh = Color(0xFF242424);    // For mid-level containers
  static const Color surfaceContainerLow = Color(0xFF1A1A1A);     // For lower containers
  
  // Interactive Colors
  static const Color buttonBackground = Color(0xFFFFD700);        // Golden yellow for buttons
  static const Color buttonText = Color(0xFF000000);             // Black text on buttons
  static const Color inputBackground = Color(0xFF1A1A1A);        // Dark background for inputs
  static const Color inputBorder = Color(0xFF2C2C2C);           // Darker border for inputs
} 