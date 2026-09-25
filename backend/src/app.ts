import cors from 'cors';
import express, { type Express } from 'express';
import helmet from 'helmet';

import { env } from './config/env.js';
import { logger } from './config/logger.js';
import { errorHandler } from './middleware/error-handler.js';
import { createRateLimiter, type RateLimitOverrides } from './middleware/rate-limit.js';
import { requestIdMiddleware } from './middleware/request-id.js';
import { sendError } from './lib/response.js';
import { v1Router } from './modules/v1-router.js';

export interface CreateAppOptions {
  /** Test seam — see middleware/rate-limit.ts. Unused in production. */
  rateLimitOverrides?: RateLimitOverrides;
  /**
   * Test seam — overrides env.CORS_ALLOWED_ORIGINS's parsed origin list
   * without needing to mutate global env (which is validated once, eagerly,
   * at module load — see config/env.ts). Unused in production, where the
   * env-driven default applies.
   */
  corsAllowedOrigins?: string[];
}

/**
 * Builds the Express app without binding a port — server.ts does that.
 * Kept separate so tests (supertest) and any future multi-instance setup
 * can exercise the app directly.
 */
export function createApp(options: CreateAppOptions = {}): Express {
  const app = express();

  // Earliest middleware in the chain, before rate-limit and before auth —
  // every downstream handler, the logger, and the error handler reference
  // the same req.requestId.
  app.use(requestIdMiddleware);

  const allowedOrigins =
    options.corsAllowedOrigins ??
    env.CORS_ALLOWED_ORIGINS.split(',')
      .map((origin) => origin.trim())
      .filter(Boolean);
  // V1 is mobile-only (TRD §10.2) — default to allowing no origins at all
  // (origin: false — cors() then omits Access-Control-Allow-Origin from
  // every response, so a browser blocks the cross-origin read) rather than
  // a permissive wildcard, until a web/admin client needs one.
  app.use(
    cors({
      origin: allowedOrigins.length > 0 ? allowedOrigins : false,
      credentials: true,
    }),
  );

  app.use(helmet());
  app.use(express.json({ limit: '1mb' }));

  // Structured per-request log line: request ID, route, status, timestamp
  // (pino adds this automatically), a safe user ID reference (Supabase
  // user id only, never an email/token), and duration — Security & Access
  // §6.2. Registered after body parsing but before any route so it always
  // fires via `res.on('finish', ...)` regardless of which handler runs.
  app.use((req, res, next) => {
    const startedAt = Date.now();
    res.on('finish', () => {
      logger.info(
        {
          requestId: req.requestId,
          method: req.method,
          route: req.originalUrl,
          statusCode: res.statusCode,
          durationMs: Date.now() - startedAt,
          userId: req.user?.id,
        },
        'request completed',
      );
    });
    next();
  });

  // Unauthenticated, no rate limit, no Supabase dependency — Railway needs
  // this to answer fast and reliably even if a downstream dependency is
  // degraded. Registered before the rate limiter below and not versioned
  // under /v1.
  app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok' });
  });

  app.use(createRateLimiter(options.rateLimitOverrides));

  app.use('/v1', v1Router);

  // Anything that fell through every route above — unknown path or a
  // deprecated one — is a 404 in the standard envelope, not a raw Express
  // default page.
  app.use((req, res) => {
    sendError(res, 404, {
      code: 'NOT_FOUND',
      userMessage: 'This item is no longer available.',
      requestId: req.requestId,
    });
  });

  // Last middleware in the chain.
  app.use(errorHandler);

  return app;
}
