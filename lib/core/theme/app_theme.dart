  import 'package:a_play/core/theme/custom_theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();
  // Color constants

  static const Color primary = Color(0xFFFF4707);
  static const Color secondaryPink = Color.fromARGB(255, 255, 192, 171);
  static const Color accentCyan = Color(0xFF00E5FF);

  // Background gradient colors
  static const Color backgroundStart = Color(0xFF121212);
  static const Color backgroundMiddle = Color(0xFF1E1D22);
  static const Color backgroundEnd = Color(0xFF121212);

  // Surface colors
  static const Color surfaceDark = Color.fromARGB(255, 0, 0, 0);
  static const Color surfaceMedium = Color.fromARGB(15, 255, 38, 38);
  static const Color surfaceLight = Color(0xFF2A1F3D);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB4BBCC);
  static const Color textMuted = Color(0xFF7E7A9A);

  static ThemeData get darkTheme {
    final parisienneTextTheme = GoogleFonts.parisienneTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundStart,
      primaryColor: primary,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      highlightColor: primary.withValues(alpha: 0.08),
      splashColor: primary.withValues(alpha: 0.12),

      // Smoother, more consistent screen transitions across platforms -
      // same navigation, nicer motion.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondaryPink,
        tertiary: Colors.amberAccent,
        surface: surfaceMedium,
        error: Color(0xFFFF3D71),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        surfaceContainerHighest: surfaceLight,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDark,
        contentTextStyle: TextStyle(
          color: textPrimary,
          fontFamily: GoogleFonts.inter().fontFamily,
          fontSize: 14,
        ),
        actionTextColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // Font Family
      fontFamily: GoogleFonts.inter().fontFamily,

      // Card Theme
      cardTheme: CardThemeData(
        color: backgroundMiddle,
        elevation: 0,
       // shadowColor: primary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          //side: const BorderSide(color: surfaceLight, width: 1),
        ),
      ),

      // AppBar Theme
      appBarTheme:  AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: GoogleFonts.parisienne().fontFamily,
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme:  BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: GoogleFonts.inter().fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: GoogleFonts.inter().fontFamily,
          fontSize: 12,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xFFFF3D71)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(
          fontFamily: GoogleFonts.inter().fontFamily,
          color: textMuted,
          fontSize: 14,
        ),
        prefixIconColor: primary,
        suffixIconColor: primary,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return primary.withValues(alpha: 0.35);
            }
            if (states.contains(WidgetState.pressed)) {
              return Color.lerp(primary, Colors.black, 0.12);
            }
            return primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white;
          }),
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.08)),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return 0;
            if (states.contains(WidgetState.pressed)) return 1;
            return 4;
          }),
          shadowColor: WidgetStateProperty.all(primary.withValues(alpha: 0.5)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: GoogleFonts.inter().fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          animationDuration: const Duration(milliseconds: 150),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? primary.withValues(alpha: 0.4)
                : primary;
          }),
          overlayColor: WidgetStateProperty.all(primary.withValues(alpha: 0.08)),
          side: WidgetStateProperty.resolveWith((states) {
            return BorderSide(
              color: states.contains(WidgetState.disabled)
                  ? primary.withValues(alpha: 0.4)
                  : primary,
            );
          }),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: GoogleFonts.inter().fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? textMuted
                : primary;
          }),
          overlayColor: WidgetStateProperty.all(primary.withValues(alpha: 0.08)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(textPrimary.withValues(alpha: 0.08)),
          foregroundColor: WidgetStateProperty.all(textPrimary),
        ),
      ),

      // Progress indicators inherit the brand color everywhere automatically.
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceLight,
        circularTrackColor: surfaceLight,
      ),

      // Consistent, unobtrusive tooltips.
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: textPrimary,
          fontFamily: GoogleFonts.inter().fontFamily,
          fontSize: 12,
        ),
      ),

      // Text Theme
      textTheme: TTextTheme.lightTextTheme,

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMedium,
        selectedColor: primary,
        disabledColor: surfaceMedium,
        labelStyle: TextStyle(
          fontFamily: GoogleFonts.inter().fontFamily, 
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: const BorderSide(color: surfaceLight, width: 1),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: surfaceLight,
        thickness: 1,
        space: 24,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundMiddle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Bottom Sheet Theme - matches dialog rounding for a consistent
      // "raised surface" feel across the app.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: backgroundMiddle,
        modalBackgroundColor: backgroundMiddle,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: textMuted.withValues(alpha: 0.4),
      ),

      // List Tile Theme - consistent row spacing/rounding wherever
      // ListTile is used instead of ad-hoc per-screen padding.
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Switch / Checkbox / Radio Themes - same brand color, consistent
      // states everywhere instead of default Material colors leaking in.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? primary : textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primary.withValues(alpha: 0.4)
              : surfaceLight;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? primary : Colors.transparent;
        }),
        side: const BorderSide(color: textMuted, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? primary : textMuted;
        }),
      ),

      // Scrollbar Theme - subtle, brand-colored instead of default gray.
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(textMuted.withValues(alpha: 0.5)),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(4),
      ),
    );
  }

  // Light theme can be added here if needed
  static ThemeData get lightTheme {
    return darkTheme.copyWith(
      brightness: Brightness.light,
      // Add light theme specific overrides here
    );
  }
} 
