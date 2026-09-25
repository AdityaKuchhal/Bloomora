import type { ErrorEvent } from '@sentry/node';

import { scrubDeniedKeys } from './pii-scrub.js';

/**
 * The actual `beforeSend` hook passed to `Sentry.init` — real wiring, not
 * a function that exists in isolation. Also directly unit-testable with a
 * fabricated `Event` object.
 *
 * Strips, from every event before it leaves the process:
 *   - `user.email` (never sent — logger.ts already established the
 *     Authorization-header-redaction discipline this mirrors, see
 *     config/logger.ts)
 *   - `request.data` (the raw request BODY), `request.cookies`, and
 *     `request.query_string` — dropped ENTIRELY, not selectively scrubbed.
 *     `@sentry/node`'s default `requestDataIntegration` attaches these to
 *     every event unconditionally (confirmed by reading the SDK source —
 *     its own comment reads "Always attach body data that's already on
 *     the scope," and `data` inclusion isn't gated by `sendDefaultPii` at
 *     all). A key-based denylist can't safely handle this the way it does
 *     for `tags`/`extra`: a request body is arbitrary caller-controlled
 *     JSON with no fixed key set — e.g. a future `PATCH
 *     /assessments/:id/responses` body would carry raw assessment scores
 *     under whatever key names that endpoint happens to use, none of
 *     which need to match the denylist for the data to be sensitive. The
 *     only safe move is to never let the body/cookies/query leave the
 *     process at all.
 *   - every `request.headers` key, run through the full denylist (not
 *     just a literal `Authorization` check) — so a custom header like
 *     `X-Auth-Token` is caught too, not only the one exact header name
 *   - any denylisted key (child name, DOB, assessment answer text,
 *     diagnosis, tokens, AI prompts, raw DB payloads — see
 *     lib/pii-scrub.ts) from `tags`, `extra`, and `contexts`, recursively
 *
 * `Sentry.init` also sets `sendDefaultPii: false` explicitly (see
 * lib/sentry.ts) as defense-in-depth on top of this — belt and suspenders,
 * not a substitute for the explicit stripping above, since this function
 * is what's actually verified by test.
 */
export function scrubSentryEvent(event: ErrorEvent): ErrorEvent {
  if (event.user) {
    const { email: _email, ...rest } = event.user;
    event.user = rest;
  }

  if (event.request) {
    const { data: _data, cookies: _cookies, query_string: _queryString, ...safeRequest } =
      event.request;
    event.request = safeRequest;
    if (event.request.headers) {
      event.request.headers = scrubDeniedKeys(
        event.request.headers as Record<string, unknown>,
      ) as Record<string, string>;
    }
  }

  if (event.tags) {
    event.tags = scrubDeniedKeys(event.tags as Record<string, unknown>) as typeof event.tags;
  }

  if (event.extra) {
    event.extra = scrubDeniedKeys(event.extra as Record<string, unknown>);
  }

  if (event.contexts) {
    event.contexts = scrubDeniedKeys(
      event.contexts as Record<string, unknown>,
    ) as typeof event.contexts;
  }

  return event;
}
