import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../services/supabase_service.dart';
import 'app_routes.dart';

// ─── Onboarding step resolver ───────────────────────────────────────────────
//
// Ordered list of onboarding steps (PRD §5 flow: consent → child profile →
// assessment → priorities → home). Each step knows its own redirect target
// and how to check whether the user has satisfied it. This is the single
// source of truth for "what onboarding step is this user on" — both the
// router redirect and (previously duplicated) NavigationService logic now
// go through this.
//
// Two steps (Consent, Priorities) are STUBS today because their backing
// tables don't exist yet (FT-017, FT-034). They always return `true` so
// existing users aren't blocked on a table that doesn't exist — but they
// stay wired into the ordered list rather than being removed, so FT-017/
// FT-034 only need to swap the stub body for a real query, never touch the
// router or the resolver.

/// One onboarding step: where to send the user if it's unmet, and how to
/// check whether they've met it.
///
/// Takes a plain [Ref] (not `WidgetRef`) — this runs inside
/// `appRouterProvider`'s own `Provider<GoRouter>((ref) => ...)` closure,
/// which is not a widget context, so `WidgetRef` isn't available/correct
/// here. `Ref` is Riverpod's context-free read/watch handle and is what
/// this actually needs.
abstract class OnboardingStepCheck {
  const OnboardingStepCheck();

  /// Where to redirect the user if [isSatisfied] returns false.
  String get routePath;

  /// Whether this user has completed this step.
  Future<bool> isSatisfied(Ref ref, String userId);
}

class ConsentStepCheck extends OnboardingStepCheck {
  const ConsentStepCheck();

  @override
  String get routePath => AppRoutes.onboardingConsent;

  @override
  Future<bool> isSatisfied(Ref ref, String userId) async {
    // TODO(FT-017): query consents table once it exists; currently a
    // no-op pass-through so existing users aren't blocked on a table that
    // doesn't exist.
    return true;
  }
}

class ChildProfileStepCheck extends OnboardingStepCheck {
  const ChildProfileStepCheck();

  @override
  String get routePath => AppRoutes.onboardingChildProfile;

  @override
  Future<bool> isSatisfied(Ref ref, String userId) async {
    try {
      // Direct Supabase read (RLS-scoped to this user), per the
      // reads-go-direct architecture rule — no backend endpoint for this.
      final response = await SupabaseService.client
          .from('children')
          .select('id')
          .eq('parent_id', userId)
          .limit(1)
          .maybeSingle();
      return response != null;
    } catch (_) {
      // Fail closed: a query error is treated as "not satisfied", not as
      // "let them through" — see the guard's fail-closed policy below.
      return false;
    }
  }
}

class AssessmentStepCheck extends OnboardingStepCheck {
  const AssessmentStepCheck();

  @override
  String get routePath => AppRoutes.onboardingAssessment;

  @override
  Future<bool> isSatisfied(Ref ref, String userId) async {
    try {
      // Assessment rows are only ever written on full completion (see
      // QuestionnaireNotifier.saveAssessment — there's no partial-save/
      // resume row in the DB), so "no completed assessment" and "assessment
      // in progress" are the same state from the DB's point of view, and
      // both correctly resolve to the same target: /onboarding/assessment.
      // QuestionnairePage's own local Riverpod state (not persisted) is
      // what drives in-session resume; there's no separate resume state to
      // reuse beyond that, and this check doesn't need to invent one.
      final child = await SupabaseService.client
          .from('children')
          .select('id')
          .eq('parent_id', userId)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();
      if (child == null) return false;
      final childId = child['id'] as String;

      final assessment = await SupabaseService.client
          .from('assessments')
          .select('id')
          .eq('child_id', childId)
          .not('completed_at', 'is', null)
          .limit(1)
          .maybeSingle();
      return assessment != null;
    } catch (_) {
      return false;
    }
  }
}

class PrioritiesStepCheck extends OnboardingStepCheck {
  const PrioritiesStepCheck();

