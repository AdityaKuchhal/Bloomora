import { config as loadDotenv } from 'dotenv';
import { z } from 'zod';

loadDotenv();

// Var names here are pulled EXACTLY from the committed backend/.env.example
// (FT-001), not from the TRD/ticket's literal text — the two disagree in
// three places, and .env.example is the authoritative source per FT-005's
// Step 0 instructions:
//   - SUPABASE_SERVICE_KEY, not SUPABASE_SERVICE_ROLE_KEY (the existing
//     legacy code already reads this name — see legacy/middleware_auth.js).
//   - ANTHROPIC_API_KEY, not OPENAI_API_KEY/OPENAI_MODEL/OPENAI_PROMPT_VERSION
//     — this project's confirmed AI provider is Anthropic (see
//     docs/audit-findings.md, Open Question 4, resolved). OPENAI_MODEL and
//     OPENAI_PROMPT_VERSION-equivalent vars for Anthropic don't exist yet
//     and are explicitly deferred to FT-037 (the AI module ticket) rather
//     than invented here.
//   - RATE_LIMIT_MAX_REQUESTS, not RATE_LIMIT_MAX.
export const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production', 'test']),
  PORT: z.coerce.number().int().positive().default(3000),

  SUPABASE_URL: z.string().min(1, 'SUPABASE_URL is required'),
  SUPABASE_SERVICE_KEY: z.string().min(1, 'SUPABASE_SERVICE_KEY is required'),

  ANTHROPIC_API_KEY: z.string().min(1, 'ANTHROPIC_API_KEY is required'),

  // Optional/should-have, with sensible defaults — see ticket's env
  // validation section.
  LOG_LEVEL: z
    .enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent'])
    .default('info'),
  SENTRY_DSN: z.string().optional(),
  RATE_LIMIT_WINDOW_MS: z.coerce.number().int().positive().default(900_000),
  RATE_LIMIT_MAX_REQUESTS: z.coerce.number().int().positive().default(100),

  // V1 is mobile-only — default to "no origins allowed" (empty string,
  // parsed to []) rather than a permissive default. A comma-separated list
  // of allowed origins, e.g. "https://admin.bloomora.app,https://staging...".
  CORS_ALLOWED_ORIGINS: z.string().default(''),

  // Legacy var from the pre-FT-005 app.js (see legacy/app.js) — kept
  // optional so its presence in a real .env doesn't fail validation, but
  // NOT used to drive CORS in the new app.ts; CORS_ALLOWED_ORIGINS is the
  // only mechanism per this ticket's explicit instruction.
  FRONTEND_URL: z.string().optional(),

  // Present in .env.example but not read by any server-side code yet
  // (the Flutter app is the only current SUPABASE_ANON_KEY consumer) —
  // optional so its presence doesn't fail validation.
  SUPABASE_ANON_KEY: z.string().optional(),
});

export type Env = z.infer<typeof envSchema>;

export class EnvValidationError extends Error {
  readonly issues: string[];

  constructor(issues: string[]) {
    super(
      `Invalid environment configuration — the server will not start until these are fixed:\n${issues
        .map((issue) => `  - ${issue}`)
        .join('\n')}`,
    );
    this.name = 'EnvValidationError';
    this.issues = issues;
  }
}

/**
 * Pure — takes an explicit source instead of always reading `process.env`
 * so it's unit-testable with a fabricated env object. Throws
 * (`EnvValidationError`, listing every missing/invalid var by name) rather
 * than calling `process.exit` itself: an uncaught throw at module-load
 * time already crashes the process with a non-zero exit code and a clear,
 * readable stderr message — see server.ts — while keeping this function
 * itself safe to call from a test without killing the test runner.
 */
export function parseEnv(source: NodeJS.ProcessEnv = process.env): Env {
  const result = envSchema.safeParse(source);
  if (!result.success) {
    const issues = result.error.issues.map((issue) => {
      const path = issue.path.length > 0 ? issue.path.join('.') : '(root)';
      return `${path}: ${issue.message}`;
    });
    throw new EnvValidationError(issues);
  }
  return result.data;
}

// Runs at import time — the first module (directly or transitively) to
// import this file triggers validation before anything else in the app
// (including Express itself) constructs. See server.ts's import order.
export const env = parseEnv();
