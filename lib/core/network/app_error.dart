/// Typed, already-user-facing errors for every outcome the app-owned API
/// client (see app_api_client.dart) can produce. Every variant carries a
/// safe `message` — never the raw response body, a stack trace, or any
/// SQL/internal detail — plus an optional `requestId` so a user can quote
/// it to support without anything else leaking.
///
/// Default `message` values are the fixed, verbatim strings from Security
/// & Access §4.6 ("General API / network rules"). Two are deliberately
/// NEVER overridden by a server-supplied `userMessage`, even though the
/// general policy elsewhere is "prefer the server's userMessage when the
/// envelope provides one":
///  - 401 (Unauthorized): the whole flow is client-orchestrated (refresh,
///    retry-once, sign-out — see app_api_client.dart); the terminal
///    message is fixed, not relayed from the server.
///  - 403 (Forbidden): the AC is explicit — "does not reveal whether
///    another user owns a resource" — so this can't depend on the backend
///    consistently phrasing two different underlying causes identically.
///    404 is held to the same bar for the same reason (some APIs use 404
///    instead of 403 specifically to avoid confirming a resource exists).
/// 400/409/422/429/5xx do use the server's `userMessage` when present,
/// falling back to these defaults when it's missing (always true for
/// network-level failures, which never reach a server at all).
sealed class AppError {
  final String message;
  final String? requestId;

  const AppError({required this.message, this.requestId});

  @override
  String toString() => '$runtimeType(requestId: $requestId)';
}

/// Offline, DNS failure, or the request/response timing out — anything
/// that never got a response from the server at all.
class OfflineError extends AppError {
  const OfflineError({super.requestId})
      : super(message: 'No connection. Check your internet and try again.');
}

/// 400 — invalid request. `fieldErrors` is only ever populated if the
/// server's envelope included one (the contract documents it as 422-only,
/// but nothing stops a 400 from carrying it too, so it's supported here
/// defensively rather than assumed absent).
class BadRequestError extends AppError {
  final Map<String, String>? fieldErrors;

  const BadRequestError({required super.message, super.requestId, this.fieldErrors});
}

/// 401 — unauthenticated. Only ever surfaced as the *terminal* state of
/// the refresh-then-retry-once flow in app_api_client.dart; a 401 that
/// gets fixed by a refresh never reaches the caller as an error at all.
class UnauthorizedError extends AppError {
  const UnauthorizedError({super.requestId}) : super(message: 'Please sign in again.');
}

/// 403 — forbidden. Message is fixed regardless of cause — see the class
/// doc comment above.
class ForbiddenError extends AppError {
  const ForbiddenError({super.requestId})
      : super(message: "You don't have access to this.");
}

/// 404 — missing resource. Message is fixed regardless of cause — see the
/// class doc comment above.
class NotFoundError extends AppError {
  const NotFoundError({super.requestId})
      : super(message: 'This item is no longer available.');
}

/// 409 — conflict (e.g. a stale write).
class ConflictError extends AppError {
  const ConflictError({super.requestId})
      : super(message: 'This changed somewhere else. Refresh to continue.');
}

/// 422 — validation failure. Treated like 400 for user-facing behavior
/// (field-specific correction, no auto-retry) per this ticket's reading
/// of §4.6, which doesn't list 422 separately from 400 — this is a
/// judgment call, not a literal quote from the security doc.
class ValidationError extends AppError {
  final Map<String, String>? fieldErrors;

  const ValidationError({required super.message, super.requestId, this.fieldErrors});
}

/// 429 — rate limited. `retryAfterSeconds` is the parsed `Retry-After`
/// header when the server sent one as a plain integer-seconds value (an
/// HTTP-date form isn't parsed — out of scope here). This client does not
/// implement backoff/retry itself; FT-058 owns that UX and consumes this
/// value.
class RateLimitedError extends AppError {
  final int? retryAfterSeconds;

  const RateLimitedError({super.requestId, this.retryAfterSeconds})
      : super(message: 'Too many requests. Please wait and try again.');
}

/// 500-599 — server error.
class ServerError extends AppError {
  const ServerError({super.requestId})
      : super(message: 'Something went wrong on our side. Please try again.');
}

/// Anything else: a 2xx response that didn't match the expected success
/// envelope, an unrecognized status code, or a body that failed to parse
/// as JSON at all. Never reached by a spec-compliant backend, but the
/// client must not crash or leak a raw body if one shows up.
class UnknownApiError extends AppError {
  const UnknownApiError({super.requestId})
      : super(message: 'Something went wrong. Please try again.');
}
