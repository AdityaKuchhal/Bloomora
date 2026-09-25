import 'package:sentry_flutter/sentry_flutter.dart';

import 'pii_scrub.dart';

/// The actual `beforeSend` hook passed to `SentryFlutter.init` — real
/// wiring, not just a function that exists in isolation. Also directly
/// unit-testable with a fabricated [SentryEvent], since Sentry itself
/// can't meaningfully initialize in a headless `flutter test`.
///
/// Strips, from every event before it leaves the process:
///   - `user.email` (never sent — Sentry gets the user id only, if set
///     at all; this app never calls `Sentry.configureScope` with an
///     email in the first place, but this is defense-in-depth)
///   - any `Authorization` header on the request
///   - any denylisted key (child name, DOB, assessment answer text,
///     diagnosis, tokens, AI prompts, raw DB payloads — see
///     pii_scrub.dart) from `tags` and `extra`, recursively
SentryEvent? scrubSentryEvent(SentryEvent event, Hint hint) {
  // Mutating event's fields directly rather than using event.copyWith():
  // both SentryEvent.copyWith and SentryUser.copyWith use the
  // `value ?? this.value` pattern (confirmed by reading the package
  // source, not assumed), so passing an explicit `null` through copyWith
  // to CLEAR a field silently keeps the original value instead — the
  // opposite of what a scrub function needs. SentryEvent's tags/extra/
  // user/request fields are plain mutable fields (not final), so direct
  // assignment is both correct and what the SDK itself expects here.
  final user = event.user;
  if (user != null) {
    // SentryUser's constructor asserts at least one of
    // id/username/email/ipAddress is non-null — if email was the only
    // identifying field set, drop the user object entirely rather than
    // construct an invalid one.
    final hasOtherIdentifyingField =
        user.id != null || user.username != null || user.ipAddress != null;
    event.user = hasOtherIdentifyingField
        ? SentryUser(
            id: user.id,
            username: user.username,
            ipAddress: user.ipAddress,
            geo: user.geo,
            name: user.name,
            data: user.data,
          )
        : null;
  }

  final request = event.request;
  if (request != null) {
    final headers = Map<String, String>.of(request.headers)
      ..removeWhere((key, _) => key.toLowerCase() == 'authorization');
    request.headers = headers;
  }

  if (event.tags != null) {
    event.tags = scrubDeniedKeys(Map<String, Object?>.of(event.tags!))
        .map((key, value) => MapEntry(key, value.toString()));
  }
  // ignore: deprecated_member_use
  if (event.extra != null) {
    // ignore: deprecated_member_use
    event.extra = scrubDeniedKeys(Map<String, Object?>.of(event.extra!));
  }

  return event;
}
