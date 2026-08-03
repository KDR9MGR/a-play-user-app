-- Applied live via `supabase db query` on 2026-07-12; tracked here.
-- S2: block direct client INSERT into user_subscriptions and bookings - see
-- confirm-purchase, start-free-trial, and the rewritten verify-apple-receipt
-- edge functions for where fulfillment now actually happens.
CREATE OR REPLACE FUNCTION public.guard_paid_resource_inserts()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
BEGIN
  IF auth.role() = 'service_role' OR is_user_admin() THEN
    RETURN NEW;
  END IF;
  RAISE EXCEPTION 'Direct insert not allowed - purchases must go through the payment confirmation flow';
END;
$$;

DROP TRIGGER IF EXISTS guard_user_subscriptions_insert ON user_subscriptions;
CREATE TRIGGER guard_user_subscriptions_insert
  BEFORE INSERT ON user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.guard_paid_resource_inserts();

DROP TRIGGER IF EXISTS guard_bookings_insert ON bookings;
CREATE TRIGGER guard_bookings_insert
  BEFORE INSERT ON bookings
  FOR EACH ROW EXECUTE FUNCTION public.guard_paid_resource_inserts();
