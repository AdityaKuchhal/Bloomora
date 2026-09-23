import 'package:flutter/material.dart';

/// Elevation tokens per the Frontend Spec.
///
/// The spec's shadow values (§ shadow-1/shadow-2) read as light-mode-tuned
/// — a dark, low-opacity shadow barely registers on a dark background. The
/// spec doesn't give explicit dark-mode values, so dark elevation here uses
/// a different mechanism entirely: a subtle light-tinted border/overlay
/// instead of a shadow (shadows can't be lighter than the page behind
/// them, which is what "elevated" would need on a dark background — a
/// highlight border is the standard substitute in dark UI design). See
/// [elevation1]/[elevation2]/[darkElevationBorder].
class AppShadows {
  AppShadows._();

  /// Subtle floating controls/cards. Light mode only — see [elevation1].
  static const List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.05),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Modals/elevated hero cards. Light mode only — see [elevation2].
  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.08),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Glass blur sigma range from the spec (12-16px); use [glassBlur] as the
  /// default unless a specific surface calls for the min/max.
  static const double glassBlurMin = 12;
  static const double glassBlurMax = 16;
  static const double glassBlur = 14;

  /// Dark-mode elevation substitute: a light-tinted 1px border instead of a
  /// shadow. [opacity] defaults to a level tuned for [shadow1]-equivalent
  /// (subtle); pass a higher value (e.g. 0.14) for [shadow2]-equivalent
  /// (more prominent, modals/hero cards).
  static Border darkElevationBorder({double opacity = 0.08}) => Border.all(
        color: Colors.white.withValues(alpha: opacity),
        width: 1,
      );

  /// Shadow list for a "resting" elevated surface (cards, floating
  /// controls). Empty in dark mode — pair with [darkElevationBorder] there.
  static List<BoxShadow> elevation1(bool isDark) => isDark ? const [] : shadow1;

  /// Shadow list for a "raised" elevated surface (modals, hero cards).
  /// Empty in dark mode — pair with `darkElevationBorder(opacity: 0.14)`.
  static List<BoxShadow> elevation2(bool isDark) => isDark ? const [] : shadow2;
}
