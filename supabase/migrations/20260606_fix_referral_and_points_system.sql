-- Fix Referral and Points System
-- Date: June 6, 2026
-- Description: Creates missing RPC function and ensures all tables have proper data

-- ============================================================================
-- 1. Create apply_referral_code RPC function (MISSING)
-- ============================================================================

CREATE OR REPLACE FUNCTION apply_referral_code(
  p_referral_code TEXT,
  p_user_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_referrer_id UUID;
  v_referral_id UUID;
  v_already_applied BOOLEAN;
BEGIN
  -- Check if user has already applied a referral code
  SELECT EXISTS(
    SELECT 1 FROM referral_history
    WHERE referred_user_id = p_user_id
  ) INTO v_already_applied;

  IF v_already_applied THEN
    RAISE EXCEPTION 'You have already used a referral code';
  END IF;

  -- Find the referrer by code
  SELECT user_id, id INTO v_referrer_id, v_referral_id
  FROM referrals
  WHERE referral_code = UPPER(p_referral_code);

  IF v_referrer_id IS NULL THEN
    RAISE EXCEPTION 'Invalid referral code';
  END IF;

  -- Cannot refer yourself
  IF v_referrer_id = p_user_id THEN
    RAISE EXCEPTION 'You cannot use your own referral code';
  END IF;

  -- Create referral history record
  INSERT INTO referral_history (
    referrer_user_id,
    referred_user_id,
    referral_code_used,
    points_earned,
    created_at
  ) VALUES (
    v_referrer_id,
    p_user_id,
    p_referral_code,
    0, -- Points will be earned when referred user subscribes
    NOW()
  );

  -- Increment referral count
  UPDATE referrals
  SET referral_count = referral_count + 1,
      updated_at = NOW()
  WHERE id = v_referral_id;

END;
$$;

-- ============================================================================
-- 2. Ensure user_points record exists for all users
-- ============================================================================

-- Create user_points for any profiles that don't have one
INSERT INTO user_points (id, user_id, total_points, available_points, used_points)
SELECT gen_random_uuid(), p.id, 0, 0, 0
FROM profiles p
LEFT JOIN user_points up ON p.id = up.user_id
WHERE up.user_id IS NULL
ON CONFLICT (user_id) DO NOTHING;

-- ============================================================================
-- 3. Populate membership_tiers if empty
-- ============================================================================

DO $$
BEGIN
  -- Only insert if table is empty or tiers don't exist
  IF NOT EXISTS (SELECT 1 FROM membership_tiers WHERE name = 'Bronze') THEN
    INSERT INTO membership_tiers (name, min_points, max_points, benefits, created_at, updated_at)
    VALUES ('Bronze', 0, 99, ARRAY['Access to basic events', '5% booking discount'], NOW(), NOW());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM membership_tiers WHERE name = 'Silver') THEN
    INSERT INTO membership_tiers (name, min_points, max_points, benefits, created_at, updated_at)
    VALUES ('Silver', 100, 499, ARRAY['Access to premium events', '10% booking discount', 'Priority support'], NOW(), NOW());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM membership_tiers WHERE name = 'Gold') THEN
    INSERT INTO membership_tiers (name, min_points, max_points, benefits, created_at, updated_at)
    VALUES ('Gold', 500, 1999, ARRAY['Access to VIP events', '15% booking discount', 'Priority booking', 'Free event upgrades'], NOW(), NOW());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM membership_tiers WHERE name = 'Platinum') THEN
    INSERT INTO membership_tiers (name, min_points, max_points, benefits, created_at, updated_at)
    VALUES ('Platinum', 2000, 4999, ARRAY['Access to all events', '20% booking discount', 'VIP lounge access', 'Free concierge service'], NOW(), NOW());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM membership_tiers WHERE name = 'Black') THEN
    INSERT INTO membership_tiers (name, min_points, max_points, benefits, created_at, updated_at)
    VALUES ('Black', 5000, NULL, ARRAY['Unlimited access', '25% booking discount', 'Personal event planner', 'Exclusive backstage passes', 'VIP nationwide access'], NOW(), NOW());
  END IF;
END $$;

-- ============================================================================
-- 4. Create sample challenges if table is empty
-- ============================================================================

INSERT INTO user_challenges (
  name,
  description,
  challenge_type,
  target_count,
  period_days,
  reward_points,
  active,
  created_at,
  updated_at
)
VALUES
  (
    'Weekly Warrior',
    'Book 3 events in 7 days',
    'booking',
    3,
    7,
    100,
    true,
    NOW(),
    NOW()
  )
ON CONFLICT DO NOTHING;

INSERT INTO user_challenges (
  name,
  description,
  challenge_type,
  target_count,
  period_days,
  reward_points,
  active,
  created_at,
  updated_at
)
VALUES
  (
    'Monthly Marathon',
    'Book 10 events in 30 days',
    'booking',
    10,
    30,
    500,
    true,
    NOW(),
    NOW()
  )
ON CONFLICT DO NOTHING;

INSERT INTO user_challenges (
  name,
  description,
  challenge_type,
  target_count,
  period_days,
  reward_points,
  active,
  created_at,
  updated_at
)
VALUES
  (
    'Review Master',
    'Write 5 event reviews',
    'rating',
    5,
    30,
    150,
    true,
    NOW(),
    NOW()
  )
