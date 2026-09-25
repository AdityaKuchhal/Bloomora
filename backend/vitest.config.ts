import { defineConfig } from 'vitest/config';

// config/env.ts validates process.env eagerly at import time (see its own
// comment on why) — every test file that imports app.ts/server.ts
// transitively imports it, so these need to be in place before Vitest
// loads any test module, not inside a test file's own body (ESM imports
// are hoisted above any process.env assignment a test file could make).
export default defineConfig({
  test: {
    environment: 'node',
    env: {
      NODE_ENV: 'test',
      SUPABASE_URL: 'https://example.supabase.co',
      SUPABASE_SERVICE_KEY: 'test-service-key',
      ANTHROPIC_API_KEY: 'test-anthropic-key',
      CORS_ALLOWED_ORIGINS: '',
    },
  },
});
