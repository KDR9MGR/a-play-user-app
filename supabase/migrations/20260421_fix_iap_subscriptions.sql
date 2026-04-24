-- ============================================================================
-- IAP Subscription Fix - Complete Solution
-- ============================================================================
-- Date: 2026-04-21
-- Purpose: Fix subscription flow for iOS IAP purchases
-- Issues Fixed:
--   1. Add subscription tracking columns to profiles
--   2. Fix RLS policies to allow user-initiated subscription creation
--   3. Create trigger to auto-update profiles when subscription changes
--   4. Add helper functions for subscription validation
-- ============================================================================

-- ============================================================================
-- STEP 1: Add Subscription Status Columns to Profiles
-- ============================================================================

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_subscribed BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS subscription_tier TEXT DEFAULT 'Free',
  ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMP WITH TIME ZONE;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_profiles_is_subscribed ON profiles(is_subscribed);
CREATE INDEX IF NOT EXISTS idx_profiles_subscription_expires ON profiles(subscription_expires_at);

COMMENT ON COLUMN profiles.is_subscribed IS
  'Quick boolean flag indicating if user has an active subscription. Auto-updated by trigger.';

COMMENT ON COLUMN profiles.subscription_tier IS
  'Current subscription tier (Free, Gold, Platinum, Black). Auto-updated by trigger.';

COMMENT ON COLUMN profiles.subscription_expires_at IS
  'When the current subscription expires. NULL if not subscribed. Auto-updated by trigger.';

-- ============================================================================
-- STEP 2: Fix RLS Policies for user_subscriptions
-- ============================================================================

-- Drop old restrictive insert policy
DROP POLICY IF EXISTS "user_subscriptions_insert_service" ON user_subscriptions;

-- Allow authenticated users to insert their own subscriptions
-- This is needed for IAP purchases initiated by the app
CREATE POLICY "user_subscriptions_insert_own"
  ON user_subscriptions
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Allow service role to insert any subscription (for backend processing)
CREATE POLICY "user_subscriptions_insert_service_role"
  ON user_subscriptions
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Ensure users can still read and update their own subscriptions
DROP POLICY IF EXISTS "user_subscriptions_select_own" ON user_subscriptions;
CREATE POLICY "user_subscriptions_select_own"
  ON user_subscriptions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "user_subscriptions_update_own" ON user_subscriptions;
CREATE POLICY "user_subscriptions_update_own"
  ON user_subscriptions
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- STEP 3: Fix user_subscriptions Table Schema
-- ============================================================================

-- Ensure required columns exist with correct types
ALTER TABLE user_subscriptions
  ADD COLUMN IF NOT EXISTS plan_type TEXT,
  ADD COLUMN IF NOT EXISTS tier_points_earned INTEGER DEFAULT 0;

-- Update existing records to have plan_type if null
UPDATE user_subscriptions
SET plan_type = CASE
  WHEN plan_id = 'weekly_plan' THEN 'weekly'
  WHEN plan_id = 'monthly_plan' THEN 'monthly'
  WHEN plan_id = 'quarterly_plan' THEN 'quarterly'
  WHEN plan_id = 'annual_plan' THEN 'annual'
  ELSE 'unknown'
END
WHERE plan_type IS NULL;

-- ============================================================================
-- STEP 4: Auto-Update Profile When Subscription Changes (Trigger)
-- ============================================================================

CREATE OR REPLACE FUNCTION update_profile_subscription_status()
RETURNS TRIGGER AS $$
DECLARE
  v_tier TEXT;
BEGIN
  -- Determine tier based on plan_id
  CASE NEW.plan_id
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
      ELSE current_tier  -- Keep current tier if subscription is not active
    END,
    updated_at = NOW()
  WHERE id = NEW.user_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop old trigger if exists
DROP TRIGGER IF EXISTS trigger_update_profile_subscription ON user_subscriptions;

-- Create trigger that fires after insert or update
CREATE TRIGGER trigger_update_profile_subscription
  AFTER INSERT OR UPDATE ON user_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_subscription_status();

-- ============================================================================
-- STEP 5: Helper Functions for Subscription Validation
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

-- Function to expire old subscriptions (should be run periodically)
CREATE OR REPLACE FUNCTION expire_old_subscriptions()
RETURNS void AS $$
BEGIN
  -- Mark subscriptions as expired
  UPDATE user_subscriptions
  SET status = 'expired',
      updated_at = NOW()
  WHERE status = 'active'
    AND end_date < NOW();

  -- Update profiles for users with expired subscriptions
  UPDATE profiles p
  SET
    is_subscribed = false,
    subscription_tier = 'Free',
    subscription_expires_at = NULL,
    updated_at = NOW()
  WHERE p.is_subscribed = true
    AND NOT EXISTS (
      SELECT 1
      FROM user_subscriptions us
      WHERE us.user_id = p.id
        AND us.status = 'active'
        AND us.end_date > NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- STEP 6: Grant Permissions
-- ============================================================================

GRANT EXECUTE ON FUNCTION has_active_subscription(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_active_subscription(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION expire_old_subscriptions() TO service_role;

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
    -- Determine tier
    CASE sub_record.plan_id
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
-- STEP 8: Add Comments for Documentation
-- ============================================================================

COMMENT ON FUNCTION update_profile_subscription_status() IS
  'Trigger function that automatically updates profile subscription status when user_subscriptions changes.';

COMMENT ON FUNCTION has_active_subscription(UUID) IS
  'Returns true if user has an active subscription that has not expired.';

COMMENT ON FUNCTION get_active_subscription(UUID) IS
  'Returns details of user active subscription including days remaining.';

COMMENT ON FUNCTION expire_old_subscriptions() IS
  'Batch function to expire old subscriptions and update profiles. Should be run periodically via cron.';

-- ============================================================================
-- Success Messages
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Subscription columns added to profiles table';
  RAISE NOTICE '✅ RLS policies updated to allow user inserts';
  RAISE NOTICE '✅ Trigger created to auto-update profiles';
  RAISE NOTICE '✅ Helper functions created';
  RAISE NOTICE '✅ Existing subscriptions backfilled';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 IAP Subscription system is ready!';
  RAISE NOTICE '';
  RAISE NOTICE 'Next steps:';
  RAISE NOTICE '1. Test subscription purchase from iOS app';
  RAISE NOTICE '2. Verify database updates automatically';
  RAISE NOTICE '3. Schedule expire_old_subscriptions() to run daily';
END $$;
