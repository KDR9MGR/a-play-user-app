-- Applied live via `supabase db query` on 2026-07-12; tracked here.
-- S1: block privilege escalation. A BEFORE INSERT/UPDATE trigger stops any
-- non-service-role, non-admin caller from changing role / is_organizer /
-- is_approved / premium / subscription columns on profiles (and from
-- creating admin rows / self-granting premium at insert). Only actual
-- CHANGES (IS DISTINCT FROM) are blocked, so existing flows that rewrite a
-- privileged column with its unchanged value keep working. Also restores an
-- admins-manage-all policy after the earlier own-row-only SELECT tightening.

CREATE OR REPLACE FUNCTION public.guard_profile_privileged_columns()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
BEGIN
  IF auth.role() = 'service_role' OR is_user_admin() THEN
    RETURN NEW;
  END IF;
  IF TG_OP = 'UPDATE' THEN
    IF NEW.role IS DISTINCT FROM OLD.role
       OR NEW.is_organizer IS DISTINCT FROM OLD.is_organizer
       OR NEW.is_approved IS DISTINCT FROM OLD.is_approved
       OR NEW.is_premium IS DISTINCT FROM OLD.is_premium
       OR NEW.is_subscribed IS DISTINCT FROM OLD.is_subscribed
       OR NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier
       OR NEW.subscription_expires_at IS DISTINCT FROM OLD.subscription_expires_at
       OR NEW.current_tier IS DISTINCT FROM OLD.current_tier
    THEN
      RAISE EXCEPTION 'Not allowed to change privileged profile fields';
    END IF;
  ELSIF TG_OP = 'INSERT' THEN
    IF NEW.role = 'admin' THEN
      RAISE EXCEPTION 'Not allowed to create admin profiles';
    END IF;
    NEW.is_premium := false;
    NEW.is_subscribed := false;
    NEW.subscription_tier := 'Free';
    NEW.subscription_expires_at := NULL;
    NEW.current_tier := 'Free';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS guard_profile_privileged_columns ON profiles;
CREATE TRIGGER guard_profile_privileged_columns
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION public.guard_profile_privileged_columns();

DROP POLICY IF EXISTS "admins manage profiles" ON profiles;
CREATE POLICY "admins manage profiles" ON profiles FOR ALL USING (is_user_admin());
