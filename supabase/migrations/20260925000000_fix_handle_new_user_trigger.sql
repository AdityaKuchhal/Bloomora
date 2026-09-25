-- FT-006 follow-up, urgent: the pre-existing on_auth_user_created trigger
-- (AFTER INSERT ON auth.users -> public.handle_new_user()) was not created
-- by any migration in this repo — it predates this baseline and was
-- discovered live on the remote project via `supabase db dump --schema
-- auth` after 20260924000000_drop_legacy_schema.sql ran. Its function body
-- does `INSERT INTO public.parents (...)`, and DROP TABLE parents CASCADE
-- has no way to catch that: Postgres doesn't track a plpgsql function
-- body's hardcoded table references as a dependency, so the function
-- survived the drop unchanged while its target table did not. Left as-is,
-- this breaks every new sign-up (the trigger fires synchronously inside
-- the same transaction as the auth.users insert).
--
-- Fix: repoint the function at public.profiles, the new baseline's
-- equivalent caregiver-identity table, mapping fields as closely as the
-- old trigger's intent (auto-provision an identity row on signup):
--   parents.name            -> profiles.display_name (same COALESCE-to-
--                               empty-string fallback as before)
--   parents.email            -> dropped: profiles has no email column
--                               (per the FT-006 spec; auth.users.email is
--                               already the source of truth for email)
--   parents.created_at/updated_at -> profiles.created_at/updated_at
--                               (both already default to now())
-- country_code/locale/timezone are left NULL (all nullable);
-- onboarding_complete keeps its DEFAULT false.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (user_id, display_name, created_at, updated_at)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        now(),
        now()
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- The trigger itself (on_auth_user_created AFTER INSERT ON auth.users)
-- was also never created by any committed migration — it already existed
-- live, outside of git, same as the function above. Declared here too so
-- a fresh environment (supabase db reset, or standing up a new project)
-- reproduces the exact same live behavior, not just the function fix.
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
