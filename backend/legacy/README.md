# Legacy pre-FT-004 backend code

Moved here (not deleted) by FT-005 rather than left in `src/`, where it would
otherwise collide by filename with the new TypeScript skeleton and confuse
which `app.js`/`auth.js` is actually running.

**Why this wasn't repaired in place instead of scaffolding fresh:** it's
plain JavaScript (FT-005 requires TypeScript), a flat `routes/`/`services/`/
`middleware/` layout (not the TRD §4 per-domain `modules/` structure), used
`joi` instead of `zod`, had no `config/`/`lib/`/`repositories/` layers at
all, and didn't boot — `app.js` required `./routes/auth`, `./middleware/errorHandler`,
`./routes/assessments`, `./routes/activities`, and `./routes/progress`, none
of which exist on disk (confirmed via `node -e "require('./src/app.js')"`,
which threw `Cannot find module './routes/auth'` immediately). See
`docs/audit-findings.md` Section C for the full pre-existing writeup.

**Known correctness issues in this code, if a future ticket wants to mine
it for reference:**
- `routes/children.js` queries a `child_profiles` table — the live schema
  (confirmed via Table Editor, see `docs/audit-findings.md` Section D) is
  actually `children`. Querying against this code as-is would fail against
  the real database.
- `middleware_auth.js` (originally `middleware/auth.js`) hand-verifies the
  token via `supabase.auth.getUser(token)`, which is actually the *correct*
  approach and matches what FT-005's new `middleware/auth.ts` does — this
  part is fine as a reference. Its `checkChildOwnership` helper, however,
  does a flat `.eq('id', childId).eq('user_id', userId)` match with no
  `child_caregivers` join-table support, which `docs/audit-findings.md`
  Section E flags as a Blocker-severity gap versus the intended ownership
  model.
- `services/aiService.js` calls OpenAI (`gpt-4`, hardcoded in 3 places), not
  Anthropic — this project's confirmed AI provider (see `docs/audit-findings.md`
  Open Question 4 and `.env.example`'s `ANTHROPIC_API_KEY`). Not reachable
  today (never wired into a router even before this move) and would need a
  provider rewrite regardless of reachability.

Nothing in this directory is imported by `src/` or referenced by
`package.json`'s scripts.
