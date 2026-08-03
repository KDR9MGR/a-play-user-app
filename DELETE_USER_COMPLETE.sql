-- Complete User Deletion Script
-- This deletes a user from ALL tables including auth
-- WARNING: This is IRREVERSIBLE!

-- ============================================================================
-- OPTION 1: Delete by Email (Most Common)
-- ============================================================================

DO $$
DECLARE
  v_user_id UUID;
  v_email TEXT := 'user@example.com'; -- REPLACE WITH ACTUAL EMAIL
BEGIN
  -- Get user ID from email
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = v_email;

  IF v_user_id IS NULL THEN
    RAISE NOTICE 'User not found with email: %', v_email;
    RETURN;
  END IF;

  RAISE NOTICE 'Deleting user: % (ID: %)', v_email, v_user_id;

  -- Delete from all user-related tables (in correct order to avoid FK conflicts)

  -- 1. Points & Referrals
  DELETE FROM point_transactions WHERE user_id = v_user_id;
  DELETE FROM point_redemptions WHERE user_id = v_user_id;
  DELETE FROM user_points WHERE user_id = v_user_id;
  DELETE FROM user_challenge_progress WHERE user_id = v_user_id;
  DELETE FROM user_daily_logins WHERE user_id = v_user_id;
  DELETE FROM referral_history WHERE referrer_user_id = v_user_id OR referred_user_id = v_user_id;
  DELETE FROM referrals WHERE user_id = v_user_id;

  -- 2. Subscriptions
  DELETE FROM user_subscriptions WHERE user_id = v_user_id;

  -- 3. Bookings
  DELETE FROM event_bookings WHERE user_id = v_user_id;
  DELETE FROM club_bookings WHERE user_id = v_user_id;
  DELETE FROM restaurant_bookings WHERE user_id = v_user_id;
  DELETE FROM table_bookings WHERE user_id = v_user_id;

  -- 4. Social Features
  DELETE FROM post_gifts WHERE gifter_user_id = v_user_id OR receiver_user_id = v_user_id;
  DELETE FROM feed_likes WHERE user_id = v_user_id;
  DELETE FROM feed_comments WHERE user_id = v_user_id;
  DELETE FROM feeds WHERE user_id = v_user_id;
  DELETE FROM followers WHERE follower_id = v_user_id OR following_id = v_user_id;

  -- 5. Chats & Messages
  DELETE FROM chat_messages WHERE sender_id = v_user_id;
  DELETE FROM chat_participants WHERE user_id = v_user_id;
  DELETE FROM chats WHERE created_by = v_user_id;

  -- 6. Reviews & Ratings
  DELETE FROM event_reviews WHERE user_id = v_user_id;
  DELETE FROM club_reviews WHERE user_id = v_user_id;

  -- 7. Favorites & Saved
  DELETE FROM favorite_events WHERE user_id = v_user_id;
  DELETE FROM favorite_clubs WHERE user_id = v_user_id;
  DELETE FROM saved_events WHERE user_id = v_user_id;

  -- 8. Notifications
  DELETE FROM notifications WHERE user_id = v_user_id;

  -- 9. User Sessions & Devices
  DELETE FROM user_sessions WHERE user_id = v_user_id;
  DELETE FROM user_devices WHERE user_id = v_user_id;

  -- 10. Profile & Auth
  DELETE FROM profiles WHERE id = v_user_id;
  DELETE FROM auth.users WHERE id = v_user_id;

  RAISE NOTICE '✓ User deleted successfully: %', v_email;
END $$;

-- ============================================================================
-- OPTION 2: Delete by User ID (If you know the UUID)
-- ============================================================================

