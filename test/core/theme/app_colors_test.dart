// Verifies the four adaptive palettes resolve to the exact hex values from
// the Frontend Spec §3 — a value assertion, not just "does it compile".
// See lib/core/theme/app_colors.dart and docs/audit-findings.md (FT-002).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloomora/core/theme/app_colors.dart';

void main() {
  group('Ocean Light (boyLight)', () {
    test('matches Frontend Spec §3 exactly', () {
      expect(AppColors.boyLight.primary, const Color(0xFF356FA8));
      expect(AppColors.boyLight.primaryStrong, const Color(0xFF255780));
      expect(AppColors.boyLight.secondary, const Color(0xFF66A6B8));
      expect(AppColors.boyLight.accent, const Color(0xFF8FC7D8));
      expect(AppColors.boyLight.background, const Color(0xFFF6FAFD));
      expect(AppColors.boyLight.surface, const Color(0xFFFFFFFF));
      expect(AppColors.boyLight.surfaceElevated, const Color(0xFFEAF3F8));
      expect(AppColors.boyLight.textPrimary, const Color(0xFF183247));
      expect(AppColors.boyLight.textSecondary, const Color(0xFF607585));
      expect(AppColors.boyLight.border, const Color(0xFFD8E6EE));
      expect(AppColors.boyLight.isDark, isFalse);
    });
  });

  group('Ocean Dark (boyDark)', () {
    test('matches Frontend Spec §3 exactly', () {
      expect(AppColors.boyDark.primary, const Color(0xFF73A9DB));
      expect(AppColors.boyDark.secondary, const Color(0xFF65B1BE));
      expect(AppColors.boyDark.accent, const Color(0xFF9ACCDD));
      expect(AppColors.boyDark.background, const Color(0xFF0D1822));
      expect(AppColors.boyDark.surface, const Color(0xFF152532));
      expect(AppColors.boyDark.surfaceElevated, const Color(0xFF1C3040));
      expect(AppColors.boyDark.textPrimary, const Color(0xFFF2F7FA));
      expect(AppColors.boyDark.textSecondary, const Color(0xFFA7BBC8));
      expect(AppColors.boyDark.border, const Color(0xFF29404F));
      expect(AppColors.boyDark.isDark, isTrue);
    });
  });

  group('Blossom Light (girlLight)', () {
    test('matches Frontend Spec §3 exactly', () {
      expect(AppColors.girlLight.primary, const Color(0xFFA95F86));
      expect(AppColors.girlLight.primaryStrong, const Color(0xFF85476A));
      expect(AppColors.girlLight.secondary, const Color(0xFF9875B5));
      expect(AppColors.girlLight.accent, const Color(0xFFD7A3BC));
      expect(AppColors.girlLight.background, const Color(0xFFFCF8FB));
      expect(AppColors.girlLight.surface, const Color(0xFFFFFFFF));
      expect(AppColors.girlLight.surfaceElevated, const Color(0xFFF7EAF1));
      expect(AppColors.girlLight.textPrimary, const Color(0xFF442C3B));
      expect(AppColors.girlLight.textSecondary, const Color(0xFF796471));
      expect(AppColors.girlLight.border, const Color(0xFFECD9E3));
      expect(AppColors.girlLight.isDark, isFalse);
    });
  });

  group('Blossom Dark (girlDark)', () {
    test('matches Frontend Spec §3 exactly', () {
      expect(AppColors.girlDark.primary, const Color(0xFFD58FB2));
      expect(AppColors.girlDark.secondary, const Color(0xFFB49AD0));
      expect(AppColors.girlDark.accent, const Color(0xFFE1B3CB));
      expect(AppColors.girlDark.background, const Color(0xFF1B1218));
      expect(AppColors.girlDark.surface, const Color(0xFF291C25));
      expect(AppColors.girlDark.surfaceElevated, const Color(0xFF35242F));
      expect(AppColors.girlDark.textPrimary, const Color(0xFFFAF3F7));
      expect(AppColors.girlDark.textSecondary, const Color(0xFFCBB5C1));
      expect(AppColors.girlDark.border, const Color(0xFF493340));
      expect(AppColors.girlDark.isDark, isTrue);
    });
  });

  test('semantic colors are a single set, not palette-specific', () {
    expect(AppColors.success, const Color(0xFF15803D));
    expect(AppColors.warning, const Color(0xFFB45309));
    expect(AppColors.error, const Color(0xFFB91C1C));
    expect(AppColors.info, const Color(0xFF0369A1));
  });

  test('fixed accessibility constants', () {
    expect(AppColors.focusRing, const Color(0xFF2563EB));
    expect(AppColors.scrim, const Color.fromRGBO(0, 0, 0, 0.45));
  });

  test('domain accent map covers all 8 spec-named domains', () {
    expect(AppColors.domainColors.keys, hasLength(8));
    expect(AppColors.domainColors['Attention & Play'], const Color(0xFF7C3AED));
    expect(AppColors.domainColors['Cognitive'], const Color(0xFF2563EB));
    expect(AppColors.domainColors['Daily Living'], const Color(0xFF059669));
    expect(AppColors.domainColors['Fine Motor'], const Color(0xFFDB2777));
    expect(AppColors.domainColors['Gross Motor'], const Color(0xFFEA580C));
    expect(AppColors.domainColors['Sensory'], const Color(0xFF0891B2));
    expect(AppColors.domainColors['Social & Emotional'], const Color(0xFFE11D48));
    expect(AppColors.domainColors['Communication'], const Color(0xFF4F46E5));
  });

  test('forProfile resolves gender + brightness to the right scheme', () {
    expect(AppColors.forProfile(gender: 'boy', isDark: false), same(AppColors.boyLight));
    expect(AppColors.forProfile(gender: 'boy', isDark: true), same(AppColors.boyDark));
    expect(AppColors.forProfile(gender: 'girl', isDark: false), same(AppColors.girlLight));
    expect(AppColors.forProfile(gender: 'girl', isDark: true), same(AppColors.girlDark));
    // 'unset' defaults to Ocean (boy) — decided, matches current behavior.
    expect(AppColors.forProfile(gender: 'unset', isDark: false), same(AppColors.boyLight));
  });

  test('dark-mode disabled state is distinct from light-mode (contrast fix)', () {
    expect(AppColors.boyLight.disabledFill, isNot(AppColors.boyDark.disabledFill));
    expect(AppColors.boyLight.disabledText, isNot(AppColors.boyDark.disabledText));
    // Same fixed pair across both palette families for a given brightness.
    expect(AppColors.boyDark.disabledFill, AppColors.girlDark.disabledFill);
    expect(AppColors.boyDark.disabledText, AppColors.girlDark.disabledText);
  });
}
