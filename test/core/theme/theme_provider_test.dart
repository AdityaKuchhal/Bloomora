// Verifies: (1) manual palette override persists PER CHILD, not as a
// single global override, and (2) AppThemeMode.system switches immediately
// on simulated platform brightness change. See FT-002 AC "theme resolution
// logic" and docs/audit-findings.md.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloomora/core/theme/app_colors.dart';
import 'package:bloomora/core/theme/theme_provider.dart';
import 'package:bloomora/features/onboarding/domain/models/child_model.dart';
import 'package:bloomora/features/onboarding/presentation/providers/onboarding_provider.dart';

ChildModel _child(String id, String gender) => ChildModel(
      id: id,
      parentId: 'parent-1',
      name: 'Test Child $id',
      dateOfBirth: DateTime(2021, 1, 1),
      gender: gender,
      ageGroup: '3-4',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('manual palette override is remembered per child, not globally', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Let ThemeNotifier's async _load() (SharedPreferences) settle.
    await Future<void>.delayed(Duration.zero);

    final childA = _child('child-a', 'Boy');
    final childB = _child('child-b', 'Boy');

    container.read(childNotifierProvider.notifier).setChild(childA);
    // No override yet -> falls back to the child's own gender (Boy -> Ocean).
    expect(container.read(activeColorSchemeProvider), same(AppColors.boyLight));

    // Override child A to Blossom.
    await container.read(themeNotifierProvider.notifier).setPaletteOverride('child-a', 'girl');
    expect(container.read(activeColorSchemeProvider), same(AppColors.girlLight));

    // Switch to child B — no override set for B — resolves independently
    // from child A's override (this is the "not a single global override"
    // regression the audit flagged).
    container.read(childNotifierProvider.notifier).setChild(childB);
    expect(container.read(activeColorSchemeProvider), same(AppColors.boyLight));

    // Switch back to child A — its override is still remembered.
    container.read(childNotifierProvider.notifier).setChild(childA);
    expect(container.read(activeColorSchemeProvider), same(AppColors.girlLight));

    // Clearing child A's override falls back to its own gender again.
    await container.read(themeNotifierProvider.notifier).setPaletteOverride('child-a', null);
    expect(container.read(activeColorSchemeProvider), same(AppColors.boyLight));
  });

  test('previewGender (pre-child) does not leak into a per-child override', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await Future<void>.delayed(Duration.zero);

    // Pre-child: onboarding/auth screens preview Blossom.
    await container.read(themeNotifierProvider.notifier).setGender('girl');
    expect(container.read(activeColorSchemeProvider), same(AppColors.girlLight));

    // Once a child exists with its own gender, that child's gender (not the
    // stale preview) drives resolution.
    container.read(childNotifierProvider.notifier).setChild(_child('child-c', 'Boy'));
    expect(container.read(activeColorSchemeProvider), same(AppColors.boyLight));
  });

  testWidgets('AppThemeMode.system switches immediately on platform brightness change',
      (tester) async {
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        child: Builder(builder: (context) {
          container = ProviderScope.containerOf(context);
          return const SizedBox();
        }),
      ),
    );
    await tester.pump();

    // Default is AppThemeMode.system.
    expect(container.read(themeNotifierProvider).themeMode, AppThemeMode.system);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    tester.binding.handlePlatformBrightnessChanged();
    await tester.pump();
    expect(container.read(activeColorSchemeProvider).isDark, isFalse);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    tester.binding.handlePlatformBrightnessChanged();
    await tester.pump();
    expect(container.read(activeColorSchemeProvider).isDark, isTrue);

    addTearDown(() => tester.platformDispatcher.clearPlatformBrightnessTestValue());
  });

  test('explicit light/dark mode overrides system brightness', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await Future<void>.delayed(Duration.zero);

    await container.read(themeNotifierProvider.notifier).setThemeMode(AppThemeMode.dark);
    expect(container.read(activeColorSchemeProvider).isDark, isTrue);

    await container.read(themeNotifierProvider.notifier).setThemeMode(AppThemeMode.light);
    expect(container.read(activeColorSchemeProvider).isDark, isFalse);
  });
}
