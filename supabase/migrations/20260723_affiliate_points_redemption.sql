-- Affiliate points redemption + settlement tracking (tier 2/3 of the
-- points-as-currency plan). Deliberately does NOT move real money anywhere -
-- affiliates never get an automated payout; admins record settlement amounts
-- owed and mark them paid once they've settled outside this system (bank
-- transfer / MoMo, done manually). Affiliates have no login of their own -
-- everything here is managed by A-Play staff through the admin dashboard.

-- Businesses that accept points as a discount/payment.
CREATE TABLE IF NOT EXISTS affiliates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  business_name text NOT NULL,
  category text,
  contact_name text,
  contact_phone text,
  contact_email text,
  address text,
  point_value_ghs numeric, -- per-affiliate override; falls back to points_settings.default_point_value_ghs
  is_active boolean NOT NULL DEFAULT true,
  notes text,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE affiliates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admins manage affiliates" ON affiliates
  FOR ALL USING (is_user_admin());

CREATE POLICY "anyone can view active affiliates" ON affiliates
  FOR SELECT USING (is_active = true OR is_user_admin());

-- Single global default conversion rate (GHS per point). Affiliates can
-- override it individually via affiliates.point_value_ghs.
CREATE TABLE IF NOT EXISTS points_settings (
  id boolean PRIMARY KEY DEFAULT true CHECK (id = true), -- singleton row
  default_point_value_ghs numeric NOT NULL DEFAULT 0.01,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid REFERENCES auth.users(id)
);
INSERT INTO points_settings (id) VALUES (true) ON CONFLICT (id) DO NOTHING;

ALTER TABLE points_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anyone can read points settings" ON points_settings FOR SELECT USING (true);
CREATE POLICY "admins manage points settings" ON points_settings FOR ALL USING (is_user_admin());

