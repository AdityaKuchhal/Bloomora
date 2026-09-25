#!/bin/bash
# FT-007: Automated cross-account RLS isolation test suite.
#
# LOCAL ONLY — targets the Supabase CLI's local dev stack (127.0.0.1:54321)
# and hardcodes its well-known, publicly-documented local demo keys (the
# same anon/service_role keys every `supabase start` prints — not secrets,
# never valid against a real project). Never point this at a live project.
#
# Usage:
#   supabase start        # from repo root, brings up the local stack
#   bash supabase/tests/rls_cross_account_isolation.sh
#
# Self-contained and idempotent: creates two real throwaway Supabase-auth
# accounts (Account A / Account B) via the local Auth API, seeds one child
# + a full set of child-owned rows for each via the service-role key
# (bypassing RLS, exactly like the backend does), runs every assertion as
# Account A's real JWT against PostgREST (the same path a manipulated
# Flutter client would take), then tears down every row and both auth
# users it created — on success, failure, or Ctrl-C (trap on EXIT), and
# also as a best-effort pre-clean at the start, so reruns don't collide
# with leftover state from a previous run.
#
# Exits 0 if every assertion passed, 1 otherwise (safe to wire into CI
# later once this repo has a Supabase-level CI job).
set -uo pipefail

ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU"
REST="http://127.0.0.1:54321/rest/v1"
AUTH="http://127.0.0.1:54321/auth/v1"
EMAIL_A="ft007-account-a@isolation-test.local"
EMAIL_B="ft007-account-b@isolation-test.local"
PASSWORD="TestPassw0rd!12345"

CHILD_A="11111111-1111-1111-1111-111111111111"
CHILD_B="22222222-2222-2222-2222-222222222222"
CAREGIVER_A="11111111-1111-1111-1111-111111111112"
CAREGIVER_B="22222222-2222-2222-2222-222222222223"
QBV="33333333-3333-3333-3333-333333333333"
SV="44444444-4444-4444-4444-444444444444"
QUESTION="55555555-5555-5555-5555-555555555555"
ACTIVITY="66666666-6666-6666-6666-666666666666"
ASSESS_A="77777777-7777-7777-7777-777777777777"
ASSESS_B="88888888-8888-8888-8888-888888888888"
RESP_A="99999999-9999-9999-9999-999999999999"
RESP_B="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
DOMR_A="bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
DOMR_B="cccccccc-cccc-cccc-cccc-cccccccccccc"
PRIO_A="dddddddd-dddd-dddd-dddd-dddddddddddd"
PRIO_B="eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"
REC_A="12121212-1212-1212-1212-121212121212"
REC_B="23232323-2323-2323-2323-232323232323"
SESS_A="34343434-3434-3434-3434-343434343434"
SESS_B="45454545-4545-4545-4545-454545454545"
FEED_A="56565656-5656-5656-5656-565656565656"
FEED_B="67676767-6767-6767-6767-676767676767"
AI_A="78787878-7878-7878-7878-787878787878"
AUDIT_A="89898989-8989-8989-8989-898989898989"

pass_count=0
fail_count=0
A_ID=""
B_ID=""

check() {
  if [ "$2" = "true" ]; then echo "PASS: $1"; pass_count=$((pass_count+1))
  else echo "FAIL: $1"; fail_count=$((fail_count+1)); fi
}

svc() { # service-role REST call — bypasses RLS, used only for setup/teardown
  curl -s -o /dev/null -w '%{http_code}' -X "$1" "$REST/$2" \
    -H "apikey: $SERVICE_KEY" -H "Authorization: Bearer $SERVICE_KEY" \
    -H "Content-Type: application/json" -H "Prefer: return=minimal,resolution=merge-duplicates" \
    ${3:+-d "$3"}
}

as_a() { # Account A's real JWT — this is what every assertion runs through
  curl -s -w '\nHTTP_STATUS:%{http_code}' -X "$1" "$REST/$2" \
    -H "apikey: $ANON_KEY" -H "Authorization: Bearer $A_TOKEN" \
    -H "Content-Type: application/json" -H "Prefer: return=representation" ${3:+-d "$3"}
}