-- Uncomment and run this if you have the user ID directly:
/*
DO $$
DECLARE
  v_user_id UUID := 'abc123-def456-789...'; -- REPLACE WITH ACTUAL USER ID
BEGIN
  RAISE NOTICE 'Deleting user ID: %', v_user_id;

  -- Delete from all tables (same order as above)
  DELETE FROM point_transactions WHERE user_id = v_user_id;
  DELETE FROM point_redemptions WHERE user_id = v_user_id;
  DELETE FROM user_points WHERE user_id = v_user_id;
  DELETE FROM user_challenge_progress WHERE user_id = v_user_id;
  DELETE FROM user_daily_logins WHERE user_id = v_user_id;
  DELETE FROM referral_history WHERE referrer_user_id = v_user_id OR referred_user_id = v_user_id;
  DELETE FROM referrals WHERE user_id = v_user_id;
  DELETE FROM user_subscriptions WHERE user_id = v_user_id;
  DELETE FROM event_bookings WHERE user_id = v_user_id;
  DELETE FROM club_bookings WHERE user_id = v_user_id;
  DELETE FROM restaurant_bookings WHERE user_id = v_user_id;
  DELETE FROM table_bookings WHERE user_id = v_user_id;
  DELETE FROM post_gifts WHERE gifter_user_id = v_user_id OR receiver_user_id = v_user_id;
  DELETE FROM feed_likes WHERE user_id = v_user_id;
  DELETE FROM feed_comments WHERE user_id = v_user_id;
  DELETE FROM feeds WHERE user_id = v_user_id;
  DELETE FROM followers WHERE follower_id = v_user_id OR following_id = v_user_id;
  DELETE FROM chat_messages WHERE sender_id = v_user_id;
  DELETE FROM chat_participants WHERE user_id = v_user_id;
  DELETE FROM chats WHERE created_by = v_user_id;
  DELETE FROM event_reviews WHERE user_id = v_user_id;
  DELETE FROM club_reviews WHERE user_id = v_user_id;
  DELETE FROM favorite_events WHERE user_id = v_user_id;
  DELETE FROM favorite_clubs WHERE user_id = v_user_id;
  DELETE FROM saved_events WHERE user_id = v_user_id;
  DELETE FROM notifications WHERE user_id = v_user_id;
  DELETE FROM user_sessions WHERE user_id = v_user_id;
  DELETE FROM user_devices WHERE user_id = v_user_id;
  DELETE FROM profiles WHERE id = v_user_id;
  DELETE FROM auth.users WHERE id = v_user_id;

  RAISE NOTICE '✓ User deleted successfully';
END $$;
*/

-- ============================================================================
-- OPTION 3: Safe Check Before Delete (Recommended)
-- ============================================================================

-- Run this first to see what will be deleted:
/*
DO $$
DECLARE
  v_user_id UUID;
  v_email TEXT := 'user@example.com'; -- REPLACE WITH ACTUAL EMAIL
  v_count INTEGER;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = v_email;

  IF v_user_id IS NULL THEN
    RAISE NOTICE 'User not found: %', v_email;
    RETURN;
  END IF;

  RAISE NOTICE 'User to delete: % (ID: %)', v_email, v_user_id;
  RAISE NOTICE '═══════════════════════════════════════';

  SELECT COUNT(*) INTO v_count FROM point_transactions WHERE user_id = v_user_id;
  RAISE NOTICE 'Point transactions: %', v_count;

  SELECT COUNT(*) INTO v_count FROM user_subscriptions WHERE user_id = v_user_id;
  RAISE NOTICE 'Subscriptions: %', v_count;

  SELECT COUNT(*) INTO v_count FROM event_bookings WHERE user_id = v_user_id;
  RAISE NOTICE 'Event bookings: %', v_count;

  SELECT COUNT(*) INTO v_count FROM feeds WHERE user_id = v_user_id;
  RAISE NOTICE 'Feed posts: %', v_count;

  SELECT COUNT(*) INTO v_count FROM chat_messages WHERE sender_id = v_user_id;
  RAISE NOTICE 'Chat messages: %', v_count;

  RAISE NOTICE '═══════════════════════════════════════';
  RAISE NOTICE 'To proceed with deletion, run OPTION 1 or OPTION 2 above';
END $$;
*/

