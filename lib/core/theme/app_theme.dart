import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF0C831F);
  static const Color vibrantYellow = Color(0xFFF7C429);
  static const Color backgroundLightGrey = Color(0xFFF2F3F6);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF0C831F);
  static const Color errorRed = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      primary: primaryGreen,
      onPrimary: cardWhite,
      secondary: vibrantYellow,
      onSecondary: textPrimary,
      error: errorRed,
      onError: cardWhite,
      background: backgroundLightGrey,
      onBackground: textPrimary,
      surface: cardWhite,
      onSurface: textPrimary,
      outline: borderColor,
    );

    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textPrimary),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textPrimary),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textPrimary),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textPrimary),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: textPrimary),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: textSecondary),
      bodyLarge: GoogleFonts.inter(color: textPrimary),
      bodyMedium: GoogleFonts.inter(color: textPrimary),
      bodySmall: GoogleFonts.inter(color: textSecondary),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, color: textPrimary),
      labelMedium: GoogleFonts.inter(color: textSecondary),
      labelSmall: GoogleFonts.inter(color: textTertiary),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: cardWhite,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }
}