body_of() { echo "$1" | sed 's/HTTP_STATUS:[0-9]*$//' | tr -d '[:space:]'; }
raw_body_of() { echo "$1" | sed 's/HTTP_STATUS:[0-9]*$//'; }
status_of() { echo "$1" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2; }

cleanup() {
  echo "--- cleanup ---"
  # Delete by known fixed IDs, FK-safe order (safe no-ops if absent —
  # service role, RLS bypassed).
  svc DELETE "activity_feedback?id=in.($FEED_A,$FEED_B)" >/dev/null
  svc DELETE "activity_sessions?id=in.($SESS_A,$SESS_B)" >/dev/null
  svc DELETE "activity_recommendations?id=in.($REC_A,$REC_B)" >/dev/null
  svc DELETE "child_priorities?id=in.($PRIO_A,$PRIO_B)" >/dev/null
  svc DELETE "domain_results?id=in.($DOMR_A,$DOMR_B)" >/dev/null
  svc DELETE "assessment_responses?id=in.($RESP_A,$RESP_B)" >/dev/null
  svc DELETE "assessments?id=in.($ASSESS_A,$ASSESS_B)" >/dev/null
  svc DELETE "ai_analysis_runs?id=eq.$AI_A" >/dev/null
  svc DELETE "audit_logs?id=eq.$AUDIT_A" >/dev/null
  svc DELETE "questions?id=eq.$QUESTION" >/dev/null
  svc DELETE "activities?id=eq.$ACTIVITY" >/dev/null
  svc DELETE "scoring_versions?id=eq.$SV" >/dev/null
  svc DELETE "question_bank_versions?id=eq.$QBV" >/dev/null
  svc DELETE "child_caregivers?id=in.($CAREGIVER_A,$CAREGIVER_B)" >/dev/null
  svc DELETE "children?id=in.($CHILD_A,$CHILD_B)" >/dev/null
  # Delete the throwaway auth users via the GoTrue admin API. This local
  # GoTrue version ignores the documented ?email= filter (confirmed: it
  # returns the full user list regardless), so filter client-side instead.
  all_users=$(curl -s "$AUTH/admin/users" -H "apikey: $SERVICE_KEY" -H "Authorization: Bearer $SERVICE_KEY")
  for email in "$EMAIL_A" "$EMAIL_B"; do
    uid=$(echo "$all_users" | jq -r --arg email "$email" '.users[] | select(.email == $email) | .id' 2>/dev/null)
    if [ -n "${uid:-}" ]; then
      # profiles.user_id -> auth.users.id is ON DELETE RESTRICT by design
      # (FT-006), and handle_new_user() auto-creates a profiles row on
      # every signup — must delete that row first or the auth user delete
      # below fails with a FK violation.
      svc DELETE "profiles?user_id=eq.$uid" >/dev/null
      curl -s -o /dev/null -X DELETE "$AUTH/admin/users/$uid" -H "apikey: $SERVICE_KEY" -H "Authorization: Bearer $SERVICE_KEY"
    fi
  done
  echo "--- cleanup done ---"
}
trap cleanup EXIT

echo "=== pre-clean (best-effort, in case a previous run left state) ==="
cleanup

echo "=== setup: create two throwaway accounts ==="
signup() {
  curl -s -X POST "$AUTH/signup" -H "apikey: $ANON_KEY" -H "Content-Type: application/json" \
    -d "{\"email\":\"$1\",\"password\":\"$PASSWORD\"}"
}
A_JSON=$(signup "$EMAIL_A")
B_JSON=$(signup "$EMAIL_B")
A_TOKEN=$(echo "$A_JSON" | jq -r '.access_token')
A_ID=$(echo "$A_JSON" | jq -r '.user.id')
B_TOKEN=$(echo "$B_JSON" | jq -r '.access_token')
B_ID=$(echo "$B_JSON" | jq -r '.user.id')
if [ "$A_ID" = "null" ] || [ -z "$A_ID" ] || [ "$B_ID" = "null" ] || [ -z "$B_ID" ]; then
  echo "FATAL: could not create test accounts. A_JSON=$A_JSON B_JSON=$B_JSON"
  exit 1
fi
echo "Account A: $A_ID"
echo "Account B: $B_ID"

