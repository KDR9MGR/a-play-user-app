-- ============================================================================
-- Fix Duplicate Policy Error - Safe Migration
-- ============================================================================
-- Date: 2026-04-23
-- Purpose: Apply only the missing parts of the IAP subscription setup
-- ============================================================================

-- ============================================================================
-- STEP 1: Add Subscription Status Columns to Profiles (Safe - uses IF NOT EXISTS)
-- ============================================================================

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_subscribed BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS subscription_tier TEXT DEFAULT 'Free',
  ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMP WITH TIME ZONE;

-- Create indexes for performance (Safe - uses IF NOT EXISTS)
CREATE INDEX IF NOT EXISTS idx_profiles_is_subscribed ON profiles(is_subscribed);
CREATE INDEX IF NOT EXISTS idx_profiles_subscription_expires ON profiles(subscription_expires_at);

-- ============================================================================
-- STEP 2: Update RLS Policies (Skip user_subscriptions_insert_own - already exists)
-- ============================================================================

-- Allow service role to insert any subscription (for backend processing)
DROP POLICY IF EXISTS "user_subscriptions_insert_service_role" ON user_subscriptions;
CREATE POLICY "user_subscriptions_insert_service_role"
  ON user_subscriptions
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Ensure users can read their own subscriptions
DROP POLICY IF EXISTS "user_subscriptions_select_own" ON user_subscriptions;
CREATE POLICY "user_subscriptions_select_own"
  ON user_subscriptions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Ensure users can update their own subscriptions
DROP POLICY IF EXISTS "user_subscriptions_update_own" ON user_subscriptions;
CREATE POLICY "user_subscriptions_update_own"
  ON user_subscriptions
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- STEP 3: Ensure Required Columns Exist
-- ============================================================================

ALTER TABLE user_subscriptions
  ADD COLUMN IF NOT EXISTS plan_type TEXT,
  ADD COLUMN IF NOT EXISTS tier_points_earned INTEGER DEFAULT 0;

-- ============================================================================
-- STEP 4: Auto-Update Profile When Subscription Changes (Trigger)
-- ============================================================================

CREATE OR REPLACE FUNCTION update_profile_subscription_status()
RETURNS TRIGGER AS $$
DECLARE
  v_tier TEXT;
BEGIN
  -- Determine tier based on plan_id or existing tier value
  CASE NEW.plan_id
    WHEN '7day' THEN v_tier := 'Gold';
    WHEN '1month' THEN v_tier := 'Platinum';
    WHEN '3SUB' THEN v_tier := 'Platinum';
    WHEN '365day' THEN v_tier := 'Black';
    -- Legacy plan IDs
    WHEN 'weekly_plan' THEN v_tier := 'Gold';
    WHEN 'monthly_plan' THEN v_tier := 'Platinum';
    WHEN 'quarterly_plan' THEN v_tier := 'Platinum';
    WHEN 'annual_plan' THEN v_tier := 'Black';
    ELSE v_tier := COALESCE(NEW.tier, 'Gold');
  END CASE;

  -- Update profile with subscription status
  UPDATE profiles
  SET
    is_subscribed = (NEW.status = 'active'),
    subscription_tier = CASE
      WHEN NEW.status = 'active' THEN v_tier
      ELSE 'Free'
    END,
    subscription_expires_at = CASE
      WHEN NEW.status = 'active' THEN NEW.end_date
      ELSE NULL
    END,
    current_tier = CASE
      WHEN NEW.status = 'active' THEN v_tier
      ELSE current_tier
    END,
    updated_at = NOW()
  WHERE id = NEW.user_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop old trigger if exists and create new one
DROP TRIGGER IF EXISTS trigger_update_profile_subscription ON user_subscriptions;

CREATE TRIGGER trigger_update_profile_subscription
  AFTER INSERT OR UPDATE ON user_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_subscription_status();

-- ============================================================================
-- STEP 5: Helper Functions
-- ============================================================================

-- Function to check if user has active subscription
CREATE OR REPLACE FUNCTION has_active_subscription(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_has_sub BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM user_subscriptions
    WHERE user_id = p_user_id
      AND status = 'active'
      AND end_date > NOW()
  ) INTO v_has_sub;

  RETURN COALESCE(v_has_sub, FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's active subscription details
CREATE OR REPLACE FUNCTION get_active_subscription(p_user_id UUID)
RETURNS TABLE (
  subscription_id UUID,
  plan_id TEXT,
  plan_type TEXT,
  tier TEXT,
  status TEXT,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  days_remaining INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    us.id,
    us.plan_id,
    us.plan_type,
    us.tier,
    us.status,
    us.start_date,
    us.end_date,
    EXTRACT(DAY FROM (us.end_date - NOW()))::INTEGER as days_remaining
  FROM user_subscriptions us
  WHERE us.user_id = p_user_id
    AND us.status = 'active'
    AND us.end_date > NOW()
  ORDER BY us.created_at DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- STEP 6: Grant Permissions
-- ============================================================================

GRANT EXECUTE ON FUNCTION has_active_subscription(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_active_subscription(UUID) TO authenticated;

-- ============================================================================
-- STEP 7: Backfill Existing Data
-- ============================================================================

-- Update profiles for users with existing active subscriptions
DO $$
DECLARE
  sub_record RECORD;
  v_tier TEXT;
BEGIN
  FOR sub_record IN
    SELECT user_id, plan_id, status, end_date, tier
    FROM user_subscriptions
    WHERE status = 'active'
      AND end_date > NOW()
  LOOP
    -- Determine tier for IAP and legacy plan IDs
    CASE sub_record.plan_id
      WHEN '7day' THEN v_tier := 'Gold';
      WHEN '1month' THEN v_tier := 'Platinum';
      WHEN '3SUB' THEN v_tier := 'Platinum';
      WHEN '365day' THEN v_tier := 'Black';
      WHEN 'weekly_plan' THEN v_tier := 'Gold';
      WHEN 'monthly_plan' THEN v_tier := 'Platinum';
      WHEN 'quarterly_plan' THEN v_tier := 'Platinum';
      WHEN 'annual_plan' THEN v_tier := 'Black';
      ELSE v_tier := COALESCE(sub_record.tier, 'Gold');
    END CASE;

    -- Update profile
    UPDATE profiles
    SET
      is_subscribed = true,
      subscription_tier = v_tier,
      subscription_expires_at = sub_record.end_date,
      current_tier = v_tier,
      updated_at = NOW()
    WHERE id = sub_record.user_id;
  END LOOP;
END $$;

-- ============================================================================
-- Success Messages
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Subscription columns ensured in profiles table';
  RAISE NOTICE '✅ RLS policies updated (skipped duplicate policy)';
  RAISE NOTICE '✅ Trigger created/updated to auto-update profiles';
  RAISE NOTICE '✅ Helper functions created/updated';
  RAISE NOTICE '✅ Existing subscriptions backfilled';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 IAP Subscription system is ready!';
  RAISE NOTICE '';
  RAISE NOTICE 'IAP Product IDs mapped:';
  RAISE NOTICE '  • 7day → Gold tier';
  RAISE NOTICE '  • 1month → Platinum tier';
  RAISE NOTICE '  • 3SUB → Platinum tier';
  RAISE NOTICE '  • 365day → Black tier';
  RAISE NOTICE '';
  RAISE NOTICE 'Next: Test subscription purchase from iOS app';
END $$;
