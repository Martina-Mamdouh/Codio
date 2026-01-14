import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color kDarkBackground = Color(0xFF1A1A1A);
  static const Color kLightBackground = Color(0xFF2C2C2C);
  static const Color kElectricLime = Color(0xFFE5FF17);
  static const Color kLightText = Color(0xFFFAFAFA);
  static const Color kSubtleText = Color(0xFF9E9E9E);

  static ThemeData get darkTheme {
    // Start with a base dark theme to get defaults
    final base = ThemeData.dark();

    // Create the base text theme with Cairo
    final baseTextTheme = GoogleFonts.cairoTextTheme(base.textTheme);

    // Customize the text theme for better spacing and weights
    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        height: 1.2,
        fontWeight: FontWeight.bold,
        color: kLightText,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        height: 1.2,
        fontWeight: FontWeight.bold,
        color: kLightText,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: kLightText,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        height: 1.3,
        fontWeight: FontWeight.bold,
        color: kLightText,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: kLightText,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: kLightText,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: kLightText,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: kLightText,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: kLightText,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        height: 1.6,
        fontSize: 16,
        color: kLightText,
      ), // Improved readability
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        height: 1.6,
        fontSize: 14,
        color: kLightText,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        height: 1.6,
        fontSize: 12,
        color: kSubtleText,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kDarkBackground,
      primaryColor: kElectricLime,

      // Set the default font family for the entire app
      fontFamily: GoogleFonts.cairo().fontFamily,

      // Apply the custom text theme
      textTheme: textTheme,

      colorScheme: ColorScheme.dark(
        primary: kElectricLime,
        secondary: kElectricLime,
        onPrimary: Colors.black,
        surface: kLightBackground,
        onSurface: kLightText,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: kDarkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kLightText),
        titleTextStyle: GoogleFonts.cairo(
          color: kLightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kElectricLime,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ), // Slightly more rounded for modern look
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kLightBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ), // More breathing room
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(
          color: kSubtleText,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        hintStyle: TextStyle(
          color: kSubtleText,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        errorStyle: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily),
      ),

      cardTheme: CardThemeData(
        color: kLightBackground,
        elevation: 0,
        margin: const EdgeInsets.only(
          bottom: 12,
        ), // Add default margin between cards
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: kLightBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kLightText,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 16,
          color: kSubtleText,
          height: 1.5,
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