echo "=== setup: seed data via service role (bypasses RLS, same as the backend) ==="
svc POST "children" "[{\"id\":\"$CHILD_A\",\"preferred_name\":\"Child A\",\"date_of_birth\":\"2021-01-01\"},{\"id\":\"$CHILD_B\",\"preferred_name\":\"Child B\",\"date_of_birth\":\"2021-06-01\"}]" >/dev/null
svc POST "child_caregivers" "[{\"id\":\"$CAREGIVER_A\",\"child_id\":\"$CHILD_A\",\"user_id\":\"$A_ID\",\"relationship_type\":\"parent\",\"role\":\"owner\",\"is_active\":true},{\"id\":\"$CAREGIVER_B\",\"child_id\":\"$CHILD_B\",\"user_id\":\"$B_ID\",\"relationship_type\":\"parent\",\"role\":\"owner\",\"is_active\":true}]" >/dev/null
svc POST "question_bank_versions" "{\"id\":\"$QBV\",\"version\":\"v1-test\",\"status\":\"active\"}" >/dev/null
svc POST "scoring_versions" "{\"id\":\"$SV\",\"version\":\"s1-test\",\"rules_json\":{},\"status\":\"active\"}" >/dev/null
svc POST "questions" "{\"id\":\"$QUESTION\",\"bank_version_id\":\"$QBV\",\"question_key\":\"q1\",\"domain_code\":\"cognitive\",\"prompt\":\"Test\",\"age_min_months\":12,\"age_max_months\":24,\"slot_key\":\"slot1\",\"sort_order\":1,\"is_active\":true}" >/dev/null
svc POST "activities" "{\"id\":\"$ACTIVITY\",\"activity_key\":\"test-activity\",\"version\":1,\"title\":\"Test\",\"domain_code\":\"cognitive\",\"target_skill\":\"skill\",\"age_min_months\":12,\"age_max_months\":24,\"difficulty\":\"easy\",\"duration_minutes\":10,\"materials\":[],\"steps\":[],\"benefits\":\"b\",\"status\":\"published\"}" >/dev/null
svc POST "assessments" "[{\"id\":\"$ASSESS_A\",\"child_id\":\"$CHILD_A\",\"started_by_user_id\":\"$A_ID\",\"question_bank_version_id\":\"$QBV\",\"scoring_version_id\":\"$SV\",\"status\":\"submitted\"},{\"id\":\"$ASSESS_B\",\"child_id\":\"$CHILD_B\",\"started_by_user_id\":\"$B_ID\",\"question_bank_version_id\":\"$QBV\",\"scoring_version_id\":\"$SV\",\"status\":\"submitted\"}]" >/dev/null
svc POST "assessment_responses" "[{\"id\":\"$RESP_A\",\"assessment_id\":\"$ASSESS_A\",\"question_id\":\"$QUESTION\",\"slot_key\":\"slot1\",\"score\":2,\"answered_by_user_id\":\"$A_ID\"},{\"id\":\"$RESP_B\",\"assessment_id\":\"$ASSESS_B\",\"question_id\":\"$QUESTION\",\"slot_key\":\"slot1\",\"score\":1,\"answered_by_user_id\":\"$B_ID\"}]" >/dev/null
svc POST "domain_results" "[{\"id\":\"$DOMR_A\",\"assessment_id\":\"$ASSESS_A\",\"domain_code\":\"cognitive\",\"raw_score\":2,\"max_score\":2},{\"id\":\"$DOMR_B\",\"assessment_id\":\"$ASSESS_B\",\"domain_code\":\"cognitive\",\"raw_score\":1,\"max_score\":2}]" >/dev/null
svc POST "child_priorities" "[{\"id\":\"$PRIO_A\",\"child_id\":\"$CHILD_A\",\"domain_code\":\"cognitive\",\"rank\":1,\"source\":\"system_suggested\",\"is_active\":true},{\"id\":\"$PRIO_B\",\"child_id\":\"$CHILD_B\",\"domain_code\":\"cognitive\",\"rank\":1,\"source\":\"system_suggested\",\"is_active\":true}]" >/dev/null
svc POST "activity_recommendations" "[{\"id\":\"$REC_A\",\"child_id\":\"$CHILD_A\",\"activity_id\":\"$ACTIVITY\",\"domain_code\":\"cognitive\",\"reason_code\":\"priority_domain\",\"source\":\"rules\",\"status\":\"active\"},{\"id\":\"$REC_B\",\"child_id\":\"$CHILD_B\",\"activity_id\":\"$ACTIVITY\",\"domain_code\":\"cognitive\",\"reason_code\":\"priority_domain\",\"source\":\"rules\",\"status\":\"active\"}]" >/dev/null
svc POST "activity_sessions" "[{\"id\":\"$SESS_A\",\"child_id\":\"$CHILD_A\",\"activity_id\":\"$ACTIVITY\",\"performed_by_user_id\":\"$A_ID\",\"status\":\"completed\"},{\"id\":\"$SESS_B\",\"child_id\":\"$CHILD_B\",\"activity_id\":\"$ACTIVITY\",\"performed_by_user_id\":\"$B_ID\",\"status\":\"completed\"}]" >/dev/null
svc POST "activity_feedback" "[{\"id\":\"$FEED_A\",\"activity_session_id\":\"$SESS_A\",\"difficulty\":\"just_right\",\"engagement\":\"high\"},{\"id\":\"$FEED_B\",\"activity_session_id\":\"$SESS_B\",\"difficulty\":\"just_right\",\"engagement\":\"high\"}]" >/dev/null
svc POST "ai_analysis_runs" "{\"id\":\"$AI_A\",\"child_id\":\"$CHILD_A\",\"purpose\":\"assessment_summary\",\"provider\":\"anthropic\",\"model\":\"test-model\",\"prompt_version\":\"v1\",\"status\":\"completed\"}" >/dev/null
svc POST "audit_logs" "{\"id\":\"$AUDIT_A\",\"actor_user_id\":\"$A_ID\",\"action\":\"test.action\",\"entity_type\":\"children\",\"entity_id\":\"$CHILD_A\"}" >/dev/null
echo "seed complete"