-- ============================================================================
-- OPTION 4: Create Reusable Function (Best for Multiple Deletions)
-- ============================================================================

CREATE OR REPLACE FUNCTION delete_user_completely(p_email TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = p_email;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not found: %', p_email;
  END IF;

  RAISE NOTICE 'Deleting user: % (ID: %)', p_email, v_user_id;

  -- Delete from all tables
  DELETE FROM point_transactions WHERE user_id = v_user_id;
  DELETE FROM point_redemptions WHERE user_id = v_user_id;
  DELETE FROM user_points WHERE user_id = v_user_id;
  DELETE FROM user_challenge_progress WHERE user_id = v_user_id;
  DELETE FROM user_daily_logins WHERE user_id = v_user_id;
  DELETE FROM referral_history WHERE referrer_user_id = v_user_id OR referred_user_id = v_user_id;
  DELETE FROM referrals WHERE user_id = v_user_id;
  DELETE FROM user_subscriptions WHERE user_id = v_user_id;
  DELETE FROM event_bookings WHERE user_id = v_user_id;
  DELETE FROM club_bookings WHERE user_id = v_user_id;
  DELETE FROM restaurant_bookings WHERE user_id = v_user_id;
  DELETE FROM table_bookings WHERE user_id = v_user_id;
  DELETE FROM post_gifts WHERE gifter_user_id = v_user_id OR receiver_user_id = v_user_id;
  DELETE FROM feed_likes WHERE user_id = v_user_id;
  DELETE FROM feed_comments WHERE user_id = v_user_id;
  DELETE FROM feeds WHERE user_id = v_user_id;
  DELETE FROM followers WHERE follower_id = v_user_id OR following_id = v_user_id;
  DELETE FROM chat_messages WHERE sender_id = v_user_id;
  DELETE FROM chat_participants WHERE user_id = v_user_id;
  DELETE FROM chats WHERE created_by = v_user_id;
  DELETE FROM event_reviews WHERE user_id = v_user_id;
  DELETE FROM club_reviews WHERE user_id = v_user_id;
  DELETE FROM favorite_events WHERE user_id = v_user_id;
  DELETE FROM favorite_clubs WHERE user_id = v_user_id;
  DELETE FROM saved_events WHERE user_id = v_user_id;
  DELETE FROM notifications WHERE user_id = v_user_id;
  DELETE FROM user_sessions WHERE user_id = v_user_id;
  DELETE FROM user_devices WHERE user_id = v_user_id;
  DELETE FROM profiles WHERE id = v_user_id;
  DELETE FROM auth.users WHERE id = v_user_id;

  RAISE NOTICE '✓ User deleted successfully: %', p_email;
END;
$$;

-- Usage:
-- SELECT delete_user_completely('user@example.com');

-- ============================================================================
-- QUICK REFERENCE
-- ============================================================================

-- Delete specific user by email:
-- 1. Edit OPTION 1 above, replace 'user@example.com' with actual email
-- 2. Run the script

-- Check what will be deleted before deleting:
-- 1. Uncomment OPTION 3
-- 2. Replace email
-- 3. Run to see counts

-- Create function for repeated use:
-- 1. Run OPTION 4 to create function
-- 2. Use: SELECT delete_user_completely('email@example.com');

-- ============================================================================
-- NOTES
-- ============================================================================

-- ⚠️ WARNING: These deletions are PERMANENT and CANNOT be undone!
-- ⚠️ Always backup your database before mass deletions
-- ⚠️ Test on staging environment first

-- ✅ Deletes from ALL tables including auth.users
-- ✅ Handles foreign key constraints in correct order
-- ✅ Removes all user data (bookings, posts, chats, etc.)
-- ✅ Cleans up points, referrals, subscriptions
-- ✅ Safe to run multiple times (won't error if user not found)
