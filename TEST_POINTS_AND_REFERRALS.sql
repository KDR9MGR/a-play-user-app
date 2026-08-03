-- Test and Verify Points & Referrals System
-- Date: June 6, 2026
-- Purpose: Ensure all points and referrals functionality works correctly

-- ============================================================================
-- PART 1: Verify System Setup
-- ============================================================================

-- 1. Check all tables exist
SELECT
  'Tables Check' as test_name,
  COUNT(*) as count,
  CASE WHEN COUNT(*) = 9 THEN 'PASS ✅' ELSE 'FAIL ❌' END as status
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'user_points', 'point_transactions', 'referrals', 'referral_history',
    'membership_tiers', 'user_challenges', 'user_challenge_progress',
    'time_limited_offers', 'user_daily_logins'
  );

-- 2. Check functions exist
SELECT
  'Functions Check' as test_name,
  COUNT(*) as count,
  CASE WHEN COUNT(*) >= 3 THEN 'PASS ✅' ELSE 'FAIL ❌' END as status
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('apply_referral_code', 'get_user_points_with_tier', 'update_points_on_transaction');

-- 3. Check triggers exist
SELECT
  'Triggers Check' as test_name,
  COUNT(*) as count,
  CASE WHEN COUNT(*) >= 1 THEN 'PASS ✅' ELSE 'FAIL ❌' END as status
FROM information_schema.triggers
WHERE event_object_table = 'point_transactions'
  AND trigger_name = 'update_points_on_transaction';

-- 4. Check membership tiers populated
SELECT
  'Membership Tiers' as test_name,
  COUNT(*) as count,
  CASE WHEN COUNT(*) >= 5 THEN 'PASS ✅' ELSE 'FAIL ❌' END as status
FROM membership_tiers;

-- 5. Check challenges populated
SELECT
  'Active Challenges' as test_name,
  COUNT(*) as count,
  CASE WHEN COUNT(*) >= 5 THEN 'PASS ✅' ELSE 'FAIL ❌' END as status
FROM user_challenges
WHERE active = true;

-- ============================================================================
-- PART 2: Check Data Integrity
-- ============================================================================

-- List all membership tiers
SELECT
  '=== MEMBERSHIP TIERS ===' as section,
  name,
  min_points,
  max_points,
  array_length(benefits, 1) as benefit_count
FROM membership_tiers
ORDER BY min_points;

-- List all active challenges
SELECT
  '=== ACTIVE CHALLENGES ===' as section,
  name,
  challenge_type,
  target_count,
  period_days,
  reward_points
FROM user_challenges
WHERE active = true
ORDER BY reward_points;

-- ============================================================================
-- PART 3: Test with Sandbox User
-- ============================================================================

-- Check if sandbox user has user_points record
SELECT
  '=== SANDBOX USER POINTS ===' as section,
  p.email,
  COALESCE(up.total_points, 0) as total_points,
  COALESCE(up.available_points, 0) as available_points,
  COALESCE(up.used_points, 0) as used_points,
  CASE
    WHEN up.user_id IS NOT NULL THEN 'Has Points Record ✅'
    ELSE 'Missing Points Record ❌'
  END as status
FROM profiles p
LEFT JOIN user_points up ON p.id = up.user_id
WHERE p.email = 'sylonow.test@gmail.com';

-- Check if sandbox user has referral code
SELECT
  '=== SANDBOX USER REFERRAL ===' as section,
  p.email,
  COALESCE(r.referral_code, 'NOT CREATED') as referral_code,
  COALESCE(r.referral_count, 0) as referral_count,
  CASE
    WHEN r.user_id IS NOT NULL THEN 'Has Referral Code ✅'
    ELSE 'No Referral Code (Subscribe First) ⚠️'
  END as status
FROM profiles p
LEFT JOIN referrals r ON p.id = r.user_id
WHERE p.email = 'sylonow.test@gmail.com';

-- Check sandbox user's recent point transactions
SELECT
  '=== RECENT POINT TRANSACTIONS ===' as section,
  transaction_type,
  points,
  description,
  created_at
FROM point_transactions
WHERE user_id = (SELECT id FROM profiles WHERE email = 'sylonow.test@gmail.com')
ORDER BY created_at DESC
LIMIT 5;

-- ============================================================================
-- PART 4: Create Test Data (if needed)
-- ============================================================================

-- Create user_points if missing for sandbox user
INSERT INTO user_points (id, user_id, total_points, available_points, used_points)
SELECT
  gen_random_uuid(),
  id,
  0,
  0,
  0
FROM profiles
WHERE email = 'sylonow.test@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM user_points WHERE user_id = profiles.id
  );

