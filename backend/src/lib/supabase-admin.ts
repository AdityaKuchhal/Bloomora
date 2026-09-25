import { createClient } from '@supabase/supabase-js';

import { env } from '../config/env.js';

/**
 * The trusted, RLS-bypassing server client (Security & Access §6.4
 * "Backend trust boundary"). Every privileged endpoint built on top of
 * this must verify identity (middleware/auth.ts, already wired) AND
 * ownership of the specific resource being touched — ownership checks are
 * NOT provided here; they differ per resource and belong to each domain
 * module's own ticket (e.g. FT-018 for children).
 */
export const supabaseAdmin = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});
