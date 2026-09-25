// Import order matters here: ./config/env.js is imported transitively by
// ./app.js (via its middleware/lib imports) before createApp() is ever
// called, so environment validation already ran — and would already have
// crashed the process with a clear error — before any Express construction
// happens. This satisfies the AC ("starts only when required server
// environment variables pass validation") without needing extra
// sequencing code here.
import { createApp } from './app.js';
import { env } from './config/env.js';
import { logger } from './config/logger.js';
import { captureException, initSentry } from './lib/sentry.js';

// Before the app constructs, same reasoning as the env-validation ordering
// above — so a crash during app/route construction itself is still
// captured. No-ops if SENTRY_DSN isn't configured (see initSentry's doc
// comment) and can't itself throw (wrapped internally).
initSentry();

// Process-level safety net for anything that escapes Express entirely —
// a rejected promise or thrown error with no request context at all
// (e.g. during startup, in a timer, in a fire-and-forget call). Express's
// own error-handler middleware (middleware/error-handler.ts) already
// covers everything within a request/response cycle; this is the
// remaining gap FT-008 asked for ("process-level uncaughtException/
// unhandledRejection handlers").
//
// Deliberately does NOT call process.exit() here — Node's own guidance is
// that a process is in an undefined state after an uncaughtException and
// *should* restart, but actually wiring a graceful-shutdown-then-exit
// path (draining in-flight requests, etc.) is a bigger operational
// decision than this ticket's AC asks for ("exceptions are captured with
// environment/release metadata"). Flagging this as a known scope
// boundary rather than silently deciding the process-restart policy.
process.on('uncaughtException', (error) => {
  logger.error({ err: { message: error.message, stack: error.stack, name: error.name } }, 'uncaughtException');
  captureException(error);
});

process.on('unhandledRejection', (reason) => {
  const error = reason instanceof Error ? reason : new Error(String(reason));
  logger.error({ err: { message: error.message, stack: error.stack, name: error.name } }, 'unhandledRejection');
  captureException(error);
});

const app = createApp();

app.listen(env.PORT, () => {
  logger.info({ port: env.PORT, nodeEnv: env.NODE_ENV }, 'backend started');
});
