-- =====================================================
-- DELETE SINGLE USER - COMPLETE REMOVAL
-- =====================================================
-- Purpose: Completely remove a single user from all tables
-- Use case: GDPR deletion, account removal, testing
-- =====================================================
-- USAGE:
-- Replace 'USER_UUID_HERE' with the actual user UUID
-- Example: '550e8400-e29b-41d4-a716-446655440000'
-- =====================================================

-- Set the user ID to delete
\set user_id 'USER_UUID_HERE'

-- Alternatively, use this for parameterized execution:
-- Run with: psql -v user_id='actual-uuid-here' < DELETE_SINGLE_USER.sql

BEGIN;

-- Verify user exists before deletion
DO $$
DECLARE
  v_user_id UUID := :'user_id';
  v_email TEXT;
  v_full_name TEXT;
BEGIN
  -- Get user details for confirmation
  SELECT email, full_name INTO v_email, v_full_name
  FROM profiles
  WHERE id = v_user_id;

  IF v_email IS NULL THEN
    RAISE EXCEPTION 'User with ID % not found in profiles table', v_user_id;
  END IF;

  RAISE NOTICE 'Deleting user: % (%) - ID: %', v_full_name, v_email, v_user_id;
END $$;

-- =====================================================
-- DELETE USER DATA IN CORRECT ORDER
-- =====================================================

-- 1. Delete booking cancellations
DELETE FROM booking_cancellations
WHERE user_id = :'user_id';
RAISE NOTICE '✓ Deleted booking_cancellations';

-- 2. Delete bookings
DELETE FROM bookings
WHERE user_id = :'user_id';
RAISE NOTICE '✓ Deleted bookings';

-- 3. Delete post gifts (as gifter or receiver)
DELETE FROM post_gifts
WHERE gifter_user_id = :'user_id'
   OR receiver_user_id = :'user_id';
RAISE NOTICE '✓ Deleted post_gifts';

-- 4. Delete chat messages
DELETE FROM chat_messages
WHERE sender_id = :'user_id';
RAISE NOTICE '✓ Deleted chat_messages';

-- 5. Delete chat participants
DELETE FROM chat_participants
WHERE user_id = :'user_id';
RAISE NOTICE '✓ Deleted chat_participants';

-- 6. Delete friendships (as user or friend)
DELETE FROM friendships
WHERE user_id = :'user_id'
   OR friend_id = :'user_id';
RAISE NOTICE '✓ Deleted friendships';

-- 7. Delete referrals (as referrer or referred)
DELETE FROM referrals
WHERE referrer_user_id = :'user_id'
   OR referred_user_id = :'user_id';
RAISE NOTICE '✓ Deleted referrals';

-- 8. Delete point redemptions
DELETE FROM point_redemptions
WHERE user_id = :'user_id';
RAISE NOTICE '✓ Deleted point_redemptions';

-- 9. Delete concierge request tracking
DELETE FROM concierge_request_tracking
WHERE user_id = :'user_id';
RAISE NOTICE '✓ Deleted concierge_request_tracking';

-- 10. Delete subscription events
DELETE FROM subscription_events
WHERE user_id = :'user_id';
RAISE NOTICE '✓ Deleted subscription_events';

-- 11. Delete subscriptions (IAP)
DELETE FROM subscriptions
WHERE user_id = :'user_id';
RAISE NOTICE '✓ Deleted subscriptions';

-- 12. Delete user subscriptions
DELETE FROM user_subscriptions
WHERE user_id = :'user_id';
RAISE NOTICE '✓ Deleted user_subscriptions';

-- 13. Delete profile (cascades to any remaining FK references)
DELETE FROM profiles
WHERE id = :'user_id';
RAISE NOTICE '✓ Deleted profile';

COMMIT;

RAISE NOTICE '=== USER DELETION COMPLETE ===';
RAISE NOTICE 'User ID % has been completely removed from all tables', :'user_id';
RAISE NOTICE 'IMPORTANT: You must also delete from auth.users using Supabase Dashboard or Admin API';

-- =====================================================
-- NEXT STEP: DELETE FROM auth.users
-- =====================================================
-- This cannot be done via SQL. Use one of these methods:
--
-- METHOD 1: Supabase Dashboard
-- https://supabase.com/dashboard/project/YOUR_PROJECT/auth/users
-- Find the user and click "Delete User"
--
-- METHOD 2: Supabase Admin API (JavaScript)
-- const { error } = await supabase.auth.admin.deleteUser('USER_UUID_HERE')
--
-- METHOD 3: cURL
-- curl -X DELETE \
--   'https://YOUR_PROJECT.supabase.co/auth/v1/admin/users/USER_UUID_HERE' \
--   -H 'apikey: YOUR_SERVICE_ROLE_KEY' \
--   -H 'Authorization: Bearer YOUR_SERVICE_ROLE_KEY'
-- =====================================================
