import 'package:posthog_flutter/posthog_flutter.dart';

/// The actual PostHog SDK calls, behind a narrow interface — same
/// testability seam pattern as FT-004's HttpTransport / FT-003's
/// evaluateRedirectFor split: `Posthog()` is a platform-channel-backed
/// singleton that can't be meaningfully driven in a headless `flutter
/// test`, so AnalyticsService is built against this interface and tests
/// inject a fake instead of touching the real SDK.
abstract class AnalyticsBackend {
  Future<void> capture(String event, Map<String, Object?> properties);
  Future<void> identify(String userId);
  Future<void> reset();
}

class PostHogAnalyticsBackend implements AnalyticsBackend {
  const PostHogAnalyticsBackend();

  @override
  Future<void> capture(String event, Map<String, Object?> properties) {
    // Event property maps are built to already exclude null entries (see
    // analytics_event.dart's conditional-inclusion pattern), but the
    // static type is Map<String, Object?> — filter defensively rather
    // than force-cast, since posthog_flutter's capture() takes
    // Map<String, Object>?.
    final nonNullProperties = <String, Object>{
      for (final entry in properties.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    return Posthog().capture(eventName: event, properties: nonNullProperties);
  }

  @override
  Future<void> identify(String userId) {
    return Posthog().identify(userId: userId);
  }

  @override
  Future<void> reset() {
    return Posthog().reset();
  }
}