-- Create referral code if user is subscribed but doesn't have one
INSERT INTO referrals (user_id, referral_code, referral_count)
SELECT
  p.id,
  'REF' || UPPER(SUBSTRING(p.id::text, 1, 8)),
  0
FROM profiles p
WHERE p.email = 'sylonow.test@gmail.com'
  AND p.is_subscribed = true
  AND NOT EXISTS (
    SELECT 1 FROM referrals WHERE user_id = p.id
  );

-- ============================================================================
-- PART 5: Test Functionality
-- ============================================================================

-- Test 1: Award Daily Login Points (5 points)
DO $$
DECLARE
  v_user_id UUID;
  v_today TEXT;
  v_exists BOOLEAN;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id FROM profiles WHERE email = 'sylonow.test@gmail.com';

  IF v_user_id IS NULL THEN
    RAISE NOTICE 'User not found';
    RETURN;
  END IF;

  -- Get today's date
  v_today := TO_CHAR(NOW(), 'YYYY-MM-DD');

  -- Check if already logged in today
  SELECT EXISTS(
    SELECT 1 FROM user_daily_logins
    WHERE user_id = v_user_id
      AND login_date = v_today
      AND points_awarded = true
  ) INTO v_exists;

  IF v_exists THEN
    RAISE NOTICE 'TEST: Daily login - Already awarded today ⚠️';
    RETURN;
  END IF;

  -- Record login
  INSERT INTO user_daily_logins (user_id, login_date, points_awarded)
  VALUES (v_user_id, v_today, true)
  ON CONFLICT (user_id, login_date)
  DO UPDATE SET points_awarded = true;

  -- Award points
  INSERT INTO point_transactions (id, user_id, points, transaction_type, description)
  VALUES (gen_random_uuid(), v_user_id, 5, 'daily_login', 'Daily login reward');

  RAISE NOTICE 'TEST: Daily login - 5 points awarded ✅';
END $$;

-- Test 2: Check if points were updated
SELECT
  'TEST: Points Update' as test_name,
  total_points,
  available_points,
  CASE
    WHEN total_points >= 5 THEN 'Points awarded ✅'
    ELSE 'Points not updated ❌'
  END as status
FROM user_points
WHERE user_id = (SELECT id FROM profiles WHERE email = 'sylonow.test@gmail.com');

-- ============================================================================
-- PART 6: Verification Summary
-- ============================================================================

-- Final status check
SELECT
  '=== FINAL VERIFICATION ===' as section,
  (SELECT COUNT(*) FROM membership_tiers) as membership_tiers,
  (SELECT COUNT(*) FROM user_challenges WHERE active = true) as active_challenges,
  (SELECT COUNT(*) FROM user_points WHERE user_id = (SELECT id FROM profiles WHERE email = 'sylonow.test@gmail.com')) as user_has_points,
  (SELECT COUNT(*) FROM referrals WHERE user_id = (SELECT id FROM profiles WHERE email = 'sylonow.test@gmail.com')) as user_has_referral_code,
  (SELECT COALESCE(SUM(points), 0) FROM point_transactions WHERE user_id = (SELECT id FROM profiles WHERE email = 'sylonow.test@gmail.com')) as total_points_earned;

-- ============================================================================
-- EXPECTED RESULTS
-- ============================================================================

-- Tables Check: PASS ✅ (9 tables)
-- Functions Check: PASS ✅ (3+ functions)
-- Triggers Check: PASS ✅
-- Membership Tiers: PASS ✅ (5 tiers)
-- Active Challenges: PASS ✅ (5+ challenges)
-- Sandbox User Points: Has Points Record ✅
-- Sandbox User Referral: Has Referral Code ✅ (if subscribed)
-- Daily Login Test: Points awarded ✅
-- Points Update Test: Points not updated ✅

-- ============================================================================
-- TROUBLESHOOTING
-- ============================================================================

-- If any test fails, run this to see detailed error info:

-- Check point transaction trigger function
SELECT
  routine_name,
  routine_definition
FROM information_schema.routines
WHERE routine_name = 'update_points_on_transaction';

-- Check if trigger is active
SELECT
  trigger_name,
  event_manipulation,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'point_transactions';

-- Manually test point transaction insertion
/*
INSERT INTO point_transactions (id, user_id, points, transaction_type, description)
SELECT
  gen_random_uuid(),
  id,
  10,
  'test',
  'Manual test transaction'
FROM profiles
WHERE email = 'sylonow.test@gmail.com';

-- Check if points were updated
SELECT total_points, available_points
FROM user_points
WHERE user_id = (SELECT id FROM profiles WHERE email = 'sylonow.test@gmail.com');
*/
