-- FT-006 follow-up: drop the pre-baseline live schema as a committed
-- migration step, not an out-of-band manual DROP.
--
-- The live/dev Supabase project (the one CI's secrets.SUPABASE_URL points
-- at) currently has 5 tables — parents, children, assessments,
-- assessment_responses, domain_results — created ad hoc (never from a
-- committed migration; see README's Step 0 findings) and confirmed stale
-- relative to the TRD (no versioning, a parents table instead of
-- profiles/child_caregivers). Approved by the product owner as a
-- deliberate, one-time destructive reset: the project is pre-launch with
-- no real users.
--
-- This runs BEFORE 20260924000001_initial_schema.sql (lexically/
-- numerically first) so replaying the full migration history from empty —
-- supabase db reset, or standing up any new environment — always produces
-- the exact same end state as the live reset: no trace of the old schema,
-- ever, not just "currently absent because someone remembered to drop it
-- once."
--
-- CASCADE drops each table's dependent objects along with it, including
-- any RLS policies attached (the audit-confirmed policies on these 5
-- tables were all `cmd=ALL, roles={public}` — see docs/audit-findings.md
-- Section E) and any FKs pointing at them. IF EXISTS makes this safe to
-- replay against an environment that never had these tables at all (e.g.
-- a brand-new project, or a second run of `supabase db reset`).
DROP TABLE IF EXISTS domain_results CASCADE;
DROP TABLE IF EXISTS assessment_responses CASCADE;
DROP TABLE IF EXISTS assessments CASCADE;
DROP TABLE IF EXISTS children CASCADE;
DROP TABLE IF EXISTS parents CASCADE;