-- Extend the existing (already-RLS'd, already-used-for-in-app-rewards)
-- point_redemptions table to also cover affiliate redemptions, rather than
-- building a second parallel table. redemption_code is what the user shows
-- in person at the affiliate; status moves pending -> settled once an admin
-- includes it in a settlement.
ALTER TABLE point_redemptions
  ADD COLUMN IF NOT EXISTS redemption_code text,
  ADD COLUMN IF NOT EXISTS affiliate_id uuid REFERENCES affiliates(id),
  ADD COLUMN IF NOT EXISTS settlement_id uuid;

-- Existing constraint only allowed pending/redeemed/expired/cancelled; add
-- 'settled' for redemptions that have been bundled into an affiliate settlement.
ALTER TABLE point_redemptions DROP CONSTRAINT IF EXISTS point_redemptions_status_check;
ALTER TABLE point_redemptions ADD CONSTRAINT point_redemptions_status_check
  CHECK (status = ANY (ARRAY['pending'::text, 'redeemed'::text, 'expired'::text, 'cancelled'::text, 'settled'::text]));

CREATE UNIQUE INDEX IF NOT EXISTS point_redemptions_code_idx ON point_redemptions (redemption_code) WHERE redemption_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS point_redemptions_affiliate_idx ON point_redemptions (affiliate_id) WHERE affiliate_id IS NOT NULL;

-- Settlement batches: one row per "we owe this affiliate this much, as of
-- these redemptions". Admin-only - this is the internal ledger, affiliates
-- never see it directly.
CREATE TABLE IF NOT EXISTS affiliate_settlements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  affiliate_id uuid NOT NULL REFERENCES affiliates(id),
  total_points integer NOT NULL,
  total_value_ghs numeric NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid')),
  paid_at timestamptz,
  paid_by uuid REFERENCES auth.users(id),
  payout_reference text, -- free-text note of how it was paid (bank ref, MoMo txn id, etc) - manual, not automated
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE affiliate_settlements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "admins manage settlements" ON affiliate_settlements FOR ALL USING (is_user_admin());

ALTER TABLE point_redemptions
  ADD CONSTRAINT point_redemptions_settlement_fk FOREIGN KEY (settlement_id) REFERENCES affiliate_settlements(id);

-- Server-side redemption: validates balance and the affiliate is active,
-- generates a short code, deducts points (via the existing point_transactions
-- trigger - same mechanism the in-app redemption path already uses) and
-- records a point_redemptions row in one atomic call. SECURITY DEFINER so it
-- can insert into point_transactions on the caller's behalf without needing
-- a broader RLS policy than "own rows only".
CREATE OR REPLACE FUNCTION public.redeem_points_at_affiliate(p_affiliate_id uuid, p_points integer)
RETURNS point_redemptions
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_available integer;
  v_affiliate affiliates;
  v_code text;
  v_row point_redemptions;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  IF p_points IS NULL OR p_points <= 0 THEN
    RAISE EXCEPTION 'Points must be positive';
  END IF;

  SELECT * INTO v_affiliate FROM affiliates WHERE id = p_affiliate_id AND is_active = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Affiliate not found or not active';
  END IF;

  SELECT available_points INTO v_available FROM user_points WHERE user_id = v_user_id;
  IF v_available IS NULL OR v_available < p_points THEN
    RAISE EXCEPTION 'Not enough points available';
  END IF;

  v_code := upper(substr(md5(random()::text || clock_timestamp()::text), 1, 8));

  INSERT INTO point_transactions (id, user_id, points, transaction_type, description)
  VALUES (gen_random_uuid(), v_user_id, -p_points, 'affiliate_redemption', 'Redeemed at ' || v_affiliate.business_name);

  INSERT INTO point_redemptions (id, user_id, points_spent, reward_type, reward_value, description, status, affiliate_id, redemption_code)
  VALUES (
    gen_random_uuid(), v_user_id, p_points, 'affiliate',
    p_points * COALESCE(v_affiliate.point_value_ghs, (SELECT default_point_value_ghs FROM points_settings LIMIT 1)),
    'Redeemed at ' || v_affiliate.business_name, 'pending', p_affiliate_id, v_code
  )
  RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

-- Admin-only mint/burn: adjusts a user's balance by inserting a
-- point_transactions row (same trigger-driven balance update as every other
-- earning/spending path) with an audit reason. Positive = mint, negative = burn.
CREATE OR REPLACE FUNCTION public.admin_adjust_user_points(p_user_id uuid, p_points integer, p_reason text)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
BEGIN
  IF NOT is_user_admin() THEN
    RAISE EXCEPTION 'Only admins can adjust points';
  END IF;
  IF p_points IS NULL OR p_points = 0 THEN
    RAISE EXCEPTION 'p_points must be nonzero';
  END IF;

  INSERT INTO point_transactions (id, user_id, points, transaction_type, description)
  VALUES (gen_random_uuid(), p_user_id, p_points, 'admin_adjustment', COALESCE(p_reason, 'Admin adjustment'));
END;
$$;

-- Admin-only: bundle all still-pending redemptions for one affiliate into a
-- settlement batch (the "we owe them this much" record). Does not move money.
CREATE OR REPLACE FUNCTION public.create_affiliate_settlement(p_affiliate_id uuid)
RETURNS affiliate_settlements
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
DECLARE
  v_settlement affiliate_settlements;
  v_total_points integer;
  v_total_value numeric;
BEGIN
  IF NOT is_user_admin() THEN
    RAISE EXCEPTION 'Only admins can create settlements';
  END IF;

  SELECT COALESCE(SUM(points_spent), 0), COALESCE(SUM(reward_value), 0)
  INTO v_total_points, v_total_value
  FROM point_redemptions
  WHERE affiliate_id = p_affiliate_id AND status = 'pending' AND settlement_id IS NULL;

  IF v_total_points = 0 THEN
    RAISE EXCEPTION 'No pending redemptions for this affiliate';
  END IF;

  INSERT INTO affiliate_settlements (id, affiliate_id, total_points, total_value_ghs, created_by)
  VALUES (gen_random_uuid(), p_affiliate_id, v_total_points, v_total_value, auth.uid())
  RETURNING * INTO v_settlement;

  UPDATE point_redemptions
  SET settlement_id = v_settlement.id, status = 'settled'
  WHERE affiliate_id = p_affiliate_id AND status = 'pending' AND settlement_id IS NULL;

  RETURN v_settlement;
END;
$$;

-- Admin-only: mark a settlement as actually paid (manual - the admin did the
-- real bank/MoMo transfer themselves outside this system, this just records it).
CREATE OR REPLACE FUNCTION public.mark_settlement_paid(p_settlement_id uuid, p_payout_reference text)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
BEGIN
  IF NOT is_user_admin() THEN
    RAISE EXCEPTION 'Only admins can mark settlements paid';
  END IF;

  UPDATE affiliate_settlements
  SET status = 'paid', paid_at = now(), paid_by = auth.uid(), payout_reference = p_payout_reference
  WHERE id = p_settlement_id;
END;
$$;
