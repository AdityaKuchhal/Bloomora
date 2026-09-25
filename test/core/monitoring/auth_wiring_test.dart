// Proves the real wired call sites (not a reimplementation of them) — see
// FT-008's report for exactly which lines these correspond to in
// auth_page.dart / email_verification_page.dart / profile_page.dart /
// child_profile_page.dart.
//
// auth_page.dart's signUp/signIn/Google-signin paths can't be driven
// through a full widget test: they await authProvider.notifier's real
// Supabase calls, and authProvider can't be faked via a provider override
// (AuthNotifier's constructor unconditionally touches Supabase in a
// private _init() method — the exact same class of limitation already
// documented in FT-003/FT-004/FT-005's own test files for this codebase).
// profile_page.dart's sign-out handler is different and genuinely
// testable: the analytics calls are written to fire synchronously BEFORE
// the authProvider read, specifically so this wiring could be verified
// without needing a real Supabase session — this test proves that
// ordering holds.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloomora/core/monitoring/analytics_backend.dart';
import 'package:bloomora/core/monitoring/analytics_service.dart';
import 'package:bloomora/features/profile/presentation/pages/profile_page.dart';

class _RecordingBackend implements AnalyticsBackend {
  final List<String> capturedEvents = [];
  bool resetCalled = false;

  @override
  Future<void> capture(String event, Map<String, Object?> properties) async {
    capturedEvents.add(event);
  }

  @override
  Future<void> identify(String userId) async {}

  @override
  Future<void> reset() async {
    resetCalled = true;
  }
}

void main() {
  testWidgets(
    'tapping Sign Out on the real ProfilePage fires signout_completed and reset() '
    'before the auth call, via the real analyticsServiceProvider read',
    (tester) async {
      final backend = _RecordingBackend();
      final analytics = AnalyticsService(backend: backend)..enable();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [analyticsServiceProvider.overrideWithValue(analytics)],
          child: const MaterialApp(home: ProfilePage()),
        ),
      );
      await tester.pumpAndSettle();

      // The button lives inside a ListView further down the profile
      // screen — scroll it into view before tapping.
      await tester.scrollUntilVisible(find.text('Sign Out'), 200);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Out'));
      // The tap handler's subsequent authProvider.notifier.signOut() read
      // throws synchronously (no live Supabase in this headless test —
      // the same environment limitation documented throughout this
      // project) — expected and irrelevant to what this test is proving.
      // takeException() absorbs it so the test can inspect what happened
      // before that point rather than failing on it.
      await tester.pump();
      tester.takeException();

      expect(backend.capturedEvents, contains('signout_completed'));
      expect(backend.resetCalled, isTrue);
    },
  );
}
