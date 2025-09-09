import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - TastyLink
  static const Color primaryColor = Color(0xFF2E7D32); // Green
  static const Color secondaryColor = Color(0xFF4CAF50); // Light Green
  static const Color accentColor = Color(0xFFFF9800); // Orange
  static const Color errorColor = Color(0xFFD32F2F); // Red
  static const Color warningColor = Color(0xFFFFC107); // Amber
  static const Color successColor = Color(0xFF4CAF50); // Green
  
  // Legacy colors for compatibility
  static const Color primaryOrange = accentColor;
  static const Color secondaryLime = secondaryColor;
  static const Color bgLight = Color(0xFFFFFBFE);
  static const Color bgDark = Color(0xFF1C1B1F);
  static const Color textLight = Color(0xFF1C1B1F);
  static const Color textDark = Color(0xFFE6E1E5);
  
  // Additional Colors
  static const Color surfaceLight = Color(0xFFFFFBFE);
  static const Color surfaceDark = Color(0xFF1C1B1F);
  
  // Animation Durations
  static const Duration tabSwitchDuration = Duration(milliseconds: 180);
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
  static const Duration confettiDuration = Duration(milliseconds: 600);
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceLight,
        background: bgLight,
        error: errorColor,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bgLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLight.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 3,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: bgLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textLight.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textLight.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        filled: true,
        fillColor: surfaceLight,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceDark,
        background: bgDark,
        error: errorColor,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: textDark.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 3,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textDark.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textDark.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        filled: true,
        fillColor: surfaceDark,
      ),
    );
  }
  
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light ? textLight : textDark;
    
    return TextTheme(
      // Headlines - Poppins
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      
      // Titles - Poppins
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      
      // Body - Inter
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      
      // Labels - Inter
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }
}
