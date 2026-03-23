import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  // Primary Colors
  static const Color kDarkBackground = Color(0xFF1A1A1A);
  static const Color kLightBackground = Color(0xFF2C2C2C);
  static const Color kElevatedBackground = Color(0xFF363636);
  static const Color kElectricLime = Color(0xFFE5FF17);
  static const Color kElectricLimeDark = Color(0xFFB8CC12);

  // Text Colors
  static const Color kLightText = Color(0xFFFAFAFA);
  static const Color kSubtleText = Color(0xFF9E9E9E);
  static const Color kMutedText = Color(0xFF6B6B6B);

  // Semantic Colors
  static const Color kSuccess = Color(0xFF4CAF50);
  static const Color kSuccessLight = Color(0xFF81C784);
  static const Color kWarning = Color(0xFFFF9800);
  static const Color kWarningLight = Color(0xFFFFB74D);
  static const Color kError = Color(0xFFE53935);
  static const Color kErrorLight = Color(0xFFEF5350);
  static const Color kInfo = Color(0xFF2196F3);

  // Surface Colors
  static const Color kCardBorder = Color(0xFF3A3A3A);
  static const Color kDivider = Color(0xFF404040);
  static const Color kOverlay = Color(0x99000000);

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING SYSTEM (8px base grid)
  // ═══════════════════════════════════════════════════════════════════════════

  static double get spacing2 => 2.w;
  static double get spacing4 => 4.w;
  static double get spacing6 => 6.w;
  static double get spacing8 => 8.w;
  static double get spacing10 => 10.w;
  static double get spacing12 => 12.w;
  static double get spacing14 => 14.w;
  static double get spacing16 => 16.w;
  static double get spacing20 => 20.w;
  static double get spacing24 => 24.w;
  static double get spacing32 => 32.w;
  static double get spacing40 => 40.w;
  static double get spacing48 => 48.w;
  static double get spacing56 => 56.w;
  static double get spacing64 => 64.w;

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════════════════════════════════

  static double get radiusXs => 4.r;
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 20.r;
  static double get radius2xl => 24.r;
  static double get radiusFull => 999.r;

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationSlower = Duration(milliseconds: 500);

  // Animation Curves
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveEmphasized = Curves.easeOutBack;
  static const Curve curveDecelerate = Curves.decelerate;

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get glowLime => [
        BoxShadow(
          color: kElectricLime.withValues(alpha: 0.3),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  // ═══════════════════════════════════════════════════════════════════════════
  // ICON SIZES
  // ═══════════════════════════════════════════════════════════════════════════

  static double get iconXs => 14.w;
  static double get iconSm => 18.w;
  static double get iconMd => 24.w;
  static double get iconLg => 32.w;
  static double get iconXl => 48.w;

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

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: kLightBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        dragHandleColor: kSubtleText,
        dragHandleSize: Size(40.w, 4.h),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kElevatedBackground,
        contentTextStyle: GoogleFonts.cairo(
          color: kLightText,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: kDivider,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: kLightBackground,
        selectedColor: kElectricLime,
        labelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        indicatorColor: kElectricLime,
        labelColor: kLightText,
        unselectedLabelColor: kSubtleText,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DECORATION HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Standard card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: kLightBackground,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: kCardBorder, width: 1),
      );

  /// Elevated card decoration with shadow
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: kLightBackground,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: shadowMd,
      );

  /// Glass effect decoration
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: kLightBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      );

  /// Accent bordered decoration
  static BoxDecoration get accentBorderedDecoration => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: kElectricLime, width: 1.5),
      );

  /// Filled accent decoration
  static BoxDecoration get accentFilledDecoration => BoxDecoration(
        color: kElectricLime,
        borderRadius: BorderRadius.circular(radiusLg),
      );

  /// Gradient decoration
  static BoxDecoration get gradientDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kElectricLime.withValues(alpha: 0.2),
            kElectricLime.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(
          color: kElectricLime.withValues(alpha: 0.3),
          width: 1,
        ),
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT DECORATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Search field decoration
  static InputDecoration searchInputDecoration({
    String hintText = 'بحث...',
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: kSubtleText, fontSize: 14.sp),
        prefixIcon: prefixIcon ??
            Icon(Icons.search_rounded, color: kSubtleText, size: iconMd),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: kLightBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: kElectricLime, width: 1.5),
        ),
      );
}
