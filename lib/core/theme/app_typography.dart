import 'package:flutter/material.dart';

/// Type scale per the Frontend Spec — Manrope for headings, Inter for
/// body/interface text. Both are bundled locally (assets/fonts/, see
/// pubspec.yaml) rather than fetched at runtime.
///
/// These styles carry no [TextStyle.color] — callers apply a theme color
/// via `.copyWith(color: scheme.textPrimary)` (or similar), since color is
/// palette/brightness-dependent and these shapes are not. See
/// lib/core/theme/app_theme.dart for how the Material [TextTheme] is built
/// from these.
///
/// **Sentence case throughout** (buttons, tabs, labels, headings) — never
/// ALL CAPS, except a tiny non-interactive eyebrow label if one is ever
/// needed. This is a content rule for callers; it isn't something a
/// TextStyle can enforce on its own.
///
/// All styles support system text scaling to >=200% without clipping when
/// used inside a container that can grow vertically (min-height, not fixed
/// height) — see lib/core/widgets/buttons/app_button.dart and
/// lib/core/widgets/inputs/app_text_field.dart for that pattern. Resolve
/// the active scale via `MediaQuery.textScalerOf(context)`
/// ([TextScaler]) — never the deprecated `textScaleFactor` double API.
class AppTypography {
  AppTypography._();

  static const manrope = 'Manrope';
  static const inter = 'Inter';

  /// Manrope 700, 32/40.
  static const display = TextStyle(
    fontFamily: manrope,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
  );

  /// Manrope 700, 28/36.
  static const h1 = TextStyle(
    fontFamily: manrope,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
  );

  /// Manrope 700, 24/32.
  static const h2 = TextStyle(
    fontFamily: manrope,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
  );

  /// Manrope 600, 20/28.
  static const h3 = TextStyle(
    fontFamily: manrope,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  /// Inter 600, 18/26.
  static const title = TextStyle(
    fontFamily: inter,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18,
  );

  /// Inter 400, 16/24.
  static const bodyLg = TextStyle(
    fontFamily: inter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  /// Inter 400, 14/20.
  static const body = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  /// Inter 600, 14/20.
  static const label = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );

  /// Inter 600, 15/20. Button label style.
  static const button = TextStyle(
    fontFamily: inter,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
  );

  /// Inter 400, 12/16.
  static const caption = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );
}
