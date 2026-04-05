import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/intro_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/onboarding/presentation/pages/child_profile_page.dart';
import '../../features/assessment/presentation/pages/questionnaire_page.dart';
import '../../features/assessment/presentation/pages/priority_selection_page.dart';
import '../../features/assessment/presentation/pages/loading_analysis_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/activities/presentation/pages/activity_page.dart';
import '../../features/activities/presentation/pages/activity_completion_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';

// ── Route sets ────────────────────────────────────────────────────────────────

// Requires authentication. Unauthenticated users are sent to /parent-signup.
// /child-profile is protected: auth must come before profile entry.
const _protectedRoutes = {
  '/child-profile',
  '/dashboard',
  '/questionnaire',
  '/priority-selection',
  '/loading-analysis',
  '/progress',
  '/search',
  '/profile',
};

// Only accessible when NOT authenticated.
// Authenticated users landing here are sent to /dashboard.
// NOTE: /parent-signup is included because after the new flow the router can
// safely redirect authenticated users away from it without the flash problem
// (AuthPage does its own explicit context.go after signup before the guard fires).
const _authOnlyRoutes = {
  '/parent-signup',
  '/parent-signin',
};

// ── Router ────────────────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.matchedLocation;

      // Wait for auth state to resolve before redirecting
      if (authState.isUnknown) return null;

      final isAuthenticated = authState.isAuthenticated;

      // /email-verification is no longer a blocking step in the main flow.
      // Redirect it to the appropriate auth tab so old deep-links still work.
      if (location.startsWith('/email-verification')) {
        return isAuthenticated ? '/dashboard' : '/parent-signin';
      }

      final isProtected = _protectedRoutes.any((r) => location.startsWith(r));
      final isAuthOnly  = _authOnlyRoutes.any((r) => location.startsWith(r));

      // Unauthenticated user hitting a protected route → Auth screen (sign-up tab)
      if (!isAuthenticated && isProtected) return '/parent-signup';

      // Authenticated user hitting an auth-only route:
      // - If they have already completed child profile setup → redirect to dashboard.
      // - If not (e.g. going back from /child-profile before saving) → let them
      //   through so the back button on child_profile_page works correctly.
      if (isAuthenticated && isAuthOnly) {
        final hasChildProfile = ref.read(childNotifierProvider) != null;
        return hasChildProfile ? '/dashboard' : null;
      }

      return null;
    },
    routes: [
      // ── Pre-auth flow ───────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/intro',
        name: 'intro',
        builder: (context, state) => const IntroPage(),
      ),

      // ── Auth ────────────────────────────────────────────────────────────────
      // Both routes open AuthPage; initialIsSignUp controls which tab is active.
      GoRoute(
        path: '/parent-signup',
        name: 'parent-signup',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return AuthPage(email: email, initialIsSignUp: true);
        },
      ),
      GoRoute(
        path: '/parent-signin',
        name: 'parent-signin',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return AuthPage(email: email, initialIsSignUp: false);
        },
      ),

      // ── Post-auth flow ──────────────────────────────────────────────────────
      GoRoute(
        path: '/child-profile',
        name: 'child-profile',
        builder: (context, state) => const ChildProfilePageNew(),
      ),

      // ── Assessment ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/questionnaire',
        name: 'questionnaire',
        builder: (context, state) => const QuestionnairePage(),
      ),
      GoRoute(
        path: '/priority-selection',
        name: 'priority-selection',
        builder: (context, state) => const PrioritySelectionPage(),
      ),
      GoRoute(
        path: '/loading-analysis',
        name: 'loading-analysis',
        builder: (context, state) => const LoadingAnalysisPage(),
      ),

      // ── Authenticated app ───────────────────────────────────────────────────
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/activity/:activityId',
        name: 'activity',
        builder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          return ActivityPage(activityId: activityId);
        },
      ),
      GoRoute(
        path: '/activity-completion/:activityId',
        name: 'activity-completion',
        builder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          return ActivityCompletionPage(activityId: activityId);
        },
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressPage(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Bridges Riverpod auth state changes into GoRouter's Listenable refresh system
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}