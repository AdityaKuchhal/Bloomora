import { describe, expect, it } from 'vitest';

import { EnvValidationError, parseEnv } from '../../src/config/env.js';

const VALID_ENV = {
  NODE_ENV: 'development',
  SUPABASE_URL: 'https://example.supabase.co',
  SUPABASE_SERVICE_KEY: 'service-key',
  ANTHROPIC_API_KEY: 'anthropic-key',
};

describe('parseEnv', () => {
  it('accepts a fully-populated valid environment', () => {
    const result = parseEnv(VALID_ENV);
    expect(result.SUPABASE_URL).toBe('https://example.supabase.co');
    expect(result.NODE_ENV).toBe('development');
  });

  it('applies documented defaults for optional/should-have vars', () => {
    const result = parseEnv(VALID_ENV);
    expect(result.PORT).toBe(3000);
    expect(result.LOG_LEVEL).toBe('info');
    expect(result.RATE_LIMIT_WINDOW_MS).toBe(900_000);
    expect(result.RATE_LIMIT_MAX_REQUESTS).toBe(100);
    expect(result.CORS_ALLOWED_ORIGINS).toBe('');
  });

  it.each(['NODE_ENV', 'SUPABASE_URL', 'SUPABASE_SERVICE_KEY', 'ANTHROPIC_API_KEY'])(
    'throws EnvValidationError naming %s when it is missing',
    (missingKey) => {
      const broken = { ...VALID_ENV };
      delete (broken as Record<string, unknown>)[missingKey];

      let caught: unknown;
      try {
        parseEnv(broken);
      } catch (err) {
        caught = err;
      }

      expect(caught).toBeInstanceOf(EnvValidationError);
      const error = caught as EnvValidationError;
      expect(error.issues.some((issue) => issue.startsWith(`${missingKey}:`))).toBe(true);
    },
  );

  it('rejects an invalid NODE_ENV value rather than silently accepting it', () => {
    expect(() => parseEnv({ ...VALID_ENV, NODE_ENV: 'not-a-real-env' })).toThrow(
      EnvValidationError,
    );
  });

  it('the thrown error message names every missing variable, not a vague generic failure', () => {
    let caught: unknown;
    try {
      parseEnv({ NODE_ENV: 'development' });
    } catch (err) {
      caught = err;
    }
    expect(caught).toBeInstanceOf(EnvValidationError);
    const message = (caught as EnvValidationError).message;
    expect(message).toContain('SUPABASE_URL');
    expect(message).toContain('SUPABASE_SERVICE_KEY');
    expect(message).toContain('ANTHROPIC_API_KEY');
  });
});
