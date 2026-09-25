# Migrations

## Step 0 findings (FT-006)

Before writing anything, checked:

- **`supabase/migrations/` did not exist at all** prior to this ticket — no
  directory, no `config.toml`, nothing to diff or replace. `ls -la
  supabase/migrations/` returned "no such file or directory."
- The only pre-existing schema artifact anywhere in the repo is
  `database/database_schema.sql` — never a versioned migration, and
  already confirmed stale by the FT-001 audit (`docs/audit-findings.md`,
  Section D): it defines `child_profiles`/`assessment_sessions`/etc.,
  which match neither the live database nor this new baseline. Marked
  with a superseded banner rather than deleted (see that file).
- **The live/dev Supabase project is not purely local/throwaway.**
  `.github/workflows/ci.yml` references a real `secrets.SUPABASE_URL` /
  `secrets.SUPABASE_ANON_KEY` (used by the analyze/test job that runs on
  every push), and `docs/audit-findings.md` Section E records a direct
  `pg_policies` query against that same live project, confirming real RLS
  policies and real data on 5 tables (`parents`, `children`, `assessments`,
  `assessment_responses`, `domain_results`). This is a real, shared
  resource, not disposable.

**Given both of those**: there was nothing to destructively replace at the
file level (no committed migrations existed), but the live project's
current schema doesn't match this baseline and is actively in use. This
migration set targets a **fresh** database — satisfying the literal AC
("a fresh development database can be created entirely from committed
migrations") — and does **not** attempt to transform, cut over, or apply
against the currently-live project. Reconciling the live project's real
data to this new schema (renaming `parents`→`profiles`, backfilling
`child_caregivers`, etc.) is a distinct, higher-risk data-migration problem
that this ticket's AC does not ask for and that wasn't attempted here.
Flagging this explicitly rather than either doing it unprompted or staying
silent about the gap.

**Follow-up (same day)**: the product owner confirmed the live/dev project
is pre-launch with no real users and approved a one-time destructive reset
onto this baseline. `20260924000000_drop_legacy_schema.sql` (below) was
added specifically for that reset — see its own header comment for why it
had to be a committed migration step rather than a manual `DROP TABLE`.

**Urgent fix discovered during the live reset**: `auth.users` had a
pre-existing trigger (`on_auth_user_created`, never created by any
migration in this repo — it predated FT-006 entirely) that called
`public.handle_new_user()`, which did `INSERT INTO public.parents (...)`.
`DROP TABLE parents CASCADE` has no way to catch this — Postgres doesn't
track a plpgsql function body's hardcoded table references as a schema
dependency — so the function survived unchanged while its target table
didn't, and every new sign-up would have started failing immediately
after the reset (the trigger fires synchronously inside the `auth.users`
insert transaction). `20260925000000_fix_handle_new_user_trigger.sql`
repoints the same function at `public.profiles` (mapping `name` →
`display_name`, dropping the `email` column since `profiles` doesn't
have one — `auth.users.email` is already the source of truth) and commits
the trigger itself for the first time too, so a freshly-reset environment
reproduces this behavior instead of silently missing it.

## Migration ordering

Three migrations, applied in this order:

1. **`20260924000000_drop_legacy_schema.sql`** — `DROP TABLE IF EXISTS ...
   CASCADE` on the 5 legacy tables (`parents`, `children`, `assessments`,
   `assessment_responses`, `domain_results`) and everything attached to
   them (RLS policies, FKs). `IF EXISTS` makes this a safe no-op against
   any environment that never had these tables — including a second
   `supabase db reset` against the now-migrated live project, or a
   brand-new environment. This step exists so replaying the full migration
   history from empty always produces the same end state as the live
   reset, not a hand-run `DROP TABLE` that only happened once and isn't in
   git.
2. **`20260924000001_initial_schema.sql`** — the full baseline, in
   FK-safe dependency order:

```
profiles → children → child_caregivers → question_bank_versions →
questions → question_fallbacks → scoring_versions → assessments →
assessment_responses → domain_results → child_priorities → activities →
activity_recommendations → activity_sessions → activity_feedback →
ai_analysis_runs → user_consents → audit_logs
```

One file rather than one-per-table: this is a single cohesive baseline
being introduced all at once (nothing depends on an intermediate state),
and Supabase's own convention for a first migration is one `initial_*`
file — later schema changes should each get their own new migration file,
never edits to this one.

3. **`20260925000000_fix_handle_new_user_trigger.sql`** — repoints the
   pre-existing `on_auth_user_created` trigger/function at `profiles`
   instead of the now-dropped `parents` — see the urgent-fix note above.

## `profiles`, not `parents`

The Security & Access doc's RLS table (and the old `database_schema.sql`)
use `parents`. The TRD §5 explicitly replaces this with `profiles` +
`child_caregivers` as an intentional architecture change — a caregiver
isn't necessarily a parent (grandparent, therapist, etc. — see
`child_caregivers.relationship_type`), and the join table lets additional
caregivers be added to a child later with no schema change. Per
established precedent on this project, the TRD wins when it conflicts with
older/looser doc language. `parents` is not created by this migration.

## Deliberately excluded: `progress_tracking`, `recommendation_sessions`

