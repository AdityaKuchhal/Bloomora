// Real subprocess boot test — proves the actual `npm start`-equivalent
// process (not just the parseEnv() function in isolation) exits non-zero
// with a clear, readable message when a required env var is missing. This
// is the literal "process fails to start" checklist item, not a proxy for
// it.
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { describe, expect, it } from 'vitest';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const serverEntry = path.join(__dirname, '../../src/server.ts');
const tsxBin = path.join(__dirname, '../../node_modules/.bin/tsx');

describe('process boot (real subprocess)', () => {
  it('exits non-zero and names the missing variable when SUPABASE_SERVICE_KEY is unset', () => {
    const result = spawnSync(tsxBin, [serverEntry], {
      env: {
        ...process.env,
        NODE_ENV: 'development',
        SUPABASE_URL: 'https://example.supabase.co',
        ANTHROPIC_API_KEY: 'fake-anthropic-key',
        SUPABASE_SERVICE_KEY: '',
      },
      encoding: 'utf-8',
      timeout: 15_000,
    });

    expect(result.status).not.toBe(0);
    expect(result.stderr).toContain('SUPABASE_SERVICE_KEY');
    expect(result.stderr).toContain('EnvValidationError');
  }, 20_000);

  it('boots successfully (exit code null = still running / killed by us) with a complete environment', () => {
    const result = spawnSync(tsxBin, [serverEntry], {
      env: {
        ...process.env,
        NODE_ENV: 'development',
        SUPABASE_URL: 'https://example.supabase.co',
        SUPABASE_SERVICE_KEY: 'fake-service-key',
        ANTHROPIC_API_KEY: 'fake-anthropic-key',
        PORT: '4124',
      },
      encoding: 'utf-8',
      timeout: 2_500, // it never exits on its own if healthy — this is the assertion
    });

    // spawnSync times out and force-kills the process (exit status 143 =
    // 128+SIGTERM) rather than the process exiting on its own — that's the
    // point: a healthy server never exits by itself.
    expect(result.error).toMatchObject({ code: 'ETIMEDOUT' });
    expect(result.status).toBe(143);
    expect(result.stdout).toContain('backend started');
  }, 10_000);
});
