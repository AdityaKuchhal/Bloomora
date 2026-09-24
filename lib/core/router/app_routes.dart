/// Every route path in the app, as a single source of truth — used by both
/// app_router.dart (route table) and route_guards.dart (guard logic), so
/// the two can never drift out of sync on a typo'd string literal.
class AppRoutes {
  AppRoutes._();

  // ─── Signed-out group ───────────────────────────────────────────────────
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signUp = '/sign-up';
  static const signIn = '/sign-in';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  /// Reachable only while unauthenticated — an authenticated user landing
  /// here is redirected into their onboarding step / home instead.
  static const Set<String> authOnly = {welcome, signUp, signIn, forgotPassword};

  /// Never redirected to or from, regardless of auth state. These carry
  /// their own token-based access control (Supabase deep links), not the
  /// session-based guard — see route_guards.dart.
  static const Set<String> neutral = {verifyEmail, resetPassword};

  static const Set<String> signedOutGroup = {
    splash,
    welcome,
    signUp,
    signIn,
    verifyEmail,
    forgotPassword,
    resetPassword,
  };

  // ─── Onboarding group (authenticated, onboarding incomplete) ───────────
  static const onboardingConsent = '/onboarding/consent';
  static const onboardingChildProfile = '/onboarding/child-profile';
  static const onboardingAssessment = '/onboarding/assessment';
  static const onboardingAssessmentAnalyzing = '/onboarding/assessment/analyzing';
  static const onboardingPriorities = '/onboarding/priorities';

  static const Set<String> onboardingGroup = {
    onboardingConsent,
    onboardingChildProfile,
    onboardingAssessment,
    onboardingAssessmentAnalyzing,
    onboardingPriorities,
  };

  // ─── Authenticated + onboarded group ────────────────────────────────────
  static const home = '/home';
  static const search = '/search';
  static const progress = '/progress';
  static const profile = '/profile';

  static String activity(String activityId) => '/activity/$activityId';
  static String activityCompletion(String activityId) => '/activity/$activityId/completion';
  static const activityPattern = '/activity/:activityId';
  static const activityCompletionPattern = '/activity/:activityId/completion';

  static const notFound = '/not-found';
}
