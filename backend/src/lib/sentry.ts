import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import * as Sentry from '@sentry/node';

import { env } from '../config/env.js';
import { logger } from '../config/logger.js';
import { scrubSentryEvent } from './sentry-scrub.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/**
 * RELEASE_SHA (a deploy-time git SHA) is preferred when present, then
 * APP_VERSION, then package.json's own version field — neither of the
 * first two exists anywhere in this repo yet (checked, not assumed; see
 * config/env.ts's comment), so this falls through to package.json today.
 */
export function resolveRelease(): string {
  if (env.RELEASE_SHA) return env.RELEASE_SHA;
  if (env.APP_VERSION) return env.APP_VERSION;
  try {
    const packageJsonPath = path.join(__dirname, '../../package.json');
    const packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf-8')) as { version?: string };
    return packageJson.version ?? 'unknown';
  } catch {
    return 'unknown';
  }
}

let sentryInitialized = false;

/**
 * The actual options object passed to `Sentry.init` — pulled out as its
 * own function so a test can call it directly and assert on
 * `environment`/`release`/`beforeSend`/`sendDefaultPii` without needing
 * SENTRY_DSN to be set (env is a frozen singleton computed once at import
 * time — see config/env.ts — so a test can't just flip it mid-file the
 * way this needs). Same pattern as the Flutter side's
 * `configureSentryOptions`.
 */
export function buildSentryInitOptions(): Sentry.NodeOptions {
  return {
    dsn: env.SENTRY_DSN,
    environment: env.NODE_ENV,
    release: resolveRelease(),
    beforeSend: (event) => scrubSentryEvent(event),
    // Explicit, not left at whatever the SDK default happens to be. This
    // SDK version (checked — `sendDefaultPii` isn't a recognized option
    // here, it fails to compile) replaced that flag with this structured
    // `dataCollection` object. `httpBodies: []` is the important one:
    // per the SDK's own source comment on requestDataIntegration, this
    // gates whether the body is ever written onto the scope in the first
    // place ("write-time"), which is an earlier and stronger protection
    // than scrubSentryEvent's after-the-fact stripping (which is
    // "read-time" and always runs regardless, per that same comment —
    // hence still doing both: this is defense-in-depth, not a
    // replacement for the explicit stripping in sentry-scrub.ts, which
    // is what's actually verified by test).
    dataCollection: {
      httpBodies: [],
      cookies: false,
      userInfo: false,
      urlQueryParams: false,
    },
  };
}

/**
 * Called once at server startup (see server.ts). A missing SENTRY_DSN
 * skips init entirely (not an error) — same "optional, not required"
 * treatment as the Flutter side. Wrapped in try/catch: a Sentry init
 * failure must never crash the server or block startup (FT-008 AC).
 */
export function initSentry(): void {
  if (!env.SENTRY_DSN) return;
  try {
    Sentry.init(buildSentryInitOptions());
    sentryInitialized = true;
  } catch (err) {
    logger.warn({ err }, 'Sentry init failed — continuing without error monitoring');
  }
}

/**
 * Wraps Sentry.captureException so a transport/send failure can't
 * propagate and take down whatever was already in the middle of handling
 * an error (see middleware/error-handler.ts, the primary caller). No-ops
 * if init was skipped or failed. `tags` (e.g. requestId/route/method) are
 * attached so the captured event can be correlated with the same request
 * ID the user sees in the response envelope and the structured log line.
 */
export function captureException(error: unknown, tags?: Record<string, string>): void {
  if (!sentryInitialized) return;
  try {
    Sentry.captureException(error, tags ? { tags } : undefined);
  } catch {
    // Silent — see initSentry's doc comment.
  }
}

/** Test-only: lets tests reset the module-level init flag between cases. */
export function _resetForTesting(initialized: boolean): void {
  sentryInitialized = initialized;
}