  @override
  String get routePath => AppRoutes.onboardingPriorities;

  @override
  Future<bool> isSatisfied(Ref ref, String userId) async {
    // TODO(FT-034): query priorities table once it exists.
    return true;
  }
}

/// Ordered per PRD §5: consent → child profile → assessment → priorities.
const List<OnboardingStepCheck> onboardingSteps = [
  ConsentStepCheck(),
  ChildProfileStepCheck(),
  AssessmentStepCheck(),
  PrioritiesStepCheck(),
];

/// Walks [steps] (defaults to [onboardingSteps]) in order; returns the
/// route path of the first unsatisfied step, or `null` if onboarding is
/// complete. [steps] is a test seam — production code always uses the
/// default; tests inject fake steps to verify the walk-in-order logic
/// without a live Supabase connection.
Future<String?> resolveOnboardingRedirect(
  Ref ref,
  String userId, {
  List<OnboardingStepCheck> steps = onboardingSteps,
}) async {
  for (final step in steps) {
    final satisfied = await step.isSatisfied(ref, userId);
    if (!satisfied) return step.routePath;
  }
  return null;
}

// ─── Onboarding-complete cache ──────────────────────────────────────────────
//
// evaluateRedirectFor runs on EVERY navigation attempt — including a fully
// onboarded user just switching bottom-nav tabs (Home -> Search -> Progress
// -> Profile). Without this, each of those taps would re-run
// ChildProfileStepCheck and AssessmentStepCheck's live Supabase queries, and
// both fail closed (`catch (_) { return false; }`) — so a single transient
// timeout on an ordinary tab switch would bounce an actively-using parent
// straight into /onboarding/child-profile. Nothing about their onboarding
// status changed; the check itself just hiccuped.
//
// Fix: once a userId resolves fully complete, remember that for the rest of
// the session and skip the live walk entirely on subsequent navigations.
// Only the *complete* result is cached — an unmet-step result always stays
// live, since that's exactly where freshness matters (e.g. the moment the
// assessment is saved, the very next navigation needs to see it, not a
// stale "not done").
class OnboardingCompleteCache extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  bool isComplete(String userId) => state.contains(userId);

  void markComplete(String userId) {
    if (!state.contains(userId)) state = {...state, userId};
  }

  /// Called wherever onboarding status could actually change for a user:
  /// sign-out (see evaluateRedirectFor's unauthenticated branch, which
  /// clears the whole cache), a child being created
  /// (child_profile_page.dart), or an assessment being completed
  /// (questionnaire_provider.dart). In the current flows these mostly fire
  /// for a user who wasn't cached as complete yet anyway — you can't have
  /// just created a child if ChildProfileStepCheck was already failing you
  /// into onboarding — this exists to stay correct for flows where that
  /// stops being true (e.g. adding a second child later) rather than
  /// covering a hole in today's flow.
  void invalidate(String userId) {
    if (state.contains(userId)) {
      state = {...state}..remove(userId);
    }
  }

  void clear() => state = {};
}

final onboardingCompleteCacheProvider =
    NotifierProvider<OnboardingCompleteCache, Set<String>>(
  OnboardingCompleteCache.new,
);

/// Wraps [resolveOnboardingRedirect] with the cache above: once [userId]
/// has resolved fully complete this session, later calls return `null`
/// immediately without invoking any step's [OnboardingStepCheck.isSatisfied]
/// — see the class doc comment above for why only the complete result is
/// safe to cache.
Future<String?> resolveOnboardingRedirectCached(
  Ref ref,
  String userId, {
  List<OnboardingStepCheck> steps = onboardingSteps,
}) async {
  final cache = ref.read(onboardingCompleteCacheProvider.notifier);
  if (cache.isComplete(userId)) return null;

  final result = await resolveOnboardingRedirect(ref, userId, steps: steps);
  if (result == null) cache.markComplete(userId);
  return result;
}

