-- FT-006: Database Schema & Migration Baseline
--
-- Builds the full MVP relational model per TRD §5-7. This is the first
-- committed migration in this repo — there was nothing under
-- supabase/migrations/ to diff against or replace (see
-- supabase/migrations/README.md for the full Step 0 findings). It targets
-- a FRESH database; it does not attempt to transform or migrate the
-- currently-live dev Supabase project's existing 5-table schema
-- (parents/children/assessments/assessment_responses/domain_results) —
-- see the README's "Relationship to the currently-live database" section
-- for why that's explicitly out of scope here.
--
-- Naming authority: per established precedent, the TRD wins over the
-- Security & Access doc's older/looser table names. This migration does
-- NOT create parents, progress_tracking, or recommendation_sessions
-- tables — see README.
--
-- RLS: enabled on every table below with ZERO policies attached
-- (default-deny, including for owners) — FT-007 is the ticket that adds
-- the actual policies. This satisfies "RLS mandatory... even when the
-- backend uses a service-role client" without duplicating FT-007's scope.
--
-- Delete behavior: ON DELETE RESTRICT is the default on every FK below.
-- Three deviations, each justified individually where the FK is defined:
--   1. question_fallbacks.question_id / .fallback_question_id -> CASCADE
--   2. activity_feedback.activity_session_id -> CASCADE
--   3. audit_logs.actor_user_id -> SET NULL
-- No CASCADE is used anywhere for child/account-level deletion — that's a
-- deliberate service-level workflow for a future ticket, not a schema
-- default (per the ticket's explicit instruction).

-- ── Extension check ──────────────────────────────────────────────────────
-- gen_random_uuid() has been a built-in core SQL function since
-- PostgreSQL 13 (no extension required) — Supabase's managed Postgres is
-- v15+, so it's available natively. Verified empirically against a fresh
-- local instance as part of this ticket's verification (see README) rather
-- than assumed. pgcrypto is enabled anyway as a defensive fallback in case
-- this migration is ever run against an older/non-Supabase Postgres where
-- gen_random_uuid() isn't built in yet.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ── Shared domain-code vocabulary ────────────────────────────────────────
-- The same 8-domain set is CHECK-constrained on questions.domain_code,
-- domain_results.domain_code, child_priorities.domain_code,
-- activities.domain_code, and activity_recommendations.domain_code — kept
-- as a literal repeated CHECK per column (not a lookup table) per the
-- ticket's "prefer TEXT + CHECK over ENUM" instruction, applied
-- consistently across every one of these five columns.

-- ============================================================================
-- 1. profiles — one row per caregiver, PK/FK = auth.users.id
-- ============================================================================
CREATE TABLE profiles (
    user_id             uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE RESTRICT,
    display_name        text NOT NULL,
    country_code        text,
    locale              text,
    timezone            text,
    onboarding_complete boolean NOT NULL DEFAULT false,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 2. children
-- ============================================================================
CREATE TABLE children (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    preferred_name      text NOT NULL,
    date_of_birth       date NOT NULL,
    gender              text,
    premature_birth     boolean,
    gestational_weeks   smallint,
    is_active           boolean NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE children ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 3. child_caregivers
-- ============================================================================
CREATE TABLE child_caregivers (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id            uuid NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    user_id             uuid NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    -- Not explicitly given as a fixed enum by the ticket text beyond "e.g."
    -- examples, but the ticket says to CHECK against this set — added.
    relationship_type   text NOT NULL CHECK (relationship_type IN ('parent','guardian','grandparent','therapist','other')),
    role                text NOT NULL CHECK (role IN ('owner','editor','viewer')),
    is_active           boolean NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now(),
    UNIQUE (child_id, user_id)
);

CREATE INDEX child_caregivers_user_active_idx ON child_caregivers (user_id, is_active);
CREATE INDEX child_caregivers_child_active_idx ON child_caregivers (child_id, is_active);

ALTER TABLE child_caregivers ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 4. question_bank_versions
-- ============================================================================
CREATE TABLE question_bank_versions (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    version         text UNIQUE NOT NULL,
    description     text,
    status          text NOT NULL CHECK (status IN ('draft','active','retired')),
    published_at    timestamptz,
    created_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE question_bank_versions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 5. questions
-- ============================================================================
CREATE TABLE questions (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    bank_version_id     uuid NOT NULL REFERENCES question_bank_versions(id) ON DELETE RESTRICT,
    question_key        text NOT NULL,
    domain_code         text NOT NULL CHECK (domain_code IN (
                            'attention_play','cognitive','daily_living','fine_motor',
                            'gross_motor','sensory','social_emotional','communication'
                        )),
    prompt              text NOT NULL,
    age_min_months      smallint NOT NULL,
    age_max_months      smallint NOT NULL,
    slot_key            text NOT NULL,
    fallback_level      smallint NOT NULL DEFAULT 0,
    sort_order          smallint NOT NULL,
    is_active           boolean NOT NULL DEFAULT true,
    CHECK (age_min_months <= age_max_months),
    CHECK (fallback_level >= 0)
);

ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 6. question_fallbacks
--
-- DELETE DEVIATION (both FKs -> CASCADE): purely structural cleanup, per
-- the ticket's own example. A fallback-mapping row has no independent
-- meaning once either side of the mapping (the triggering question or the
-- fallback target question) is gone.
-- ============================================================================
CREATE TABLE question_fallbacks (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id             uuid NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    fallback_question_id    uuid NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    trigger_score           smallint NOT NULL,
    priority                smallint NOT NULL
);

ALTER TABLE question_fallbacks ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 7. scoring_versions
-- ============================================================================
CREATE TABLE scoring_versions (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    version         text UNIQUE NOT NULL,
    description     text,
    rules_json      jsonb NOT NULL,
    status          text NOT NULL CHECK (status IN ('draft','active','retired')),
    created_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE scoring_versions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 8. assessments
--
-- question_bank_version_id / scoring_version_id are NOT NULL FKs (every
-- assessment always has both, from creation) and are made immutable
-- post-submission by the trigger below, not just by application
-- discipline — see trg_assessments_immutable_versions.
-- ============================================================================
CREATE TABLE assessments (
    id                          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                    uuid NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    started_by_user_id          uuid NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    question_bank_version_id    uuid NOT NULL REFERENCES question_bank_versions(id) ON DELETE RESTRICT,
    scoring_version_id          uuid NOT NULL REFERENCES scoring_versions(id) ON DELETE RESTRICT,
    status                      text NOT NULL CHECK (status IN ('in_progress','submitted','scored','abandoned')),
    started_at                  timestamptz NOT NULL DEFAULT now(),
    submitted_at                timestamptz,
    completed_at                timestamptz
);

CREATE INDEX assessments_child_started_idx ON assessments (child_id, started_at DESC);

ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;

-- Immutability enforcement: a trigger, not just a documented app-layer
-- invariant. Chosen over documentation-only because it holds regardless of
-- which code path writes to this table (a future admin tool, a bulk
-- backfill script, a bug in application code) — the AC says these
-- references must be immutable, not "usually respected by the app."
CREATE OR REPLACE FUNCTION prevent_assessment_version_change()
RETURNS trigger AS $$
BEGIN
    IF OLD.submitted_at IS NOT NULL THEN
        IF NEW.question_bank_version_id IS DISTINCT FROM OLD.question_bank_version_id
           OR NEW.scoring_version_id IS DISTINCT FROM OLD.scoring_version_id THEN
            RAISE EXCEPTION
                'assessments.question_bank_version_id and scoring_version_id are immutable once submitted (assessment %)',
                OLD.id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_assessments_immutable_versions
    BEFORE UPDATE ON assessments
    FOR EACH ROW
    EXECUTE FUNCTION prevent_assessment_version_change();

-- ============================================================================
-- 9. assessment_responses
-- ============================================================================
CREATE TABLE assessment_responses (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id           uuid NOT NULL REFERENCES assessments(id) ON DELETE RESTRICT,
    question_id             uuid NOT NULL REFERENCES questions(id) ON DELETE RESTRICT,
    slot_key                text NOT NULL,
    score                   smallint NOT NULL CHECK (score IN (0,1,2)),
    answered_by_user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    answered_at             timestamptz NOT NULL DEFAULT now(),
    UNIQUE (assessment_id, question_id)
);

CREATE INDEX assessment_responses_assessment_idx ON assessment_responses (assessment_id);

ALTER TABLE assessment_responses ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 10. domain_results
-- ============================================================================
CREATE TABLE domain_results (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id   uuid NOT NULL REFERENCES assessments(id) ON DELETE RESTRICT,
    domain_code     text NOT NULL CHECK (domain_code IN (
                        'attention_play','cognitive','daily_living','fine_motor',
                        'gross_motor','sensory','social_emotional','communication'
                    )),
    raw_score       numeric NOT NULL,
    max_score       numeric NOT NULL CHECK (max_score > 0),
    percentage      numeric CHECK (percentage IS NULL OR (percentage >= 0 AND percentage <= 100)),
    display_level   text,
    explanation     text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    UNIQUE (assessment_id, domain_code)
);

CREATE INDEX domain_results_assessment_idx ON domain_results (assessment_id);
CREATE INDEX domain_results_domain_code_idx ON domain_results (domain_code);

ALTER TABLE domain_results ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 11. child_priorities
--
-- "At most 3 active rows per child, ranks 1-3, no duplicate active domain"
-- can't be a plain UNIQUE (it's conditional on is_active) — enforced via
-- two partial unique indexes instead:
--   - one active row per (child_id, rank): together with the CHECK
--     restricting rank to {1,2,3}, this makes 3 the hard ceiling on active
--     rows per child (a 4th active row would need a 4th distinct rank
--     value, which the CHECK forbids) — so no separate COUNT-based
--     constraint/trigger is needed for the "at most 3" part.
--   - one active row per (child_id, domain_code): prevents the same
--     domain being active twice under different ranks for the same child.
-- ============================================================================
CREATE TABLE child_priorities (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id        uuid NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    domain_code     text NOT NULL CHECK (domain_code IN (
                        'attention_play','cognitive','daily_living','fine_motor',
                        'gross_motor','sensory','social_emotional','communication'
                    )),
    rank            smallint NOT NULL CHECK (rank IN (1,2,3)),
    source          text NOT NULL CHECK (source IN ('system_suggested','caregiver_selected')),
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    ended_at        timestamptz
);

CREATE UNIQUE INDEX child_priorities_active_rank_uidx ON child_priorities (child_id, rank) WHERE is_active;
CREATE UNIQUE INDEX child_priorities_active_domain_uidx ON child_priorities (child_id, domain_code) WHERE is_active;
CREATE INDEX child_priorities_child_active_rank_idx ON child_priorities (child_id, is_active, rank);

ALTER TABLE child_priorities ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 12. activities
-- ============================================================================
CREATE TABLE activities (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_key        text NOT NULL,
    version             integer NOT NULL,
    title               text NOT NULL,
    domain_code         text NOT NULL CHECK (domain_code IN (
                            'attention_play','cognitive','daily_living','fine_motor',
                            'gross_motor','sensory','social_emotional','communication'
                        )),
    target_skill        text NOT NULL,
    age_min_months      smallint NOT NULL,
    age_max_months      smallint NOT NULL,
    difficulty          text NOT NULL CHECK (difficulty IN ('easy','moderate','challenging')),
    duration_minutes    smallint NOT NULL CHECK (duration_minutes > 0),
    materials           jsonb NOT NULL,
    steps               jsonb NOT NULL,
    benefits            text NOT NULL,
    safety_notes        text,
    evidence_notes      text,
    status              text NOT NULL CHECK (status IN ('draft','published','retired')),
    created_at          timestamptz NOT NULL DEFAULT now(),
    UNIQUE (activity_key, version),
    CHECK (age_min_months <= age_max_months)
);

CREATE INDEX activities_domain_age_status_idx ON activities (domain_code, age_min_months, age_max_months, status);

ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 13. activity_recommendations
-- ============================================================================
CREATE TABLE activity_recommendations (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                uuid NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    activity_id             uuid NOT NULL REFERENCES activities(id) ON DELETE RESTRICT,
    assessment_id           uuid REFERENCES assessments(id) ON DELETE RESTRICT,
    domain_code             text NOT NULL CHECK (domain_code IN (
                                'attention_play','cognitive','daily_living','fine_motor',
                                'gross_motor','sensory','social_emotional','communication'
                            )),
    -- Only these 3 reason codes are given anywhere in the ticket text
    -- available to this migration; the planning docs (TRD/Security &
    -- Access/Frontend Spec) that might reference additional codes aren't
    -- present anywhere in this repo (confirmed via repo-wide search) — see
    -- README's Step 0 findings. Built to exactly the set given, flagged
    -- rather than guessed at.
    reason_code             text NOT NULL CHECK (reason_code IN ('priority_domain','low_score','continuation')),
    reason_text             text,
    rank_score              numeric,
    source                  text NOT NULL CHECK (source IN ('rules','ai_ranked','manual')),
    status                  text NOT NULL CHECK (status IN ('active','dismissed','completed','expired')),
    recommended_for_date    date,
    created_at              timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX activity_recommendations_child_status_idx ON activity_recommendations (child_id, status, created_at DESC);

ALTER TABLE activity_recommendations ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 14. activity_sessions
-- ============================================================================
CREATE TABLE activity_sessions (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                uuid NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    activity_id             uuid NOT NULL REFERENCES activities(id) ON DELETE RESTRICT,
    recommendation_id       uuid REFERENCES activity_recommendations(id) ON DELETE RESTRICT,
    performed_by_user_id    uuid NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    status                  text NOT NULL CHECK (status IN ('started','completed','skipped','abandoned')),
    started_at              timestamptz,
    completed_at            timestamptz
);

CREATE INDEX activity_sessions_child_completed_idx ON activity_sessions (child_id, completed_at DESC);

ALTER TABLE activity_sessions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 15. activity_feedback
--
-- DELETE DEVIATION (-> CASCADE): a 1:1 annotation of exactly one session
-- (UNIQUE FK) with no independent meaning of its own — purely structural
-- cleanup, the same category as question_fallbacks above, not a
-- child/account-deletion cascade.
-- ============================================================================
CREATE TABLE activity_feedback (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_session_id     uuid NOT NULL UNIQUE REFERENCES activity_sessions(id) ON DELETE CASCADE,
    difficulty              text CHECK (difficulty IS NULL OR difficulty IN ('too_easy','just_right','challenging','too_difficult')),
    engagement              text CHECK (engagement IS NULL OR engagement IN ('low','moderate','high')),
    caregiver_note          text,
    created_at              timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE activity_feedback ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 16. ai_analysis_runs
-- ============================================================================
CREATE TABLE ai_analysis_runs (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id        uuid NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    assessment_id   uuid REFERENCES assessments(id) ON DELETE RESTRICT,
    -- Same "no other docs available to check" caveat as reason_code above.
    purpose         text NOT NULL CHECK (purpose IN ('assessment_summary','recommendation_ranking','explanation')),
    -- Real value is 'anthropic' per the confirmed provider decision (see
    -- backend FT-005's PR description) — stored as free text, not a CHECK
    -- enum, since a provider switch shouldn't require a migration.
    provider        text NOT NULL,
    model           text NOT NULL,
    prompt_version  text NOT NULL,
    status          text NOT NULL CHECK (status IN ('queued','completed','failed','blocked')),
    output_json     jsonb,
    error_code      text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    completed_at    timestamptz
);

CREATE INDEX ai_analysis_runs_assessment_purpose_idx ON ai_analysis_runs (assessment_id, purpose, created_at DESC);

ALTER TABLE ai_analysis_runs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 17. user_consents
-- ============================================================================
CREATE TABLE user_consents (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             uuid NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    child_id            uuid REFERENCES children(id) ON DELETE RESTRICT,
    -- Same "no other docs available to check" caveat as reason_code above.
    consent_type        text NOT NULL CHECK (consent_type IN ('terms','privacy','child_data','ai_processing')),
    document_version    text NOT NULL,
    accepted_at         timestamptz NOT NULL DEFAULT now(),
    revoked_at          timestamptz
);

ALTER TABLE user_consents ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 18. audit_logs
--
-- DELETE DEVIATION (actor_user_id -> SET NULL): an audit trail must
-- outlive the actor's account by design (a deleted user's past actions
-- are still real history that compliance/support may need), and the
-- column is already nullable for system-initiated jobs — RESTRICT here
-- would make user deletion effectively impossible once they'd performed
-- any logged action; CASCADE would destroy the audit history it exists to
-- preserve. SET NULL is the only one of the three that fits the table's
-- actual purpose.
-- ============================================================================
CREATE TABLE audit_logs (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id   uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    action          text NOT NULL,
    entity_type     text NOT NULL,
    entity_id       uuid,
    metadata        jsonb,
    created_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
