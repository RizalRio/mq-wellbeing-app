import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Definisi Hex Color
  static const Color background = Color(0xFFFDFBF7);
  static const Color primary = Color(0xFF7C9A92);
  static const Color secondary = Color(0xFFD4A373);
  static const Color surface = Color(0xFFF4EAD5);
  static const Color textDark = Color(0xFF3D405B);
  static const Color textLight = Color(0xFF8A8D9F);

  // 2. Definisi ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),

      // 3. Konfigurasi Tipografi (Google Fonts)
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.nunito(color: textDark, fontSize: 16),
        bodyMedium: GoogleFonts.nunito(color: textLight, fontSize: 14),
      ),

      // 4. Konfigurasi Gaya Komponen Bawaan
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }
}
