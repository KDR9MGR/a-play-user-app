-- ============================================================================
-- CLEAR ALL USERS AND DATA - START FROM SCRATCH
-- ============================================================================
-- WARNING: This will delete ALL users and ALL user-related data
-- This action is IRREVERSIBLE
-- ============================================================================

-- Disable triggers temporarily to avoid issues
SET session_replication_role = replica;

-- ============================================================================
-- 1. DELETE ALL USER-RELATED DATA (in correct order to avoid FK violations)
-- ============================================================================

-- Chat and social features
DELETE FROM chat_messages;
DELETE FROM chat_participants;
DELETE FROM chats;
DELETE FROM friendships;
DELETE FROM post_gifts;
DELETE FROM post_likes;
DELETE FROM post_comments;
DELETE FROM posts;

-- Bookings and events
DELETE FROM booking_cancellations;
DELETE FROM bookings;
DELETE FROM event_categories;
DELETE FROM event_images;

-- Restaurant and club
DELETE FROM restaurant_bookings;
DELETE FROM club_bookings;

-- Concierge
DELETE FROM concierge_requests;

-- Subscriptions and payments
DELETE FROM user_subscriptions;
DELETE FROM subscriptions;
DELETE FROM subscription_plans;
DELETE FROM user_points;
DELETE FROM payment_history;

-- Referrals
DELETE FROM referrals;

-- Podcasts and media
DELETE FROM podcast_episodes;
DELETE FROM podcasts;

-- User profiles and auth
DELETE FROM profiles;

-- ============================================================================
-- 2. DELETE ALL AUTH USERS (from auth.users table)
-- ============================================================================
-- NOTE: This requires service_role or admin privileges
-- If running from Supabase Dashboard SQL Editor, this will work
-- If you get permission errors, run this from the Authentication > Users section instead

DELETE FROM auth.users;

-- ============================================================================
-- 3. RESET SEQUENCES (optional - resets auto-increment IDs)
-- ============================================================================
-- Uncomment if you want to reset ID sequences

-- ALTER SEQUENCE IF EXISTS profiles_id_seq RESTART WITH 1;
-- ALTER SEQUENCE IF EXISTS bookings_id_seq RESTART WITH 1;
-- ALTER SEQUENCE IF EXISTS posts_id_seq RESTART WITH 1;
-- Add more sequences as needed...

-- ============================================================================
-- 4. RE-ENABLE TRIGGERS
-- ============================================================================
SET session_replication_role = DEFAULT;

-- ============================================================================
-- 5. VERIFY DELETION
-- ============================================================================
DO $$
DECLARE
  user_count INTEGER;
  profile_count INTEGER;
  subscription_count INTEGER;
  booking_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM profiles;
  SELECT COUNT(*) INTO subscription_count FROM user_subscriptions;
  SELECT COUNT(*) INTO booking_count FROM bookings;

  RAISE NOTICE '============================================';
  RAISE NOTICE 'DELETION COMPLETE';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Auth Users: %', user_count;
  RAISE NOTICE 'Profiles: %', profile_count;
  RAISE NOTICE 'Subscriptions: %', subscription_count;
  RAISE NOTICE 'Bookings: %', booking_count;
  RAISE NOTICE '============================================';

  IF user_count = 0 AND profile_count = 0 THEN
    RAISE NOTICE '✅ All users successfully deleted!';
  ELSE
    RAISE WARNING '⚠️  Some users may remain - check permissions';
  END IF;
END $$;
