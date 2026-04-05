import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds a [ThemeData] from a resolved [AppColorScheme].
///
/// Glass cards manage their own backgrounds — card theme is transparent.
/// AppBar is transparent with no elevation — each screen controls its own bar.
ThemeData buildTheme(AppColorScheme scheme) {
  final base = scheme.isDark ? ThemeData.dark() : ThemeData.light();

  final colorScheme = ColorScheme(
    brightness:       scheme.isDark ? Brightness.dark : Brightness.light,
    primary:          scheme.primary,
    onPrimary:        Colors.white,
    primaryContainer: scheme.primaryLight,
    onPrimaryContainer: scheme.textPrimary,
    secondary:        scheme.accent,
    onSecondary:      Colors.white,
    secondaryContainer: scheme.accent.withValues(alpha: 0.2),
    onSecondaryContainer: scheme.textPrimary,
    surface:          scheme.surface,
    onSurface:        scheme.textPrimary,
    error:            AppColors.error,
    onError:          Colors.white,
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
    displayLarge: GoogleFonts.inter(
      fontSize: 32, fontWeight: FontWeight.w800,
      color: scheme.textPrimary, letterSpacing: -1.0,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28, fontWeight: FontWeight.w700,
      color: scheme.textPrimary, letterSpacing: -0.8,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24, fontWeight: FontWeight.w700,
      color: scheme.textPrimary, letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 22, fontWeight: FontWeight.w700,
      color: scheme.textPrimary, letterSpacing: -0.3,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20, fontWeight: FontWeight.w600,
      color: scheme.textPrimary,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18, fontWeight: FontWeight.w600,
      color: scheme.textPrimary,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 17, fontWeight: FontWeight.w600,
      color: scheme.textPrimary,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 15, fontWeight: FontWeight.w600,
      color: scheme.textPrimary,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w500,
      color: scheme.textSecondary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w400,
      color: scheme.textPrimary, height: 1.6,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w400,
      color: scheme.textSecondary, height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w400,
      color: scheme.textMuted, height: 1.4,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: scheme.textPrimary, letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w500,
      color: scheme.textSecondary,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w500,
      color: scheme.textMuted, letterSpacing: 0.3,
    ),
  );

  return base.copyWith(
    colorScheme:            colorScheme,
    scaffoldBackgroundColor: scheme.background,
    textTheme:              textTheme,

    // Glass cards handle their own backgrounds — no default card decoration
    cardTheme: const CardThemeData(
      color:       Colors.transparent,
      elevation:   0,
      shadowColor: Colors.transparent,
      margin:      EdgeInsets.zero,
    ),

    // AppBar: transparent, no elevation, centered title
    // Each screen controls its own gradient / glass bar
    appBarTheme: AppBarTheme(
      backgroundColor:  Colors.transparent,
      foregroundColor:  scheme.textPrimary,
      elevation:        0,
      scrolledUnderElevation: 0,
      shadowColor:      Colors.transparent,
      centerTitle:      true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: scheme.textPrimary,
      ),
      systemOverlayStyle: scheme.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),

    // No default dividers
    dividerTheme: const DividerThemeData(
      color: Colors.transparent,
      thickness: 0,
      space: 0,
    ),

    // No default dialog elevation/shadow
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      elevation:       0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),

    // Snackbar matches surface
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.surface,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: scheme.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}