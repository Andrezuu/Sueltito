import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryYellow = Color(0xFFFDBA21);
  static const Color primaryGreen = Color(0xFF199D89);
  static const Color backgroundGreen = Color(0xFFD4F0E2);
  static const Color textBlack = Color(0xFF000000);
  static const Color textWhite = Color(0xFFFFFFFF);
}

// Tema "Sueltito"
ThemeData getAppTheme() {
  return ThemeData(
    // 1. Color de fondo principal
    scaffoldBackgroundColor: AppColors.backgroundGreen,

    // 2. Tipografía base
    fontFamily: GoogleFonts.urbanist().fontFamily,

    // 3. Tema de AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundGreen,
      elevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.textBlack,
    ),

    // 4. Tema de Botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.urbanist(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}