Referenced by the Security & Access doc but explicitly called out in TRD
§6.20 as **not** V1 tables. Developmental progress is computed from
`assessments`/`assessment_responses`/`domain_results` (history) and
engagement from `activity_sessions`/`activity_feedback` — kept as fully
separate table groups per the TRD's design principle, with no combined or
derived table standing in for either.

## RLS: enabled, policies deferred to FT-007

Every table above has `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;` and
**zero** policies. With RLS enabled and no policies, Postgres denies all
access by default — including to owners, including via the anon/
authenticated roles, for every operation. FT-007 ("Row-Level Security &
Ownership Policies") is the ticket that adds the actual policies; this
ticket only satisfies the TRD's "RLS mandatory, even when the backend uses
a service-role client" requirement at the enablement level, without
writing policy logic that belongs to FT-007's scope. Note: a service-role
client (e.g. the backend's `supabaseAdmin`, per FT-005) bypasses RLS
entirely regardless of policies — this default-deny state only affects
requests made with the anon/authenticated keys, which is the intended
target for FT-007's forthcoming policies.

## `gen_random_uuid()`, not `uuid_generate_v4()`

`gen_random_uuid()` has been a built-in core SQL function since
PostgreSQL 13 — no extension required. Verified empirically against a
local Supabase Postgres instance as part of this ticket (see the
verification section below), not just assumed from documentation.
`pgcrypto` is enabled anyway (`CREATE EXTENSION IF NOT EXISTS pgcrypto;`)
as a defensive fallback for any older/non-Supabase Postgres this migration
might someday run against. `uuid-ossp`/`uuid_generate_v4()` (used by the
old, superseded `database/database_schema.sql`) is not used here.

## Delete-behavior deviations from the RESTRICT default

Every FK below defaults to `ON DELETE RESTRICT`. Three deviate, each
justified at its definition site in the migration file too:

1. `question_fallbacks.question_id` / `.fallback_question_id` → `CASCADE`
   — purely structural cleanup, per the ticket's own example: a fallback
   mapping row has no meaning once either side of the mapping is gone.
2. `activity_feedback.activity_session_id` → `CASCADE` — a strict 1:1
   annotation of one session (`UNIQUE` FK) with no independent identity of
   its own; same category as #1.
3. `audit_logs.actor_user_id` → `SET NULL` — an audit trail must outlive
   the actor's account by design; `RESTRICT` would make user deletion
   nearly impossible once they'd logged any action, `CASCADE` would
   destroy the history the table exists to preserve.

No FK cascades for child- or account-level deletion anywhere — that's an
explicit deliberate service-level workflow for a future ticket, not a
schema default, per the ticket's own instruction.

## `child_priorities`: "at most 3 active, no duplicate active domain"

Not expressible as a plain `UNIQUE` (it's conditional on `is_active`).
Enforced with two partial unique indexes instead:

```sql
CREATE UNIQUE INDEX child_priorities_active_rank_uidx
    ON child_priorities (child_id, rank) WHERE is_active;
CREATE UNIQUE INDEX child_priorities_active_domain_uidx
    ON child_priorities (child_id, domain_code) WHERE is_active;
```

Combined with `rank`'s `CHECK (rank IN (1,2,3))`, the first index alone
already caps active rows at 3 per child — a 4th active row would need a
4th distinct rank value, which the `CHECK` forbids — so no separate
`COUNT(*)`-based constraint or trigger is needed for the "at most 3" part.
The second index additionally prevents the same domain being active twice
under different ranks for the same child.

## CHECK constraints added beyond the ticket's literal "CHECK" callouts

Per the ticket's instruction to apply `TEXT + CHECK` consistently to every
status-like/fixed-vocabulary column, even where the plain-English
description didn't literally say "CHECK": `child_caregivers.relationship_type`
got a `CHECK (... IN ('parent','guardian','grandparent','therapist','other'))`
built from the ticket's "e.g." example list — flagged here per the
ticket's own instruction to call this out for confirmation.

## Reason/purpose/consent-type vocabularies — no broader doc check was possible

`activity_recommendations.reason_code`, `ai_analysis_runs.purpose`, and
`user_consents.consent_type` were each built to *exactly* the set given
verbatim in the FT-006 ticket text, with a note to "extend if referenced
elsewhere in the docs." A repo-wide search for the TRD, PRD, Security &
Access doc, Frontend Specification, or Feature Ticket List found **none of
them present anywhere in this repository** (consistent with
`docs/audit-findings.md`'s own finding: "Source docs not found in repo").
There was no broader document to check against, so nothing was extended
beyond the ticket's literal list — flagging the gap rather than guessing
at values that might exist in docs this repo doesn't have.

## AI provider: `ai_analysis_runs.provider`

Stored as free `text`, not a `CHECK` enum — a provider switch shouldn't
require a migration. Real value is `anthropic`, per the provider decision
confirmed directly during FT-005 (not the TRD's literal `openai` example).
The ticket referenced `claude/decisions/ai-provider.md` as the source for
this — that file does not exist anywhere in this repo; the actual
authorization for "anthropic" traces to the FT-005 PR description instead
(itself sourced from a direct confirmation during that ticket, not a
committed decision doc — see that PR for the fuller chain of custody on
this decision).
