-- FT-007: Row-Level Security & Ownership Policies
--
-- Governing rule (established in FT-004/FT-005, reaffirmed here): writes
-- go through the Node/Express API, never direct client writes — the
-- backend's supabaseAdmin uses the service-role key (confirmed the only
-- Supabase client construction anywhere in backend/src/), which bypasses
-- RLS entirely regardless of what's declared here. So every policy below
-- is SELECT-only for `authenticated`. No INSERT/UPDATE/DELETE policies for
-- `authenticated` are added anywhere in this migration, even where the
-- TRD's prose describes a client write (e.g. "profiles: user can update
-- own allowed fields") — that write already happens via the API under
-- service-role, and adding a redundant client-side write policy would
-- only be extra attack surface for no product benefit. See this ticket's
-- report for the one column that gave me pause (none rose to the level of
-- a flaggable gap).
--
-- Circular-dependency fix: is_active_child_caregiver() is SECURITY DEFINER
-- so it queries child_caregivers with its own (elevated) privileges,
-- bypassing that table's RLS from inside the function body — this is what
-- lets child_caregivers' own SELECT policy call the same function safely
-- without recursing (verified empirically — see this ticket's report).

-- ── Ownership helper ─────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_active_child_caregiver(p_child_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM child_caregivers
        WHERE child_id = p_child_id
          AND user_id = auth.uid()
          AND is_active = true
    );
$$;

COMMENT ON FUNCTION public.is_active_child_caregiver(uuid) IS
    'Returns whether the current JWT-authenticated user (auth.uid()) has an '
    'active child_caregivers row for the given child. SECURITY DEFINER so it '
    'bypasses child_caregivers'' own RLS when called from that table''s own '
    'policy (or any other table''s policy) — only ever returns a boolean, '
    'never leaks another caregiver''s row data. SET search_path = public '
    'guards against search-path hijacking on a SECURITY DEFINER function.';

-- ============================================================================
-- Direct-owner pattern: row''s own user_id = auth.uid()
-- ============================================================================

CREATE POLICY profiles_select_own
    ON profiles FOR SELECT TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY user_consents_select_own
    ON user_consents FOR SELECT TO authenticated
    USING (user_id = auth.uid());

-- ============================================================================
-- Child-owner pattern: active child_caregivers row required
-- ============================================================================

CREATE POLICY children_select_accessible
    ON children FOR SELECT TO authenticated
    USING (is_active_child_caregiver(id));

-- "User can see relationships for children they can access" — not just
-- their own row. Verified not to recurse; see report.
CREATE POLICY child_caregivers_select_accessible
    ON child_caregivers FOR SELECT TO authenticated
    USING (is_active_child_caregiver(child_id));

CREATE POLICY assessments_select_accessible
    ON assessments FOR SELECT TO authenticated
    USING (is_active_child_caregiver(child_id));

CREATE POLICY assessment_responses_select_accessible
    ON assessment_responses FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM assessments a
            WHERE a.id = assessment_responses.assessment_id
              AND is_active_child_caregiver(a.child_id)
        )
    );

CREATE POLICY domain_results_select_accessible
    ON domain_results FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM assessments a
            WHERE a.id = domain_results.assessment_id
              AND is_active_child_caregiver(a.child_id)
        )
    );

CREATE POLICY child_priorities_select_accessible
    ON child_priorities FOR SELECT TO authenticated
    USING (is_active_child_caregiver(child_id));

CREATE POLICY activity_recommendations_select_accessible
    ON activity_recommendations FOR SELECT TO authenticated
    USING (is_active_child_caregiver(child_id));

CREATE POLICY activity_sessions_select_accessible
    ON activity_sessions FOR SELECT TO authenticated
    USING (is_active_child_caregiver(child_id));

CREATE POLICY activity_feedback_select_accessible
    ON activity_feedback FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM activity_sessions s
            WHERE s.id = activity_feedback.activity_session_id
              AND is_active_child_caregiver(s.child_id)
        )
    );

-- ============================================================================
-- Reference-content pattern: published/active content, any authenticated
-- user, no client writes ever (writes are service-role/admin-only, i.e.
-- backend-only, already satisfied by the standing writes-via-API rule).
-- ============================================================================

CREATE POLICY activities_select_published
    ON activities FOR SELECT TO authenticated
    USING (status = 'published');

CREATE POLICY question_bank_versions_select_active
    ON question_bank_versions FOR SELECT TO authenticated
    USING (status = 'active');

CREATE POLICY questions_select_active
    ON questions FOR SELECT TO authenticated
    USING (
        is_active = true
        AND EXISTS (
            SELECT 1 FROM question_bank_versions qbv
            WHERE qbv.id = questions.bank_version_id
              AND qbv.status = 'active'
        )
    );

CREATE POLICY scoring_versions_select_active
    ON scoring_versions FOR SELECT TO authenticated
    USING (status = 'active');

-- question_fallbacks: deliberately ZERO policies — see report for reasoning
-- (not named in the TRD §8 table; FT-022 is the documented client-facing
-- delivery path for fallback logic, not a direct table read).

-- ============================================================================
-- No client access at all — zero policies (RLS default-deny already
-- enabled by FT-006; nothing to add here beyond this comment marking the
-- decision as deliberate, not an oversight).
-- ============================================================================

-- ai_analysis_runs: zero policies for authenticated/anon (AC: "not
-- directly writable"; TRD leans toward no direct read either — going with
-- zero access entirely, per this ticket's explicit instruction).
-- audit_logs: zero policies (TRD/Security doc: no direct client access at
-- all, read or write).