echo ""
echo "=========================================="
echo "1. SANITY: Account A can read its OWN data"
echo "=========================================="
R=$(as_a GET "children?id=eq.$CHILD_A")
COUNT=$(body_of "$R" | jq 'length' 2>/dev/null)
echo "$(raw_body_of "$R")"
check "A can SELECT own child" "$([ "$COUNT" = "1" ] && echo true || echo false)"

echo ""
echo "=========================================="
echo "2. A CANNOT SELECT B's rows (all child-owned tables)"
echo "=========================================="
for pair in "children:id=eq.$CHILD_B" "assessments:id=eq.$ASSESS_B" "assessment_responses:id=eq.$RESP_B" \
            "domain_results:id=eq.$DOMR_B" "child_priorities:id=eq.$PRIO_B" "activity_recommendations:id=eq.$REC_B" \
            "activity_sessions:id=eq.$SESS_B" "activity_feedback:id=eq.$FEED_B" "child_caregivers:id=eq.$CAREGIVER_B"; do
  table="${pair%%:*}"; filter="${pair#*:}"
  R=$(as_a GET "${table}?${filter}")
  COUNT=$(body_of "$R" | jq 'length' 2>/dev/null)
  echo "$table?$filter -> $(raw_body_of "$R")"
  check "A cannot SELECT B's row in $table (0 rows returned)" "$([ "$COUNT" = "0" ] && echo true || echo false)"
done

echo ""
echo "=========================================="
echo "3. A CANNOT UPDATE B's rows"
echo "=========================================="
for pair in "children:id=eq.$CHILD_B:{\"preferred_name\":\"HACKED\"}" \
            "assessments:id=eq.$ASSESS_B:{\"status\":\"abandoned\"}" \
            "child_priorities:id=eq.$PRIO_B:{\"rank\":2}"; do
  IFS=':' read -r table filter payload <<< "$pair"
  R=$(as_a PATCH "${table}?${filter}" "$payload")
  echo "$table -> status=$(status_of "$R") body=$(raw_body_of "$R")"
  check "A's UPDATE on B's row in $table affects 0 rows" "$([ "$(body_of "$R")" = "[]" ] && echo true || echo false)"
done

echo ""
echo "=========================================="
echo "4. A CANNOT DELETE B's rows"
echo "=========================================="
R=$(as_a DELETE "child_priorities?id=eq.$PRIO_B")
echo "child_priorities DELETE -> status=$(status_of "$R") body=$(raw_body_of "$R")"
check "A's DELETE on B's child_priorities row affects 0 rows" "$([ "$(body_of "$R")" = "[]" ] && echo true || echo false)"

