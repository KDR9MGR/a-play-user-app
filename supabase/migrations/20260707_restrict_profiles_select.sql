-- Close the "any authenticated user can read any other user's full profile"
-- gap: profiles_select_all had USING (true), exposing email/phone/role/
-- subscription status/dob/etc. to every other user. Lock the base table to
-- the owning row only, and expose a narrow public_profiles view (the exact
-- columns chat/friends/referral features already rely on for looking up
-- OTHER users - id, full_name, avatar_url, email) so those features keep
-- working without the broad exposure.
--
-- Applied live via `supabase db query` on 2026-07-07; this file exists so
-- the change is tracked instead of only living in the database.

DROP POLICY IF EXISTS "profiles_select_all" ON profiles;

CREATE POLICY "profiles_select_own"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE OR REPLACE VIEW public_profiles AS
  SELECT id, full_name, avatar_url, email
  FROM profiles;

GRANT SELECT ON public_profiles TO authenticated;
