// Proves the theme-on-returning-sign-in bug is actually fixed: before
// FT-003, a returning user's sign-in never populated childNotifierProvider
// (only fresh onboarding did — see git history of
// NavigationService.getPostLoginRoute), so FT-002's activeColorSchemeProvider
// had no child to resolve Ocean/Blossom from on a plain sign-in.
// loadActiveChildIfAny/applyChildRow fixes this; this test chains the fix
// through to the actual visible effect (the resolved theme), not just "was
// setChild called".
//
// Uses a widget-hosted Consumer to obtain a real WidgetRef (the type
// NavigationService.applyChildRow requires) — a plain ProviderContainer
// only exposes Ref, not WidgetRef, and the two are unrelated types in
// Riverpod. The Supabase *fetch* half of loadActiveChildIfAny (the
// `.from('children').select()...` call) still isn't covered here — same
// class of gap as ChildProfileStepCheck/AssessmentStepCheck in
// route_guards_test.dart, for the same reason (no live/mock Supabase
// instance available in this environment). What IS covered: given a row
// shaped like what that query returns, the parsing + state wiring + theme
// resolution chain is correct end-to-end.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloomora/core/services/navigation_service.dart';
import 'package:bloomora/core/theme/app_colors.dart';
import 'package:bloomora/core/theme/theme_provider.dart';
import 'package:bloomora/features/onboarding/presentation/providers/onboarding_provider.dart';

Map<String, dynamic> _row({required String gender}) => {
      'id': 'child-1',
      'parent_id': 'parent-1',
      'name': 'Test Child',
      'date_of_birth': '2021-01-01T00:00:00.000Z',
      'gender': gender,
      'age_group': '3-4',
      'relationship': 'Mother',
      'created_at': '2024-01-01T00:00:00.000Z',
      'updated_at': '2024-01-01T00:00:00.000Z',
    };

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'applyChildRow populates childNotifierProvider AND the theme resolves to that child\'s palette '
    '(the actual returning-sign-in bug this fixes)',
    (tester) async {
      late WidgetRef capturedRef;
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(builder: (context, ref, _) {
            capturedRef = ref;
            container = ProviderScope.containerOf(context);
            return const SizedBox();
          }),
        ),
      );
      await tester.pump();

      // Before the fix's effect runs: no child, so the theme falls back to
      // the pre-child preview default (Ocean/boyLight) — this is the
      // BROKEN state a returning Blossom-palette family would have been
      // stuck on, since nothing else populates childNotifierProvider on a
      // plain sign-in.
      expect(container.read(childNotifierProvider), isNull);
      expect(container.read(activeColorSchemeProvider), same(AppColors.boyLight));

      // Simulate a returning sign-in fetching a girl-gendered child.
      NavigationService.applyChildRow(capturedRef, _row(gender: 'Girl'));
      await tester.pump();

      expect(container.read(childNotifierProvider)?.id, 'child-1');
      expect(container.read(childNotifierProvider)?.gender, 'Girl');
      // The actual bug fix, end to end: the theme now resolves to Blossom
      // because childNotifierProvider is populated — this is what silently
      // never happened before FT-003 for a returning sign-in.
      expect(container.read(activeColorSchemeProvider), same(AppColors.girlLight));
    },
  );

  testWidgets('applyChildRow with a boy-gendered row resolves to Ocean', (tester) async {
    late WidgetRef capturedRef;
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(builder: (context, ref, _) {
          capturedRef = ref;
          container = ProviderScope.containerOf(context);
          return const SizedBox();
        }),
      ),
    );
    await tester.pump();

    NavigationService.applyChildRow(capturedRef, _row(gender: 'Boy'));
    await tester.pump();

    expect(container.read(activeColorSchemeProvider), same(AppColors.boyLight));
  });
}