echo ""
echo "=========================================="
echo "5. A CANNOT INSERT under B's child (or even under A's OWN child)"
echo "=========================================="
R=$(as_a POST "assessments" "{\"child_id\":\"$CHILD_B\",\"started_by_user_id\":\"$A_ID\",\"question_bank_version_id\":\"$QBV\",\"scoring_version_id\":\"$SV\",\"status\":\"in_progress\"}")
echo "INSERT under B's child as A -> status=$(status_of "$R") body=$(raw_body_of "$R")"
check "A's INSERT under B's child is rejected" "$([ "$(status_of "$R")" != "200" ] && [ "$(status_of "$R")" != "201" ] && echo true || echo false)"

R=$(as_a POST "assessments" "{\"child_id\":\"$CHILD_A\",\"started_by_user_id\":\"$A_ID\",\"question_bank_version_id\":\"$QBV\",\"scoring_version_id\":\"$SV\",\"status\":\"in_progress\"}")
echo "INSERT under A's OWN child as A -> status=$(status_of "$R") body=$(raw_body_of "$R")"
check "A's INSERT even under A's OWN child is also rejected (no INSERT policy for authenticated at all)" "$([ "$(status_of "$R")" != "200" ] && [ "$(status_of "$R")" != "201" ] && echo true || echo false)"

echo ""
echo "=========================================="
echo "6. Reference content: A can read published/active content"
echo "=========================================="
for table in activities questions question_bank_versions scoring_versions; do
  R=$(as_a GET "$table?select=id&limit=5")
  COUNT=$(body_of "$R" | jq 'length' 2>/dev/null)
  echo "A reads $table -> $(raw_body_of "$R")"
  check "A can read $table (count=$COUNT > 0)" "$([ "${COUNT:-0}" -gt 0 ] 2>/dev/null && echo true || echo false)"
done

echo ""
echo "=========================================="
echo "7. ai_analysis_runs / audit_logs: unreadable AND unwritable by A"
echo "=========================================="
R=$(as_a GET "ai_analysis_runs?select=id")
COUNT=$(body_of "$R" | jq 'length' 2>/dev/null)
echo "A reads ai_analysis_runs -> $(raw_body_of "$R")"
check "A cannot read ai_analysis_runs (0 rows, though a real row exists for A's own child)" "$([ "$COUNT" = "0" ] && echo true || echo false)"

R=$(as_a GET "audit_logs?select=id")
COUNT=$(body_of "$R" | jq 'length' 2>/dev/null)
echo "A reads audit_logs -> $(raw_body_of "$R")"
check "A cannot read audit_logs (0 rows, though a real row exists for A's own action)" "$([ "$COUNT" = "0" ] && echo true || echo false)"

R=$(as_a POST "ai_analysis_runs" "{\"child_id\":\"$CHILD_A\",\"purpose\":\"assessment_summary\",\"provider\":\"anthropic\",\"model\":\"x\",\"prompt_version\":\"v1\",\"status\":\"queued\"}")
echo "A INSERT ai_analysis_runs -> status=$(status_of "$R")"
check "A cannot INSERT into ai_analysis_runs" "$([ "$(status_of "$R")" != "200" ] && [ "$(status_of "$R")" != "201" ] && echo true || echo false)"

echo ""
echo "=========================================="
echo "8. child_caregivers recursion safety"
echo "=========================================="
R=$(as_a GET "child_caregivers?child_id=eq.$CHILD_A")
COUNT=$(body_of "$R" | jq 'length' 2>/dev/null)
echo "A queries child_caregivers for child A -> status=$(status_of "$R") body=$(raw_body_of "$R")"
check "No error/timeout querying child_caregivers as A (status 200)" "$([ "$(status_of "$R")" = "200" ] && echo true || echo false)"
check "Correct row count returned (1 -- no recursion-induced wrong result)" "$([ "$COUNT" = "1" ] && echo true || echo false)"

echo ""
echo "=========================================="
echo "SUMMARY: $pass_count passed, $fail_count failed"
echo "=========================================="
[ "$fail_count" -eq 0 ]
