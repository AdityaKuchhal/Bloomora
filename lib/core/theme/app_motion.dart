import 'package:flutter/material.dart';

/// Motion tokens per the Frontend Spec: 150-250ms for standard
/// navigation/selection transitions, 250-350ms for sheets. Prefer
/// opacity/position/scale transitions; no bouncing on result/error screens.
class AppMotion {
  AppMotion._();

  /// Standard navigation/selection transitions (150-250ms).
  static const Duration standard = Duration(milliseconds: 200);

  /// Sheet present/dismiss transitions (250-350ms).
  static const Duration sheet = Duration(milliseconds: 300);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve sheetCurve = Curves.easeOutCubic;

  /// Whether the platform/OS has requested reduced motion (accessibility
  /// setting) or Flutter has disabled animations for this context.
  /// Components should check this and skip or shorten non-essential motion
  /// (shimmer sweeps, decorative bounces, shimmer loops) — never skip
  /// motion that itself conveys required state (a loading spinner should
  /// still indicate "loading", just without extra flourish on top).
  static bool isReduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// [standard], or [Duration.zero] when reduce-motion is active.
  static Duration standardOrNone(BuildContext context) =>
      isReduced(context) ? Duration.zero : standard;

  /// [sheet], or [Duration.zero] when reduce-motion is active.
  static Duration sheetOrNone(BuildContext context) =>
      isReduced(context) ? Duration.zero : sheet;
}
