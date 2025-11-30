import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
/// Class holding all text styles used in the app
class TTextTheme {
  TTextTheme._();

  static TextTheme get lightTextTheme {
    final parisienneTextTheme = GoogleFonts.parisienneTextTheme();
    final interTextTheme = GoogleFonts.interTextTheme();
    
    return TextTheme(
      // Use Parisienne for display text (large headings)
      displayLarge: parisienneTextTheme.displayLarge?.copyWith(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: parisienneTextTheme.displayMedium?.copyWith(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: parisienneTextTheme.displaySmall?.copyWith(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      
      // Use Parisienne for headlines
      headlineLarge: parisienneTextTheme.headlineLarge?.copyWith(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: parisienneTextTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: parisienneTextTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      
      // Use Parisienne for titles
      titleLarge: parisienneTextTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: parisienneTextTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      
      // Use Inter for body text
      bodyLarge: interTextTheme.bodyLarge?.copyWith(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: interTextTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: interTextTheme.bodySmall?.copyWith(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}