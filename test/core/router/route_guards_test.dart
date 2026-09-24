// Verifies route_guards.dart's guard logic directly (evaluateRedirectFor),
// without a live Supabase session — see that function's doc comment for
// why evaluateRedirectFor (not evaluateRedirect) is the test entry point.
//
// What this DOESN'T cover: ChildProfileStepCheck/AssessmentStepCheck's
// actual Supabase queries are exercised here via fake OnboardingStepCheck
// instances (the `steps:` param), not the real Supabase-backed ones — see
// FT-003's report for how those were verified instead (no local/mock
// Supabase instance is available in this environment).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bloomora/core/router/app_routes.dart';
import 'package:bloomora/core/router/route_guards.dart';
import 'package:bloomora/features/auth/presentation/providers/auth_provider.dart';

User _fakeUser(String id) => User(
      id: id,
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

const _unauth = AppAuthState(status: AuthStatus.unauthenticated);
final _authed = AppAuthState(status: AuthStatus.authenticated, user: _fakeUser('user-1'));

class _AlwaysSatisfied extends OnboardingStepCheck {
  final String path;
  const _AlwaysSatisfied(this.path);
  @override
  String get routePath => path;
  @override
  Future<bool> isSatisfied(Ref ref, String userId) async => true;
}

class _NeverSatisfied extends OnboardingStepCheck {
  final String path;
  const _NeverSatisfied(this.path);
  @override
  String get routePath => path;
  @override
  Future<bool> isSatisfied(Ref ref, String userId) async => false;
}

class _CountingStepCheck extends OnboardingStepCheck {
  final String path;
  final void Function() onCall;
  const _CountingStepCheck(this.path, this.onCall);
  @override
  String get routePath => path;
  @override
  Future<bool> isSatisfied(Ref ref, String userId) async {
    onCall();
    return true;
  }
}

// A throwaway provider purely to obtain a valid `Ref` from a
// `ProviderContainer` in tests — `ProviderContainer` itself isn't a `Ref`.
// The fake OnboardingStepChecks below don't actually read anything through
// it; they just need a well-typed value to pass along.
final _refProvider = Provider<Ref>((ref) => ref);

void main() {
  late ProviderContainer container;
  late Ref ref;
  setUp(() {
    container = ProviderContainer();
    ref = container.read(_refProvider);
  });
  tearDown(() => container.dispose());

  group('1. Signed-out session cannot open guarded routes', () {
    // AC: "Signed-out users cannot open child, assessment, dashboard,
    // activity, history or settings routes."
    const guardedRoutes = [
      AppRoutes.home, // dashboard
      AppRoutes.search,
      AppRoutes.progress, // "history"-equivalent
      AppRoutes.profile, // "settings"-equivalent
      AppRoutes.onboardingChildProfile, // "child" route
      AppRoutes.onboardingAssessment, // "assessment" route
      '/activity/abc123', // activity route (path param variant)
      '/activity/abc123/completion',
    ];

    for (final route in guardedRoutes) {
      test('$route -> redirected to /sign-in', () async {
        final result = await evaluateRedirectFor(_unauth, ref, route);
        expect(result, AppRoutes.signIn);
      });
    }

    test('signed-out group itself is NOT redirected', () async {
      for (final route in AppRoutes.signedOutGroup) {
        final result = await evaluateRedirectFor(_unauth, ref, route);
        expect(result, isNull, reason: '$route should not redirect');
      }
    });
  });

  group('2. Onboarding-step resolution', () {
    test('all steps satisfied -> lands on /home', () async {
      final steps = [
        const _AlwaysSatisfied(AppRoutes.onboardingConsent),
        const _AlwaysSatisfied(AppRoutes.onboardingChildProfile),
        const _AlwaysSatisfied(AppRoutes.onboardingAssessment),
        const _AlwaysSatisfied(AppRoutes.onboardingPriorities),
      ];
      final result = await evaluateRedirectFor(
        _authed,
        ref,
        AppRoutes.home,
        steps: steps,
      );
      expect(result, isNull); // allowed to render /home
    });

    test('"has children, no completed assessment" -> lands on exactly /onboarding/assessment', () async {
      final steps = [
        const _AlwaysSatisfied(AppRoutes.onboardingConsent),
        const _AlwaysSatisfied(AppRoutes.onboardingChildProfile), // has children
        const _NeverSatisfied(AppRoutes.onboardingAssessment), // no completed assessment
        const _AlwaysSatisfied(AppRoutes.onboardingPriorities),
      ];
      // Hitting /home (or any other route) while onboarding is incomplete
      // forwards to the actual unmet step — not an earlier or later one.
      final result = await evaluateRedirectFor(_authed, ref, AppRoutes.home, steps: steps);
      expect(result, AppRoutes.onboardingAssessment);

      // And hitting the correct step itself renders it (no redirect).
      final onStep = await evaluateRedirectFor(
        _authed,
        ref,
        AppRoutes.onboardingAssessment,
        steps: steps,
      );
      expect(onStep, isNull);
    });

    test('"no children" -> lands on exactly /onboarding/child-profile, not assessment', () async {
      final steps = [
        const _AlwaysSatisfied(AppRoutes.onboardingConsent),
        const _NeverSatisfied(AppRoutes.onboardingChildProfile), // no children
        const _NeverSatisfied(AppRoutes.onboardingAssessment), // would also fail, but shouldn't be reached
        const _AlwaysSatisfied(AppRoutes.onboardingPriorities),
      ];
      final result = await evaluateRedirectFor(_authed, ref, AppRoutes.home, steps: steps);
      expect(result, AppRoutes.onboardingChildProfile);
    });
  });

  group('4. Back navigation cannot skip steps or re-show a finished one', () {
    test('back into an earlier (already-completed) onboarding route forwards to the real step', () async {
      final steps = [
        const _AlwaysSatisfied(AppRoutes.onboardingConsent),
        const _AlwaysSatisfied(AppRoutes.onboardingChildProfile), // completed
        const _NeverSatisfied(AppRoutes.onboardingAssessment), // current step
        const _AlwaysSatisfied(AppRoutes.onboardingPriorities),
      ];
      // User is actually on /onboarding/assessment; hits back into
      // /onboarding/child-profile (already done) — must forward, not render.
      final result = await evaluateRedirectFor(
        _authed,
        ref,
        AppRoutes.onboardingChildProfile,
        steps: steps,
      );
      expect(result, AppRoutes.onboardingAssessment);
    });

    test('back into onboarding after it is fully complete forwards to /home', () async {
      final steps = [
        const _AlwaysSatisfied(AppRoutes.onboardingConsent),
        const _AlwaysSatisfied(AppRoutes.onboardingChildProfile),
        const _AlwaysSatisfied(AppRoutes.onboardingAssessment),
        const _AlwaysSatisfied(AppRoutes.onboardingPriorities),
      ];
      final result = await evaluateRedirectFor(
        _authed,
        ref,
        AppRoutes.onboardingAssessment, // stale bookmark/back-nav
        steps: steps,
      );
      expect(result, AppRoutes.home);
    });
  });

  group('6. Neutral (deep-link) routes never redirect either way', () {
    test('/reset-password is reachable with no session', () async {
      final result = await evaluateRedirectFor(_unauth, ref, AppRoutes.resetPassword);
      expect(result, isNull);
    });

    test('/reset-password does not redirect even for an authenticated user with incomplete onboarding', () async {
      final steps = [const _NeverSatisfied(AppRoutes.onboardingConsent)];
      final result = await evaluateRedirectFor(
        _authed,
        ref,
        AppRoutes.resetPassword,
        steps: steps,
      );
      expect(result, isNull);
    });

    test('/verify-email is exempt regardless of auth state', () async {
      expect(await evaluateRedirectFor(_unauth, ref, AppRoutes.verifyEmail), isNull);
      expect(await evaluateRedirectFor(_authed, ref, AppRoutes.verifyEmail), isNull);
    });
  });

  group('Auth-only routes redirect an already-authenticated user forward', () {
    test('authenticated user hitting /sign-in is routed to their onboarding step', () async {
      final steps = [const _NeverSatisfied(AppRoutes.onboardingConsent)];
      final result = await evaluateRedirectFor(_authed, ref, AppRoutes.signIn, steps: steps);
      expect(result, AppRoutes.onboardingConsent);
    });

    test('authenticated + onboarded user hitting /sign-up is routed to /home', () async {
      final steps = [const _AlwaysSatisfied(AppRoutes.onboardingConsent)];
      final result = await evaluateRedirectFor(_authed, ref, AppRoutes.signUp, steps: steps);
      expect(result, AppRoutes.home);
    });
  });

  test('unknown auth state renders whatever was requested (waiting for auth to resolve)', () async {
    const unknown = AppAuthState(status: AuthStatus.unknown);
    final result = await evaluateRedirectFor(unknown, ref, AppRoutes.home);
    expect(result, isNull);
  });

  group('Onboarding-complete cache (transient-error / tab-switch fix)', () {
    // Reproduces the reported bug directly: a fully onboarded user
    // navigating repeatedly (e.g. tapping between bottom-nav tabs) must not
    // re-invoke the live step checks on every single navigation — only the
    // first time this session, per userId.
    test('second navigation for an already-cached user does not re-invoke the step checks', () async {
      var callCount = 0;
      final steps = [
        _CountingStepCheck(AppRoutes.onboardingConsent, () => callCount++),
        _CountingStepCheck(AppRoutes.onboardingChildProfile, () => callCount++),
      ];

      final first = await evaluateRedirectFor(_authed, ref, AppRoutes.home, steps: steps);
      expect(first, isNull); // onboarding complete -> /home allowed
      expect(callCount, 2, reason: 'first navigation must actually query both steps');

      // Second navigation, same user, same steps list — simulates a bottom-
      // nav tab switch (Home -> Search). If this were a live Supabase
      // timeout on either step, the pre-fix behavior would fail closed and
      // bounce the user into onboarding; with caching it must not even
      // attempt the query.
      final second = await evaluateRedirectFor(_authed, ref, AppRoutes.search, steps: steps);
      expect(second, isNull);
      expect(
        callCount,
        2,
        reason: 'cached "complete" result must skip re-querying the steps entirely',
      );
    });

    test('an unmet step is never cached, so it keeps re-checking live', () async {
      var callCount = 0;
      final steps = [
        _CountingStepCheck(AppRoutes.onboardingConsent, () => callCount++),
        _NeverSatisfied(AppRoutes.onboardingChildProfile),
      ];

      await evaluateRedirectFor(_authed, ref, AppRoutes.home, steps: steps);
      expect(callCount, 1);

      await evaluateRedirectFor(_authed, ref, AppRoutes.search, steps: steps);
      expect(
        callCount,
        2,
        reason: 'an incomplete user must never be short-circuited by the cache',
      );
    });

    test('sign-out clears the cache so a later sign-in re-verifies live', () async {
      final steps = [const _AlwaysSatisfied(AppRoutes.onboardingConsent)];
      await evaluateRedirectFor(_authed, ref, AppRoutes.home, steps: steps);
      expect(
        ref.read(onboardingCompleteCacheProvider.notifier).isComplete('user-1'),
        isTrue,
      );

      await evaluateRedirectFor(_unauth, ref, AppRoutes.signIn);

      expect(
        ref.read(onboardingCompleteCacheProvider.notifier).isComplete('user-1'),
        isFalse,
      );
    });
  });
}
