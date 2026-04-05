import 'package:flutter/material.dart';

/// A single resolved color scheme for one gender + brightness combination.
class AppColorScheme {
  final Color background;
  final Color surface;
  final Color primary;
  final Color primaryLight;
  final Color accent;
  final Color glassBase;
  final Color glassBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final bool isDark;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.glassBase,
    required this.glassBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.isDark,
  });
}

/// Static definitions for all four color schemes.
///
/// Use [AppColors.forProfile] to resolve the correct scheme at runtime.
class AppColors {
  AppColors._();

  // ─── Boy + Light ───────────────────────────────────────────────────────────

  static const boyLight = AppColorScheme(
    background:    Color(0xFFF0F4FF),
    surface:       Color(0xFFFFFFFF),
    primary:       Color(0xFF1E3A8A),
    primaryLight:  Color(0xFF3B82F6),
    accent:        Color(0xFF60A5FA),
    glassBase:     Color.fromRGBO(255, 255, 255, 0.60),
    glassBorder:   Color.fromRGBO(255, 255, 255, 0.40),
    textPrimary:   Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted:     Color(0xFF94A3B8),
    isDark:        false,
  );

  // ─── Boy + Dark ────────────────────────────────────────────────────────────

  static const boyDark = AppColorScheme(
    background:    Color(0xFF0A0F1E),
    surface:       Color(0xFF111827),
    primary:       Color(0xFF3B82F6),
    primaryLight:  Color(0xFF60A5FA),
    accent:        Color(0xFF93C5FD),
    glassBase:     Color.fromRGBO(255, 255, 255, 0.07),
    glassBorder:   Color.fromRGBO(255, 255, 255, 0.12),
    textPrimary:   Color(0xFFF1F5F9),
    textSecondary: Color(0xFFCBD5E1),
    textMuted:     Color(0xFF64748B),
    isDark:        true,
  );

  // ─── Girl + Light ──────────────────────────────────────────────────────────

  static const girlLight = AppColorScheme(
    background:    Color(0xFFFFF0F6),
    surface:       Color(0xFFFFFFFF),
    primary:       Color(0xFFBE185D),
    primaryLight:  Color(0xFFEC4899),
    accent:        Color(0xFFF472B6),
    glassBase:     Color.fromRGBO(255, 255, 255, 0.60),
    glassBorder:   Color.fromRGBO(255, 255, 255, 0.40),
    textPrimary:   Color(0xFF1A0A12),
    textSecondary: Color(0xFF6B2D4A),
    textMuted:     Color(0xFF9D6B84),
    isDark:        false,
  );

  // ─── Girl + Dark ───────────────────────────────────────────────────────────

  static const girlDark = AppColorScheme(
    background:    Color(0xFF1A0A12),
    surface:       Color(0xFF2D0F1E),
    primary:       Color(0xFFEC4899),
    primaryLight:  Color(0xFFF472B6),
    accent:        Color(0xFFFBCFE8),
    glassBase:     Color.fromRGBO(255, 255, 255, 0.07),
    glassBorder:   Color.fromRGBO(255, 255, 255, 0.12),
    textPrimary:   Color(0xFFFDF2F8),
    textSecondary: Color(0xFFF9A8D4),
    textMuted:     Color(0xFF9D6B84),
    isDark:        true,
  );

  // ─── Resolver ──────────────────────────────────────────────────────────────

  /// Returns the correct [AppColorScheme] for a given gender + brightness pair.
  /// [gender] should be `'boy'`, `'girl'`, or `'unset'` (defaults to boy).
  static AppColorScheme forProfile({
    required String gender,
    required bool isDark,
  }) {
    final isGirl = gender == 'girl';
    if (isGirl) return isDark ? girlDark : girlLight;
    return isDark ? boyDark : boyLight;
  }

  // ─── Shared semantic colors (gender-independent) ───────────────────────────

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error   = Color(0xFFEF4444);
  static const info    = Color(0xFF38BDF8);

  // ─── Legacy static aliases (used by existing screens pre-theme-system) ────
  // These are neutral constants that keep existing code compiling unchanged.
  // Screens rebuilt with the new theme should read from AppColorScheme instead.

  static const primary      = Color(0xFF1E3A8A);
  static const primaryLight = Color(0xFF3B82F6);

  static const textPrimary   = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textMuted     = Color(0xFF94A3B8);

  static const grey50  = Color(0xFFFAFAFA);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);
  static const grey800 = Color(0xFF424242);
  static const grey900 = Color(0xFF212121);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const secondary      = Color(0xFFFF8A80);
  static const secondaryLight = Color(0xFFFFB3A8);

  static const accent      = Color(0xFF81C784);
  static const accentLight = Color(0xFFA5D6A7);

  static const successLight = Color(0xFFA5D6A7);
  static const infoLight    = Color(0xFF90CAF9);

  static const backgroundPrimary   = Color(0xFFFFFBF7);
  static const backgroundSecondary = Color(0xFFF8F5F0);

  static const border = Color(0xFFE8E8E8);
  static const shadow = Color(0x0D2C3E50);

  // Domain colors
  static const domainFineMotor      = Color(0xFF90CAF9);
  static const domainGrossMotor     = Color(0xFFA5D6A7);
  static const domainCommunication  = Color(0xFFFFB3BA);
  static const domainSocialEmotional= Color(0xFFFFCC80);
  static const domainCognitive      = Color(0xFFCE93D8);
  static const domainAdaptive       = Color(0xFF80DEEA);
  static const domainSensory        = Color(0xFFFFF59D);

  // Kid-friendly accents
  static const kidBlue   = Color(0xFF74B9FF);
  static const kidPurple = Color(0xFFCE93D8);
}