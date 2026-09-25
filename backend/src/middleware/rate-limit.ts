import rateLimit from 'express-rate-limit';

import { env } from '../config/env.js';
import { sendError } from '../lib/response.js';

export interface RateLimitOverrides {
  windowMs?: number;
  max?: number;
}

/**
 * Factory rather than a single exported instance, so tests can build one
 * with a tiny window/max without mutating process.env (env is parsed once,
 * eagerly, at module-load time — see config/env.ts) or needing a real
 * 15-minute wait. Production (app.ts) calls this with no overrides, which
 * falls through to RATE_LIMIT_WINDOW_MS/RATE_LIMIT_MAX_REQUESTS from env,
 * exactly as the ticket specifies.
 *
 * `Retry-After` is set explicitly in the handler (in addition to whatever
 * express-rate-limit's own `standardHeaders` may add) so it's guaranteed
 * present regardless of library defaults — this is exactly what FT-004's
 * RateLimitedError.retryAfterSeconds already expects to parse.
 */
export function createRateLimiter(overrides: RateLimitOverrides = {}) {
  const windowMs = overrides.windowMs ?? env.RATE_LIMIT_WINDOW_MS;
  const max = overrides.max ?? env.RATE_LIMIT_MAX_REQUESTS;

  return rateLimit({
    windowMs,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    handler: (req, res) => {
      res.setHeader('Retry-After', String(Math.ceil(windowMs / 1000)));
      sendError(res, 429, {
        code: 'RATE_LIMITED',
        userMessage: 'Too many requests. Please wait and try again.',
        requestId: req.requestId,
      });
    },
  });
}
