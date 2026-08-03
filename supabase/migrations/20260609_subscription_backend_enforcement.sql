-- =====================================================
-- SUBSCRIPTION BACKEND ENFORCEMENT
-- =====================================================
-- Created: June 9, 2026
-- Purpose: Enforce subscription checks server-side
-- Security: Prevent client-side time manipulation attacks
-- =====================================================

-- =====================================================
-- 1. SCHEDULE CRON JOB FOR AUTO-EXPIRY
-- =====================================================
-- This ensures subscriptions expire automatically using SERVER time
-- Runs every hour to check for expired subscriptions

-- First, ensure pg_cron extension is enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule the job (runs every hour at minute 0)
SELECT cron.schedule(
  'expire-old-subscriptions',
  '0 * * * *',
  $$SELECT expire_old_subscriptions()$$
);

-- =====================================================
-- 2. HELPER FUNCTION: Check if user has active subscription
-- =====================================================
-- Uses SERVER time (not client time) for validation

CREATE OR REPLACE FUNCTION user_has_active_subscription(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM user_subscriptions
    WHERE user_id = p_user_id
      AND status = 'active'
      AND end_date > NOW()  -- SERVER TIME!
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. HELPER FUNCTION: Get user's current tier
-- =====================================================
-- Returns tier based on active subscription with SERVER time validation

CREATE OR REPLACE FUNCTION get_user_current_tier(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
  v_tier TEXT;
BEGIN
  SELECT tier INTO v_tier
  FROM user_subscriptions
  WHERE user_id = p_user_id
    AND status = 'active'
    AND end_date > NOW()  -- SERVER TIME!
  ORDER BY created_at DESC
  LIMIT 1;

  RETURN COALESCE(v_tier, 'Free');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 4. HELPER FUNCTION: Check if user meets tier requirement
-- =====================================================
-- Validates tier hierarchy server-side

CREATE OR REPLACE FUNCTION user_meets_tier_requirement(
  p_user_id UUID,
  p_required_tier TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  v_user_tier TEXT;
  v_tier_hierarchy TEXT[] := ARRAY['Free', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Black'];
  v_user_tier_level INT;
  v_required_tier_level INT;
BEGIN
  -- Get user's current tier (with server time validation)
  v_user_tier := get_user_current_tier(p_user_id);

  -- Find tier levels
  SELECT idx INTO v_user_tier_level
  FROM unnest(v_tier_hierarchy) WITH ORDINALITY AS t(tier, idx)
  WHERE tier = v_user_tier;

  SELECT idx INTO v_required_tier_level
  FROM unnest(v_tier_hierarchy) WITH ORDINALITY AS t(tier, idx)
  WHERE tier = p_required_tier;

  -- Compare levels
  RETURN COALESCE(v_user_tier_level, 0) >= COALESCE(v_required_tier_level, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 5. RLS POLICY: Tier-based event access (if needed)
-- =====================================================
-- Uncomment if you want to restrict certain events by tier
-- For now, we'll add a metadata-based approach

-- Add column to events for tier requirement (optional)
ALTER TABLE events
  ADD COLUMN IF NOT EXISTS required_tier TEXT DEFAULT 'Free'
  CHECK (required_tier IN ('Free', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Black'));

-- Create index for required_tier
CREATE INDEX IF NOT EXISTS idx_events_required_tier ON events(required_tier);

-- RLS Policy: Users can only see events they have access to
DROP POLICY IF EXISTS "users_can_view_events_by_tier" ON events;

CREATE POLICY "users_can_view_events_by_tier"
ON events
FOR SELECT
USING (
  -- Public events (Free tier) are visible to everyone
  required_tier = 'Free'
  OR
  -- For tier-restricted events, check user's subscription
  user_meets_tier_requirement(auth.uid(), required_tier)
);

-- =====================================================
-- 6. RLS POLICY: Subscription-based booking creation
-- =====================================================
-- Ensure users can only book events they have access to

DROP POLICY IF EXISTS "users_can_book_with_valid_tier" ON bookings;

CREATE POLICY "users_can_book_with_valid_tier"
ON bookings
FOR INSERT
WITH CHECK (
  -- Check if user has access to the event's required tier
  EXISTS (
    SELECT 1
    FROM events e
    WHERE e.id = event_id
      AND (
        e.required_tier = 'Free'
        OR
        user_meets_tier_requirement(auth.uid(), e.required_tier)
      )
  )
);

-- =====================================================
-- 7. UPDATE EXISTING EVENTS (Set all to Free tier)
-- =====================================================
-- Mark all existing events as accessible to everyone
-- You can manually update specific events to require higher tiers

UPDATE events
SET required_tier = 'Free'
WHERE required_tier IS NULL;

-- =====================================================
-- 8. FUNCTION: Verify subscription before critical operations
-- =====================================================
-- Use this in your Edge Functions for additional security

CREATE OR REPLACE FUNCTION verify_subscription_access(
  p_user_id UUID,
  p_required_tier TEXT DEFAULT 'Free'
)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
  v_has_access BOOLEAN;
  v_current_tier TEXT;
  v_subscription RECORD;
BEGIN
  -- Get current tier
  v_current_tier := get_user_current_tier(p_user_id);

  -- Check access
  v_has_access := user_meets_tier_requirement(p_user_id, p_required_tier);

  -- Get subscription details
  SELECT
    status,
    end_date,
    tier,
    plan_id
  INTO v_subscription
  FROM user_subscriptions
  WHERE user_id = p_user_id
    AND status = 'active'
    AND end_date > NOW()
  ORDER BY created_at DESC
  LIMIT 1;

  -- Build result
  v_result := jsonb_build_object(
    'hasAccess', v_has_access,
    'currentTier', v_current_tier,
    'requiredTier', p_required_tier,
    'isSubscribed', v_subscription.status IS NOT NULL,
    'subscriptionStatus', COALESCE(v_subscription.status, 'none'),
    'expiresAt', v_subscription.end_date,
    'planId', v_subscription.plan_id
  );

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 9. UPDATE PROFILES SYNC TRIGGER
-- =====================================================
-- Ensure profiles table is always in sync with user_subscriptions
-- This improves the existing sync_profile_tier() function

DROP TRIGGER IF EXISTS sync_tier_on_subscription_change ON user_subscriptions;

CREATE OR REPLACE FUNCTION sync_profile_on_subscription_change()
RETURNS TRIGGER AS $$
DECLARE
  v_is_subscribed BOOLEAN;
  v_tier TEXT;
  v_expires_at TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Determine if user has any active subscription
  SELECT
    COUNT(*) > 0,
    MAX(tier),
    MAX(end_date)
  INTO v_is_subscribed, v_tier, v_expires_at
  FROM user_subscriptions
  WHERE user_id = COALESCE(NEW.user_id, OLD.user_id)
    AND status = 'active'
    AND end_date > NOW();

  -- Update profile with current subscription status
  UPDATE profiles
  SET
    current_tier = COALESCE(v_tier, 'Free'),
    is_subscribed = COALESCE(v_is_subscribed, false),
    subscription_tier = COALESCE(v_tier, 'Free'),
    subscription_expires_at = v_expires_at,
    updated_at = NOW()
  WHERE id = COALESCE(NEW.user_id, OLD.user_id);

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER sync_profile_on_subscription_change
  AFTER INSERT OR UPDATE OR DELETE ON user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION sync_profile_on_subscription_change();

-- =====================================================
-- 10. ADD MISSING COLUMNS TO PROFILES (if not exist)
-- =====================================================
-- Ensure profiles table has all subscription-related columns

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_subscribed BOOLEAN DEFAULT false;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS subscription_tier TEXT DEFAULT 'Free';

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMP WITH TIME ZONE;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_profiles_is_subscribed ON profiles(is_subscribed);
CREATE INDEX IF NOT EXISTS idx_profiles_subscription_tier ON profiles(subscription_tier);
CREATE INDEX IF NOT EXISTS idx_profiles_subscription_expires_at ON profiles(subscription_expires_at);

-- =====================================================
-- 11. SYNC ALL EXISTING PROFILES
-- =====================================================
-- Update all profiles to match current subscription status

DO $$
DECLARE
  v_profile RECORD;
BEGIN
  FOR v_profile IN SELECT id FROM profiles LOOP
    PERFORM sync_profile_on_subscription_change();
  END LOOP;
END $$;

-- Or simpler approach - update all at once
UPDATE profiles p
SET
  is_subscribed = COALESCE((
    SELECT COUNT(*) > 0
    FROM user_subscriptions us
    WHERE us.user_id = p.id
      AND us.status = 'active'
      AND us.end_date > NOW()
  ), false),
  subscription_tier = COALESCE((
    SELECT tier
    FROM user_subscriptions us
    WHERE us.user_id = p.id
      AND us.status = 'active'
      AND us.end_date > NOW()
    ORDER BY created_at DESC
    LIMIT 1
  ), 'Free'),
  subscription_expires_at = (
    SELECT end_date
    FROM user_subscriptions us
    WHERE us.user_id = p.id
      AND us.status = 'active'
      AND us.end_date > NOW()
    ORDER BY created_at DESC
    LIMIT 1
  );

-- =====================================================
-- 12. TESTING QUERIES
-- =====================================================

-- Test 1: Check if a user has active subscription
-- SELECT user_has_active_subscription('8ea34f17-0369-4133-a229-b5d5d9619b97');

-- Test 2: Get user's current tier
-- SELECT get_user_current_tier('8ea34f17-0369-4133-a229-b5d5d9619b97');

-- Test 3: Check tier requirement
-- SELECT user_meets_tier_requirement('8ea34f17-0369-4133-a229-b5d5d9619b97', 'Gold');

-- Test 4: Verify subscription access
-- SELECT verify_subscription_access('8ea34f17-0369-4133-a229-b5d5d9619b97', 'Platinum');

-- Test 5: Check cron job status
-- SELECT * FROM cron.job WHERE jobname = 'expire-old-subscriptions';

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '✅ Subscription backend enforcement migration complete!';
  RAISE NOTICE '';
  RAISE NOTICE '🔐 Security Features Enabled:';
  RAISE NOTICE '  ✓ Cron job scheduled: expire-old-subscriptions (runs every hour)';
  RAISE NOTICE '  ✓ Server-side expiry validation (immune to client time manipulation)';
  RAISE NOTICE '  ✓ Tier-based RLS policies for events and bookings';
  RAISE NOTICE '  ✓ Helper functions for subscription validation';
  RAISE NOTICE '  ✓ Profile sync trigger updated';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Next Steps:';
  RAISE NOTICE '  1. Test with: SELECT verify_subscription_access(auth.uid(), ''Gold'');';
  RAISE NOTICE '  2. Mark premium events: UPDATE events SET required_tier = ''Gold'' WHERE id = ''...'';';
  RAISE NOTICE '  3. Update app to call verify_subscription_access() before critical operations';
  RAISE NOTICE '';
  RAISE NOTICE '🎯 Backend checks now enforce subscription access!';
END $$;
