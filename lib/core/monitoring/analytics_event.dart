/// Closed, typed analytics event taxonomy (Frontend Spec §8: "No analytics
/// ... calls directly in widgets; route through AnalyticsService").
///
/// This is a FIRST-PASS taxonomy, not doc-derived gospel — neither the TRD
/// nor the Frontend Spec gives a literal named event list, only prose
/// ("measure activation, assessment completion, activity opens/
/// completions..."). Flagging for confirmation, per FT-008's own
/// instruction, rather than treating this list as settled:
///   - `childProfileCreated` as the activation signal is my interpretation
///     — it's the practical "this caregiver did the one thing that makes
///     the app useful" moment for a child-development app, but it's a
///     judgment call, not a quote from either doc.
///   - The exact event names/shape below may need adjusting once FT-017
///     (consent), the assessment screens, and the activity screens are
///     actually built and their real UX flow is known.
///
/// Every event exposes only `name` (the PostHog event name) and
/// `properties` (a closed set of typed, non-PII fields) — there is no
/// free-form `capture(String, Map)` anywhere in this file or in
/// AnalyticsService, by design: the type system is the first line of
/// defense against accidentally sending a raw child name or DOB, not
/// caller discipline. AnalyticsService applies a second-line runtime
/// scrub/allowlist on top of this regardless — see pii_scrub.dart.
sealed class AnalyticsEvent {
  const AnalyticsEvent();

  String get name;
  Map<String, Object?> get properties;
}

// ── Signup / auth ────────────────────────────────────────────────────────

class SignupStarted extends AnalyticsEvent {
  const SignupStarted();
  @override
  String get name => 'signup_started';
  @override
  Map<String, Object?> get properties => const {};
}

class SignupCompleted extends AnalyticsEvent {
  const SignupCompleted({required this.method});
  final String method; // 'email' | 'google'
  @override
  String get name => 'signup_completed';
  @override
  Map<String, Object?> get properties => {'method': method};
}

class SigninCompleted extends AnalyticsEvent {
  const SigninCompleted({required this.method});
  final String method; // 'email' | 'google'
  @override
  String get name => 'signin_completed';
  @override
  Map<String, Object?> get properties => {'method': method};
}

class SignoutCompleted extends AnalyticsEvent {
  const SignoutCompleted();
  @override
  String get name => 'signout_completed';
  @override
  Map<String, Object?> get properties => const {};
}

// ── Activation / onboarding ──────────────────────────────────────────────

class OnboardingConsentAccepted extends AnalyticsEvent {
  const OnboardingConsentAccepted();
  @override
  String get name => 'onboarding_consent_accepted';
  @override
  Map<String, Object?> get properties => const {};
}

/// The practical activation signal for this app — see the class-level
/// doc comment above. Not a doc-derived name; flagged for confirmation.
class ChildProfileCreated extends AnalyticsEvent {
  const ChildProfileCreated();
  @override
  String get name => 'child_profile_created';
  @override
  Map<String, Object?> get properties => const {};
}

// ── Assessment ────────────────────────────────────────────────────────────

class AssessmentStarted extends AnalyticsEvent {
  const AssessmentStarted();
  @override
  String get name => 'assessment_started';
  @override
  Map<String, Object?> get properties => const {};
}

class AssessmentSubmitted extends AnalyticsEvent {
  const AssessmentSubmitted({this.durationBucket});
  /// A coarse bucket (e.g. "0-5min", "5-15min"), never a raw timestamp or
  /// exact duration that could be correlated with other data.
  final String? durationBucket;
  @override
  String get name => 'assessment_submitted';
  @override
  Map<String, Object?> get properties =>
      {if (durationBucket != null) 'duration_bucket': durationBucket};
}

class AssessmentScored extends AnalyticsEvent {
  const AssessmentScored();
  @override
  String get name => 'assessment_scored';
  @override
  Map<String, Object?> get properties => const {};
}

// ── Activity ──────────────────────────────────────────────────────────────

class ActivityRecommendationsViewed extends AnalyticsEvent {
  const ActivityRecommendationsViewed({this.domainCode});
  final String? domainCode;
  @override
  String get name => 'activity_recommendations_viewed';
  @override
  Map<String, Object?> get properties =>
      {if (domainCode != null) 'domain_code': domainCode};
}

class ActivityStarted extends AnalyticsEvent {
  const ActivityStarted({this.domainCode});
  final String? domainCode;
  @override
  String get name => 'activity_started';
  @override
  Map<String, Object?> get properties =>
      {if (domainCode != null) 'domain_code': domainCode};
}

class ActivityCompleted extends AnalyticsEvent {
  const ActivityCompleted({this.domainCode, required this.completed});
  final String? domainCode;
  final bool completed;
  @override
  String get name => 'activity_completed';
  @override
  Map<String, Object?> get properties => {
        if (domainCode != null) 'domain_code': domainCode,
        'completed': completed,
      };
}

class ActivityFeedbackSubmitted extends AnalyticsEvent {
  const ActivityFeedbackSubmitted({this.domainCode});
  final String? domainCode;
  @override
  String get name => 'activity_feedback_submitted';
  @override
  Map<String, Object?> get properties =>
      {if (domainCode != null) 'domain_code': domainCode};
}
