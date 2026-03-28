import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/intro/presentation/pages/intro_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/auth/presentation/pages/parent_signin_page.dart';
import '../../features/onboarding/presentation/pages/parent_signup_page.dart';
import '../../features/onboarding/presentation/pages/child_profile_page_new.dart';
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

// Routes that require authentication
const _protectedRoutes = {
  '/dashboard',
  '/questionnaire',
  '/priority-selection',
  '/loading-analysis',
  '/progress',
  '/search',
  '/profile',
};

// Routes only accessible when unauthenticated
const _authOnlyRoutes = {
  '/email-verification',
  '/parent-signin',
  '/parent-signup',
};

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.matchedLocation;

      // Don't redirect while auth state is still resolving
      if (authState.isUnknown) return null;

      final isAuthenticated = authState.isAuthenticated;
      final isProtected = _protectedRoutes.any(
        (r) => location.startsWith(r),
      );
      final isAuthOnly = _authOnlyRoutes.any(
        (r) => location.startsWith(r),
      );

      // Unauthenticated user hitting a protected route → email verification
      if (!isAuthenticated && isProtected) return '/email-verification';

      // Authenticated user hitting an auth-only route → dashboard
      if (isAuthenticated && isAuthOnly) return '/dashboard';

      return null;
    },
    routes: [
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
      GoRoute(
        path: '/email-verification',
        name: 'email-verification',
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: '/parent-signin',
        name: 'parent-signin',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return ParentSigninPage(email: email);
        },
      ),
      GoRoute(
        path: '/parent-signup',
        name: 'parent-signup',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return ParentSignupPage(email: email);
        },
      ),
      GoRoute(
        path: '/child-profile',
        name: 'child-profile',
        builder: (context, state) => const ChildProfilePageNew(),
      ),
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