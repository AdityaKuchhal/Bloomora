import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_backend.dart';
import 'analytics_event.dart';
import 'pii_scrub.dart';

/// Only these property keys are ever allowed through to PostHog — an
/// allowlist, not just the pii_scrub.dart denylist, since analytics
/// properties (unlike Sentry's free-form extra/tags) come from a small,
/// fully-enumerable set of legitimate fields (TRD §10.6: event name +
/// app-level metadata only — screen, domain_code, a completion boolean, a
/// duration bucket, app version — never raw assessment content).
const Set<String> approvedAnalyticsPropertyKeys = {
  'screen',
  'domain_code',
  'completed',
  'duration_bucket',
  'app_version',
  'method',
};

/// The actual second-line-of-defense logic [AnalyticsService.capture]
/// runs on every event's properties before it reaches the backend —
/// pulled out as its own pure function, operating on a raw
/// `Map<String, Object?>`, so it's directly testable with a
/// deliberately-injected rogue key without needing to violate
/// [AnalyticsEvent]'s sealed-class closure to fabricate a bad event
/// subtype (which is itself proof the first line of defense holds — see
/// test/core/monitoring/analytics_service_test.dart).
Map<String, Object?> filterAndScrubAnalyticsProperties(Map<String, Object?> properties) {
  final allowed = {
    for (final entry in properties.entries)
      if (approvedAnalyticsPropertyKeys.contains(entry.key)) entry.key: entry.value,
  };
  return scrubDeniedKeys(allowed);
}

/// Wraps all product-analytics calls (Frontend Spec §8: "No analytics ...
/// calls directly in widgets; route through AnalyticsService"). PostHog
/// only, per FT-008's scoping — backend analytics is explicitly out of
/// scope.
///
/// Defaults to DISABLED. Frontend Spec §11: "do not infer consent from
/// installation alone" — there is no consent-acceptance screen yet
/// (FT-017), so nothing calls [enable] anywhere in this codebase today.
/// Every [capture]/[identify] call already wired into real flows (see
/// FT-008's report) correctly no-ops right now — that's expected, not
/// broken wiring to "fix" later. FT-017/FT-056 own calling [enable] once
/// real consent UI exists.
class AnalyticsService {
  AnalyticsService({AnalyticsBackend? backend})
      : _backend = backend ?? const PostHogAnalyticsBackend();

  final AnalyticsBackend _backend;
  bool _enabled = false;

  bool get isEnabled => _enabled;

  void enable() => _enabled = true;
  void disable() => _enabled = false;

  /// Never a free-form `capture(String, Map)` — only closed, typed
  /// [AnalyticsEvent] subtypes are accepted, so a call site can't
  /// accidentally pass a raw child name or DOB. The type system is the
  /// first line of defense; [scrubDeniedKeys] below is the second, in
  /// case a property sneaks in some other way (e.g. a future event
  /// subtype accidentally including a sensitive field).
  Future<void> capture(AnalyticsEvent event) async {
    if (!_enabled) return;
    final scrubbed = filterAndScrubAnalyticsProperties(event.properties);
    try {
      await _backend.capture(event.name, scrubbed);
    } catch (_) {
      // Monitoring failures must never block a user flow or crash the app.
    }
  }

  /// [userId] must be the Supabase user id (already pseudonymous) — never
  /// an email or any other PII value.
  Future<void> identify(String userId) async {
    if (!_enabled) return;
    try {
      await _backend.identify(userId);
    } catch (_) {
      // Silent — see capture().
    }
  }

  Future<void> reset() async {
    if (!_enabled) return;
    try {
      await _backend.reset();
    } catch (_) {
      // Silent — see capture().
    }
  }
}

/// App-wide singleton — overridden in tests with a fake AnalyticsBackend
/// (see test/core/monitoring/analytics_service_test.dart).
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
