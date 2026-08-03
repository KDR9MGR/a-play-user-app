-- Applied live via `supabase db query` on 2026-07-12; tracked here.
-- Fixes a regression the S1 guard (20260712_s1_profiles_privilege_guard.sql)
-- introduced: update_profile_subscription_status (SECURITY DEFINER trigger
-- on user_subscriptions) was being blocked by the S1 profiles guard because
-- auth.role()/auth.uid() reflect the ORIGINAL caller's JWT regardless of
-- SECURITY DEFINER. Any legitimate non-service-role update to a user's own
-- user_subscriptions row broke real-time profile subscription status sync.
-- Fix: the trigger sets a transaction-local flag before its trusted write;
-- the guard trusts that flag in addition to service_role/admin.
CREATE OR REPLACE FUNCTION public.update_profile_subscription_status()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $function$
BEGIN
  PERFORM set_config('app.bypass_profile_guard', 'true', true);

  IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.status = 'active' THEN
    UPDATE profiles SET is_subscribed = true, subscription_tier = NEW.tier,
      current_tier = NEW.tier, subscription_expires_at = NEW.end_date, updated_at = NOW()
    WHERE id = NEW.user_id;
  END IF;

  IF (TG_OP = 'UPDATE' AND NEW.status != 'active') OR (TG_OP = 'DELETE') THEN
    IF NOT EXISTS (
      SELECT 1 FROM user_subscriptions
      WHERE user_id = COALESCE(NEW.user_id, OLD.user_id) AND status = 'active'
        AND end_date > NOW() AND id != COALESCE(NEW.id, OLD.id)
    ) THEN
      UPDATE profiles SET is_subscribed = false, subscription_tier = NULL,
        subscription_expires_at = NULL, updated_at = NOW()
      WHERE id = COALESCE(NEW.user_id, OLD.user_id);
    END IF;
  END IF;
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.guard_profile_privileged_columns()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
BEGIN
  IF auth.role() = 'service_role' OR is_user_admin()
     OR current_setting('app.bypass_profile_guard', true) = 'true' THEN
    RETURN NEW;
  END IF;
  IF TG_OP = 'UPDATE' THEN
    IF NEW.role IS DISTINCT FROM OLD.role OR NEW.is_organizer IS DISTINCT FROM OLD.is_organizer
       OR NEW.is_approved IS DISTINCT FROM OLD.is_approved OR NEW.is_premium IS DISTINCT FROM OLD.is_premium
       OR NEW.is_subscribed IS DISTINCT FROM OLD.is_subscribed OR NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier
       OR NEW.subscription_expires_at IS DISTINCT FROM OLD.subscription_expires_at OR NEW.current_tier IS DISTINCT FROM OLD.current_tier
    THEN
      RAISE EXCEPTION 'Not allowed to change privileged profile fields';
    END IF;
  ELSIF TG_OP = 'INSERT' THEN
    IF NEW.role = 'admin' THEN
      RAISE EXCEPTION 'Not allowed to create admin profiles';
    END IF;
    NEW.is_premium := false; NEW.is_subscribed := false; NEW.subscription_tier := 'Free';
    NEW.subscription_expires_at := NULL; NEW.current_tier := 'Free';
  END IF;
  RETURN NEW;
END;
$$;
