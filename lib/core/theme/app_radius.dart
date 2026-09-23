import 'package:flutter/material.dart';

/// Corner radius scale (dp) per the Frontend Spec. Use these instead of
/// ad-hoc `BorderRadius.circular(...)` numbers.
///
/// Buttons use their own 14dp radius (see
/// lib/core/widgets/buttons/app_button.dart) — the spec gives buttons a
/// radius distinct from this scale, so it's a button-specific constant
/// rather than forced onto one of these tokens.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(pill));
}
