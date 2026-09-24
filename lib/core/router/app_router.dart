import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/presentation/pages/activity_completion_page.dart';
import '../../features/activities/presentation/pages/activity_page.dart';
import '../../features/assessment/presentation/pages/loading_analysis_page.dart';
import '../../features/assessment/presentation/pages/priority_selection_page.dart';
import '../../features/assessment/presentation/pages/questionnaire_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/onboarding/presentation/pages/child_profile_page.dart';
import '../../features/onboarding/presentation/pages/intro_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../widgets/feedback/not_found_screen.dart';
import '../widgets/feedback/placeholder_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';
import 'route_guards.dart';

// ── Router ────────────────────────────────────────────────────────────────────
//
// Route table + a thin `redirect:` that delegates to route_guards.dart. All
// auth/onboarding-step/back-navigation logic lives there — this file should
// stay a plain map of path -> screen. See route_guards.dart's doc comments
// for the guard design.

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) => evaluateRedirect(ref, state.matchedLocation),
    routes: [
      // ── Signed-out group ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const IntroPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: 'sign-up',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return AuthPage(email: email, initialIsSignUp: true);
        },
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: 'sign-in',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return AuthPage(email: email, initialIsSignUp: false);
        },
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        name: 'verify-email',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Forgot password',
          message: "Use 'Forgot password?' on the sign-in screen for now — "
              'a dedicated screen is coming soon.',
          safeActionLabel: 'Back to sign in',
          safeActionRoute: AppRoutes.signIn,
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset-password',
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          return ResetPasswordPage(code: code);
        },
      ),

      // ── Onboarding group ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboardingConsent,
        name: 'onboarding-consent',
        // STUB: ConsentStepCheck always reports satisfied today (FT-017 owns
        // the real table), so the guard never actually routes anyone here —
        // this route exists so FT-017 only has to flip the check, not add a
        // route. See route_guards.dart's ConsentStepCheck.
        builder: (context, state) => const PlaceholderScreen(
          title: 'Consent',
          message: 'Consent collection is coming soon.',
          safeActionLabel: 'Continue',
          safeActionRoute: AppRoutes.onboardingChildProfile,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingChildProfile,
        name: 'onboarding-child-profile',
        builder: (context, state) => const ChildProfilePageNew(),
      ),
      GoRoute(
        path: AppRoutes.onboardingAssessment,
        name: 'onboarding-assessment',
        builder: (context, state) => const QuestionnairePage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingAssessmentAnalyzing,
        name: 'onboarding-assessment-analyzing',
        builder: (context, state) => const LoadingAnalysisPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPriorities,
        name: 'onboarding-priorities',
        builder: (context, state) => const PrioritySelectionPage(),
      ),

      // ── Authenticated + onboarded: detail routes (no bottom nav) ─────────
      // Pushed on top of the shell rather than nested inside it, so the
      // bottom nav chrome simply isn't part of this screen's tree — the
      // simpler of the two options GoRouter supports here (see FT-003
      // report for the tradeoff).
      GoRoute(
        path: AppRoutes.activityPattern,
        name: 'activity',
        builder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          return ActivityPage(activityId: activityId);
        },
      ),
      GoRoute(
        path: AppRoutes.activityCompletionPattern,
        name: 'activity-completion',
        builder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          return ActivityCompletionPage(activityId: activityId);
        },
      ),

      // ── Authenticated + onboarded: bottom-nav shell ───────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) => const DashboardPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.search,
              name: 'search',
              builder: (context, state) => const SearchPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.progress,
              name: 'progress',
              builder: (context, state) => const ProgressPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),
    ],
    // Unknown AND deprecated routes both land here: nothing in this table
    // references an old path anymore, so any leftover bookmark/hardcoded
    // link to e.g. /dashboard or /parent-signup naturally falls through to
    // this, same as a genuinely unknown path — never a crash.
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});

// Bridges Riverpod auth state changes into GoRouter's Listenable refresh system
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