ON CONFLICT DO NOTHING;

INSERT INTO user_challenges (
  name,
  description,
  challenge_type,
  target_count,
  period_days,
  reward_points,
  active,
  created_at,
  updated_at
)
VALUES
  (
    'Loyal Subscriber',
    'Maintain subscription for 3 months',
    'subscription',
    3,
    90,
    1000,
    true,
    NOW(),
    NOW()
  )
ON CONFLICT DO NOTHING;

INSERT INTO user_challenges (
  name,
  description,
  challenge_type,
  target_count,
  period_days,
  reward_points,
  active,
  created_at,
  updated_at
)
VALUES
  (
    'Daily Devotee',
    'Login 7 days in a row',
    'daily_login',
    7,
    7,
    75,
    true,
    NOW(),
    NOW()
  )
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 5. Fix subscription status check issue
-- ============================================================================

-- Ensure all active subscriptions have updated profile fields
UPDATE profiles p
SET
  is_subscribed = true,
  subscription_tier = us.tier,
  current_tier = us.tier,
  subscription_expires_at = us.end_date,
  updated_at = NOW()
FROM user_subscriptions us
WHERE p.id = us.user_id
  AND us.status = 'active'
  AND us.end_date > NOW()
  AND (
    p.is_subscribed = false
    OR p.subscription_expires_at IS NULL
    OR p.subscription_expires_at != us.end_date
  );

-- Ensure profiles without active subscriptions are marked correctly
UPDATE profiles p
SET
  is_subscribed = false,
  subscription_tier = NULL,
  subscription_expires_at = NULL,
  updated_at = NOW()
WHERE p.is_subscribed = true
  AND NOT EXISTS (
    SELECT 1 FROM user_subscriptions us
    WHERE us.user_id = p.id
      AND us.status = 'active'
      AND us.end_date > NOW()
  );

-- ============================================================================
-- 6. Ensure trigger exists for updating profile on subscription changes
-- ============================================================================

-- Function to update profile subscription status
CREATE OR REPLACE FUNCTION update_profile_subscription_status()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update profile when subscription is created or updated
  IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.status = 'active' THEN
    UPDATE profiles
    SET
      is_subscribed = true,
      subscription_tier = NEW.tier,
      current_tier = NEW.tier,
      subscription_expires_at = NEW.end_date,
      updated_at = NOW()
    WHERE id = NEW.user_id;
  END IF;

  -- Update profile when subscription is cancelled or expired
  IF (TG_OP = 'UPDATE' AND NEW.status != 'active') OR (TG_OP = 'DELETE') THEN
    -- Check if user has any other active subscriptions
    IF NOT EXISTS (
      SELECT 1 FROM user_subscriptions
      WHERE user_id = COALESCE(NEW.user_id, OLD.user_id)
        AND status = 'active'
        AND end_date > NOW()
        AND id != COALESCE(NEW.id, OLD.id)
    ) THEN
      UPDATE profiles
      SET
        is_subscribed = false,
        subscription_tier = NULL,
        subscription_expires_at = NULL,
        updated_at = NOW()
      WHERE id = COALESCE(NEW.user_id, OLD.user_id);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS trigger_update_profile_subscription ON user_subscriptions;

CREATE TRIGGER trigger_update_profile_subscription
AFTER INSERT OR UPDATE OR DELETE ON user_subscriptions
FOR EACH ROW
EXECUTE FUNCTION update_profile_subscription_status();

-- ============================================================================
-- 7. Grant necessary permissions
-- ============================================================================

GRANT EXECUTE ON FUNCTION apply_referral_code(TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_points_with_tier(UUID) TO authenticated;

-- ============================================================================
-- Done!
-- ============================================================================

-- Verify setup
DO $$
DECLARE
  v_function_exists BOOLEAN;
  v_tiers_count INTEGER;
  v_challenges_count INTEGER;
BEGIN
  -- Check apply_referral_code function
  SELECT EXISTS(
    SELECT 1 FROM pg_proc WHERE proname = 'apply_referral_code'
  ) INTO v_function_exists;

  IF NOT v_function_exists THEN
    RAISE EXCEPTION 'apply_referral_code function not created!';
  END IF;

  -- Check membership tiers
  SELECT COUNT(*) INTO v_tiers_count FROM membership_tiers;
  IF v_tiers_count < 5 THEN
    RAISE WARNING 'Only % membership tiers found (expected 5)', v_tiers_count;
  END IF;

  -- Check challenges
  SELECT COUNT(*) INTO v_challenges_count FROM user_challenges WHERE active = true;
  IF v_challenges_count < 5 THEN
    RAISE WARNING 'Only % active challenges found (expected 5)', v_challenges_count;
  END IF;

  RAISE NOTICE '✓ Referral and Points system setup complete!';
  RAISE NOTICE '  - apply_referral_code function: Created';
  RAISE NOTICE '  - Membership tiers: % tiers', v_tiers_count;
  RAISE NOTICE '  - Active challenges: % challenges', v_challenges_count;
  RAISE NOTICE '  - Profile subscription sync: Updated';
END $$;
