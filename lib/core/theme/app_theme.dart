import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

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
    primaryContainer: scheme.accent,
    onPrimaryContainer: scheme.textPrimary,
    secondary:        scheme.secondary,
    onSecondary:      Colors.white,
    secondaryContainer: scheme.accent.withValues(alpha: 0.2),
    onSecondaryContainer: scheme.textPrimary,
    surface:          scheme.surface,
    onSurface:        scheme.textPrimary,
    error:            AppColors.error,
    onError:          Colors.white,
  );

  // Map the design system's type scale (lib/core/theme/app_typography.dart)
  // onto Material's TextTheme slots, applying scheme colors — the scale
  // itself carries no color (see AppTypography doc comment).
  final textTheme = base.textTheme.copyWith(
    displayLarge: AppTypography.display.copyWith(color: scheme.textPrimary),
    displayMedium: AppTypography.h1.copyWith(color: scheme.textPrimary),
    displaySmall: AppTypography.h2.copyWith(color: scheme.textPrimary),
    headlineLarge: AppTypography.h2.copyWith(color: scheme.textPrimary),
    headlineMedium: AppTypography.h3.copyWith(color: scheme.textPrimary),
    headlineSmall: AppTypography.h3.copyWith(color: scheme.textPrimary),
    titleLarge: AppTypography.title.copyWith(color: scheme.textPrimary),
    titleMedium: AppTypography.title.copyWith(color: scheme.textPrimary),
    titleSmall: AppTypography.label.copyWith(color: scheme.textSecondary),
    bodyLarge: AppTypography.bodyLg.copyWith(color: scheme.textPrimary),
    bodyMedium: AppTypography.body.copyWith(color: scheme.textSecondary),
    bodySmall: AppTypography.caption.copyWith(color: scheme.textMuted),
    labelLarge: AppTypography.button.copyWith(color: scheme.textPrimary),
    labelMedium: AppTypography.label.copyWith(color: scheme.textSecondary),
    labelSmall: AppTypography.caption.copyWith(color: scheme.textMuted),
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
      titleTextStyle: AppTypography.title.copyWith(color: scheme.textPrimary),
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
        borderRadius: AppRadius.xlRadius,
      ),
    ),

    // Snackbar matches surface
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.surface,
      contentTextStyle: AppTypography.body.copyWith(color: scheme.textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdRadius,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
