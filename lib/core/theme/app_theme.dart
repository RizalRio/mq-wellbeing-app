import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Definisi Hex Color (Calm Minimalism Palette)
  static const Color warmBeige = Color(0xFFF9F6F0);
  static const Color sageGreen = Color(0xFF8CA595);
  static const Color softTeal = Color(0xFF7CA9A9);
  static const Color lavenderMuda = Color(0xFFE8E6F8);
  static const Color textDark = Color(0xFF2E4037);
  static const Color textLight = Color(0xFF7D8F85);
  static const Color surfaceWhite = Colors.white;

  // 2. Definisi ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: warmBeige,
      colorScheme: const ColorScheme.light(
        primary: sageGreen,
        secondary: softTeal,
        tertiary: lavenderMuda,
        surface: surfaceWhite,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),

      // 3. Konfigurasi Tipografi (Nunito - X-Height tinggi)
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.nunito(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: GoogleFonts.nunito(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.nunito(
          color: textDark,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.nunito(
          color: textLight,
          fontSize: 14,
          height: 1.5,
        ),
      ),

      // 4. Konfigurasi Gaya Komponen (Adaptive & Minimalist)
      appBarTheme: const AppBarTheme(
        backgroundColor: warmBeige,
        elevation: 0,
        scrolledUnderElevation:
            0, // Mencegah perubahan warna saat di-scroll (Material 3)
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),

      // Mengatur ukuran tombol minimal 48px untuk interaksi yang inklusif
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sageGreen,
          foregroundColor: Colors.white,
          elevation: 0, // Flat design
          minimumSize: const Size(88, 48), // WAJIB: Large tap target
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // OutlinedButton untuk aksi sekunder (misal: Logout)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: softTeal,
          minimumSize: const Size(88, 48), // WAJIB: Large tap target
          side: const BorderSide(color: softTeal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Gaya Input Form yang luas dan bersih
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.all(20),
        hintStyle: const TextStyle(color: textLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: sageGreen.withOpacity(0.2),
            width: 1,
          ), // Border sangat tipis
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: sageGreen.withOpacity(0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: softTeal, width: 1.5),
        ),
      ),

      // Card Theme: Flat, nyaris tanpa bayangan, dengan border tipis
      cardTheme: const CardThemeData(
        // PERBAIKAN: Tambahkan kata 'Data' di sini
        color: surfaceWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          // Jika menggunakan const, gunakan warna Hex statis untuk border
          side: BorderSide(
            color: Color(0x268CA595),
            width: 1,
          ), // 0x26 mewakili sekitar 15% opacity
        ),
      ),
    );
  }
}
