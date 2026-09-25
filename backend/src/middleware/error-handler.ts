import type { NextFunction, Request, Response } from 'express';

import { logger } from '../config/logger.js';
import { ApiError } from '../lib/api-error.js';
import { sendError } from '../lib/response.js';
import { captureException } from '../lib/sentry.js';

const GENERIC_SERVER_MESSAGE = 'Something went wrong on our side. Please try again.';

/**
 * Last middleware in the chain — the 4-argument signature is what makes
 * Express recognize this as error-handling middleware. Catches anything
 * thrown or passed to `next(err)` anywhere upstream that wasn't already
 * handled as a typed 4xx (Express 5 auto-forwards rejected promises from
 * async route handlers here, so a route doesn't need its own try/catch
 * just to reach this).
 *
 * A thrown ApiError (see lib/api-error.ts) is treated as an intentional,
 * already-safe 4xx/5xx and its fields are used directly. Anything else —
 * a genuine bug, a rejected promise from a dependency, a raw Error — is
 * logged in full server-side (message, stack, request ID, route, method)
 * and turned into the fixed, generic 500 envelope. The stack trace never
 * appears in the response, only in the log line.
 */
export function errorHandler(err: unknown, req: Request, res: Response, _next: NextFunction): void {
  const requestId = req.requestId ?? 'unknown';

  if (err instanceof ApiError) {
    logger.warn(
      {
        requestId,
        route: req.originalUrl,
        method: req.method,
        statusCode: err.statusCode,
        code: err.code,
      },
      'handled API error',
    );
    sendError(res, err.statusCode, {
      code: err.code,
      userMessage: err.userMessage,
      requestId,
      fieldErrors: err.fieldErrors,
    });
    return;
  }

  const error = err instanceof Error ? err : new Error(String(err));
  logger.error(
    {
      requestId,
      route: req.originalUrl,
      method: req.method,
      err: { message: error.message, stack: error.stack, name: error.name },
    },
    'unhandled exception',
  );
  // FT-008: only truly unhandled exceptions reach Sentry — a thrown
  // ApiError above is an intentional, already-safe 4xx/5xx and returns
  // before this point, matching "backend exceptions are captured" (not
  // every handled 4xx).
  captureException(error, { requestId, route: req.originalUrl, method: req.method });

  sendError(res, 500, {
    code: 'INTERNAL_ERROR',
    userMessage: GENERIC_SERVER_MESSAGE,
    requestId,
  });
}
