-- Fix Sandbox User Subscription Status
-- This ensures the sandbox user's active subscription shows correctly in the app

-- ============================================================================
-- Check current status
-- ============================================================================

-- See what's in the database for your sandbox user
SELECT
  p.id,
  p.email,
  p.is_subscribed,
  p.subscription_tier,
  p.subscription_expires_at,
  (SELECT COUNT(*) FROM user_subscriptions WHERE user_id = p.id AND status = 'active') as active_subs_count
FROM profiles p
WHERE p.email = 'sylonow.test@gmail.com';

-- Check subscription records
SELECT
  id,
  plan_id,
  tier,
  status,
  start_date,
  end_date,
  payment_method
FROM user_subscriptions
WHERE user_id = (SELECT id FROM profiles WHERE email = 'sylonow.test@gmail.com')
ORDER BY created_at DESC;

-- ============================================================================
-- Option 1: If subscription exists but profile not synced
-- ============================================================================

-- Run this if user_subscriptions shows active subscription but profile doesn't
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
  AND p.email = 'sylonow.test@gmail.com';

-- ============================================================================
-- Option 2: If no active subscription exists, create one for sandbox testing
-- ============================================================================

-- Choose ONE of these based on which IAP product you purchased:

-- Option 2A: Weekly (7day) - $3.99
INSERT INTO user_subscriptions (
  user_id,
  plan_id,
  plan_type,
  tier,
  status,
  subscription_type,
  billing_cycle,
  amount,
  currency,
  start_date,
  end_date,
  payment_method,
  tier_points_earned,
  created_at
)
SELECT
  id,
  'weekly_plan',
  'weekly',
  'Gold',
  'active',
  'premium',
  'weekly',
  3.99,
  'USD',
  NOW(),
  NOW() + INTERVAL '7 days',
  'apple_iap',
  50,
  NOW()
FROM profiles
WHERE email = 'sylonow.test@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM user_subscriptions
    WHERE user_id = profiles.id
      AND status = 'active'
      AND end_date > NOW()
  );

-- Option 2B: Monthly (1month) - $12.99
/*
INSERT INTO user_subscriptions (
  user_id,
  plan_id,
  plan_type,
  tier,
  status,
  subscription_type,
  billing_cycle,
  amount,
  currency,
  start_date,
  end_date,
  payment_method,
  tier_points_earned,
  created_at
)
SELECT
  id,
  'monthly_plan',
  'monthly',
  'Platinum',
  'active',
  'premium',
  'monthly',
  12.99,
  'USD',
  NOW(),
  NOW() + INTERVAL '30 days',
  'apple_iap',
  200,
  NOW()
FROM profiles
WHERE email = 'sylonow.test@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM user_subscriptions
    WHERE user_id = profiles.id
      AND status = 'active'
      AND end_date > NOW()
  );
*/

-- Option 2C: Quarterly (3SUB) - $36.99
/*
INSERT INTO user_subscriptions (
  user_id,
  plan_id,
  plan_type,
  tier,
  status,
  subscription_type,
  billing_cycle,
  amount,
  currency,
  start_date,
  end_date,
  payment_method,
  tier_points_earned,
  created_at
)
SELECT
  id,
  'quarterly_plan',
  'quarterly',
  'Platinum',
  'active',
  'premium',
  'quarterly',
  36.99,
  'USD',
  NOW(),
  NOW() + INTERVAL '90 days',
  'apple_iap',
  650,
  NOW()
FROM profiles
WHERE email = 'sylonow.test@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM user_subscriptions
    WHERE user_id = profiles.id
      AND status = 'active'
      AND end_date > NOW()
  );
*/

-- Option 2D: Annual (365day) - $146.99
/*
INSERT INTO user_subscriptions (
  user_id,
  plan_id,
  plan_type,
  tier,
  status,
  subscription_type,
  billing_cycle,
  amount,
  currency,
  start_date,
  end_date,
  payment_method,
  tier_points_earned,
  created_at
)
SELECT
  id,
  'annual_plan',
  'annual',
  'Black',
  'active',
  'premium',
  'annual',
  146.99,
  'USD',
  NOW(),
  NOW() + INTERVAL '365 days',
  'apple_iap',
  3000,
  NOW()
FROM profiles
WHERE email = 'sylonow.test@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM user_subscriptions
    WHERE user_id = profiles.id
      AND status = 'active'
      AND end_date > NOW()
  );
*/

-- This will trigger the database trigger to update the profile automatically

-- ============================================================================
-- Verification
-- ============================================================================

-- Check that it worked
SELECT
  p.id,
  p.email,
  p.is_subscribed,
  p.subscription_tier,
  p.current_tier,
  p.subscription_expires_at,
  us.plan_id,
  us.tier,
  us.status,
  us.end_date
FROM profiles p
LEFT JOIN user_subscriptions us ON p.id = us.user_id AND us.status = 'active'
WHERE p.email = 'sylonow.test@gmail.com';

-- Expected result:
-- is_subscribed = true
-- subscription_tier = 'Platinum'
-- current_tier = 'Platinum'
-- subscription_expires_at = future date
-- plan_id = 'monthly_plan'
-- status = 'active'