// ─── Top-level guard ─────────────────────────────────────────────────────
//
// GoRouter's `redirect:` calls this on every navigation attempt (not just
// once at app start) — it re-reads `authProvider` fresh each call, so a
// session that expires mid-use is re-checked on the very next navigation,
// not cached from an earlier decision.
//
// Order: (1) neutral routes bypass everything, (2) auth check, (3)
// onboarding-step resolver, (4) onboarding-complete users are kept out of
// the onboarding group (back-navigation-into-a-finished-step case).

Future<String?> evaluateRedirect(
  Ref ref,
  String location, {
  // Test seam — see resolveOnboardingRedirect's `steps` param.
  List<OnboardingStepCheck> steps = onboardingSteps,
}) {
  return evaluateRedirectFor(ref.read(authProvider), ref, location, steps: steps);
}

/// The actual guard logic, taking [authState] explicitly rather than
/// reading `authProvider` internally — this is what makes it testable
/// without a live Supabase session: `authProvider`'s `AuthNotifier`
/// touches `SupabaseService` in its constructor, so it can't be faked via
/// a provider override in a plain `ProviderContainer` test. [evaluateRedirect]
/// (above) is app_router.dart's actual entry point; tests call this
/// directly with a hand-built [AppAuthState].
Future<String?> evaluateRedirectFor(
  AppAuthState authState,
  Ref ref,
  String location, {
  List<OnboardingStepCheck> steps = onboardingSteps,
}) async {
  // Deep-link/token-carrying routes: Supabase's own SDK validates the
  // token: this router never trusts a route parameter as identity, and
  // never redirects into or out of these based on session state. See the
  // "Deep links" section of the FT-003 ticket / this file's doc comment.
  if (AppRoutes.neutral.contains(location)) return null;

  // Auth state hasn't resolved yet (app just started) — let /splash render
  // rather than guessing; it re-evaluates the instant authProvider settles
  // because this whole callback re-runs on every authProvider change
  // (see _AuthRefreshNotifier in app_router.dart).
  if (authState.isUnknown) return null;

  final isAuthenticated = authState.isAuthenticated;

  // ── 1. Auth check ────────────────────────────────────────────────────
  if (!isAuthenticated) {
    // Sign-out (or a session that just expired): drop any cached
    // "complete" result so a later sign-in — by this user or another one
    // on the same device — re-verifies live rather than trusting a stale
    // cache entry.
    ref.read(onboardingCompleteCacheProvider.notifier).clear();
    if (AppRoutes.signedOutGroup.contains(location)) return null;
    return AppRoutes.signIn;
  }

  // Authenticated from here on.
  final userId = authState.user!.id;

  // Authenticated user hit a signed-out-only screen (sign-in/sign-up/
  // welcome/forgot-password) or /splash — route them into the app instead
  // of showing them the auth form again.
  if (AppRoutes.authOnly.contains(location) || location == AppRoutes.splash) {
    final firstUnmet = await resolveOnboardingRedirectCached(ref, userId, steps: steps);
    return firstUnmet ?? AppRoutes.home;
  }

  // ── 2. Onboarding-step resolver ──────────────────────────────────────
  final firstUnmet = await resolveOnboardingRedirectCached(ref, userId, steps: steps);

  if (firstUnmet != null) {
    // Already exactly on the step they need — render it.
    if (location == firstUnmet) return null;
    // Anything else — an earlier (already-completed) onboarding route hit
    // via back navigation, a later onboarding route they haven't reached
    // yet, or any authenticated+onboarded route — forward to the actual
    // unmet step. This is what makes back navigation unable to skip
    // consent or re-show a finished step: the guard re-evaluates on every
    // navigation attempt and always wins.
    return firstUnmet;
  }

  // ── 3. Onboarding complete: keep users out of the onboarding group ──
  if (AppRoutes.onboardingGroup.contains(location)) {
    return AppRoutes.home;
  }

  return null; // allow: /home, /search, /progress, /profile, /activity/*, ...
}
