-- ============================================================================
-- Subscription Status Tracking Enhancement
-- ============================================================================
-- Adds subscription status columns to profiles table for quick access
-- Creates trigger to auto-update profile when subscription changes
-- ============================================================================

-- Add subscription status columns to profiles table
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_subscribed BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS subscription_tier TEXT DEFAULT 'Free',
  ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMP WITH TIME ZONE;

-- Create index for quick subscription status lookups
CREATE INDEX IF NOT EXISTS idx_profiles_is_subscribed ON profiles(is_subscribed);
CREATE INDEX IF NOT EXISTS idx_profiles_subscription_expires_at ON profiles(subscription_expires_at);

-- ============================================================================
-- Function: Update Profile Subscription Status
-- ============================================================================
-- Updates the user's profile when their subscription changes
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
    ELSE v_tier := 'Gold';
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
      ELSE 'Free'
    END,
    updated_at = NOW()
  WHERE id = NEW.user_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- Trigger: Auto-update Profile on Subscription Insert/Update
-- ============================================================================
DROP TRIGGER IF EXISTS trigger_update_profile_subscription ON user_subscriptions;

CREATE TRIGGER trigger_update_profile_subscription
  AFTER INSERT OR UPDATE ON user_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_subscription_status();

-- ============================================================================
-- Function: Check Expired Subscriptions and Update Profiles
-- ============================================================================
-- Run this periodically (e.g., via cron job) to expire subscriptions
CREATE OR REPLACE FUNCTION expire_old_subscriptions()
RETURNS void AS $$
BEGIN
  -- Update expired subscriptions to inactive
  UPDATE user_subscriptions
  SET status = 'expired'
  WHERE status = 'active'
    AND end_date < NOW();

  -- Update profiles for users with expired subscriptions
  UPDATE profiles p
  SET
    is_subscribed = false,
    subscription_tier = 'Free',
    subscription_expires_at = NULL,
    current_tier = 'Free',
    updated_at = NOW()
  WHERE p.is_subscribed = true
    AND NOT EXISTS (
      SELECT 1 FROM user_subscriptions us
      WHERE us.user_id = p.id
        AND us.status = 'active'
        AND us.end_date > NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- Function: Get User Subscription Status (Quick Check)
-- ============================================================================
CREATE OR REPLACE FUNCTION get_subscription_status(p_user_id UUID)
RETURNS TABLE (
  is_subscribed BOOLEAN,
  tier TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  days_remaining INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.is_subscribed,
    p.subscription_tier,
    p.subscription_expires_at,
    CASE
      WHEN p.subscription_expires_at IS NOT NULL THEN
        EXTRACT(DAY FROM (p.subscription_expires_at - NOW()))::INTEGER
      ELSE NULL
    END as days_remaining
  FROM profiles p
  WHERE p.id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- Backfill: Update existing profiles with current subscription status
-- ============================================================================
-- Run this once to sync existing data
DO $$
DECLARE
  sub_record RECORD;
BEGIN
  FOR sub_record IN
    SELECT user_id, plan_id, status, end_date
    FROM user_subscriptions
    WHERE status = 'active'
      AND end_date > NOW()
  LOOP
    PERFORM update_profile_subscription_status();
  END LOOP;
END $$;

-- ============================================================================
-- Grant permissions
-- ============================================================================
GRANT EXECUTE ON FUNCTION get_subscription_status(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION expire_old_subscriptions() TO service_role;

-- ============================================================================
-- Comments
-- ============================================================================
COMMENT ON COLUMN profiles.is_subscribed IS
  'Quick boolean flag indicating if user has an active subscription. Auto-updated by trigger.';

COMMENT ON COLUMN profiles.subscription_tier IS
  'User subscription tier (Free, Gold, Platinum, Black). Auto-updated by trigger.';

COMMENT ON COLUMN profiles.subscription_expires_at IS
  'When the current subscription expires. NULL if not subscribed. Auto-updated by trigger.';

COMMENT ON FUNCTION update_profile_subscription_status() IS
  'Trigger function that automatically updates profile subscription status when user_subscriptions changes.';

COMMENT ON FUNCTION expire_old_subscriptions() IS
  'Batch function to expire old subscriptions and update profiles. Should be run periodically via cron.';

COMMENT ON FUNCTION get_subscription_status(UUID) IS
  'Quick function to get user subscription status with days remaining calculation.';
