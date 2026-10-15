import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BizaTheme {
  static const Color primaryGreen = Color(0xFF00E676);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0B0B0);
  static const Color accentRed = Color(0xFFFF5252);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF5F5F5);
  static const Color lightText = Color(0xFF1A1A1A);

  static const double paddingH = 24.0;
  static const double paddingV = 24.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryGreen,
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold, color: textWhite),
        titleLarge: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: textWhite),
        bodyMedium: GoogleFonts.montserrat(fontSize: 14, color: textGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primaryGreen,
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold, color: lightText),
        titleLarge: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: lightText),
        bodyMedium: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}