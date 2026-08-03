-- =====================================================
-- DELETE ALL USERS - NUCLEAR OPTION
-- =====================================================
-- ⚠️ WARNING: THIS WILL DELETE ALL USER DATA FROM THE DATABASE
-- USE ONLY FOR: Testing, staging environment reset, development
-- DO NOT RUN IN PRODUCTION WITHOUT COMPLETE BACKUP
-- =====================================================

BEGIN;

-- Disable triggers temporarily for faster deletion
SET session_replication_role = 'replica';

-- 1. Delete booking cancellations
DELETE FROM booking_cancellations;
RAISE NOTICE 'Deleted all booking_cancellations';

-- 2. Delete bookings
DELETE FROM bookings;
RAISE NOTICE 'Deleted all bookings';

-- 3. Delete post gifts
DELETE FROM post_gifts;
RAISE NOTICE 'Deleted all post_gifts';

-- 4. Delete chat messages
DELETE FROM chat_messages;
RAISE NOTICE 'Deleted all chat_messages';

-- 5. Delete chat participants
DELETE FROM chat_participants;
RAISE NOTICE 'Deleted all chat_participants';

-- 6. Delete chat rooms (no user data but cleanup)
DELETE FROM chat_rooms;
RAISE NOTICE 'Deleted all chat_rooms';

-- 7. Delete friendships
DELETE FROM friendships;
RAISE NOTICE 'Deleted all friendships';

-- 8. Delete referrals
DELETE FROM referrals;
RAISE NOTICE 'Deleted all referrals';

-- 9. Delete point redemptions
DELETE FROM point_redemptions;
RAISE NOTICE 'Deleted all point_redemptions';

-- 10. Delete concierge request tracking
DELETE FROM concierge_request_tracking;
RAISE NOTICE 'Deleted all concierge_request_tracking';

-- 11. Delete subscription events
DELETE FROM subscription_events;
RAISE NOTICE 'Deleted all subscription_events';

-- 12. Delete subscriptions (IAP)
DELETE FROM subscriptions;
RAISE NOTICE 'Deleted all subscriptions';

-- 13. Delete user subscriptions
DELETE FROM user_subscriptions;
RAISE NOTICE 'Deleted all user_subscriptions';

-- 14. Delete profiles (cascades to any remaining FK references)
DELETE FROM profiles;
RAISE NOTICE 'Deleted all profiles';

-- Re-enable triggers
SET session_replication_role = 'origin';

COMMIT;

-- =====================================================
-- NOTE: auth.users CANNOT be deleted via SQL
-- =====================================================
-- You must use Supabase Dashboard or Admin API:
-- 1. Go to: https://supabase.com/dashboard/project/YOUR_PROJECT/auth/users
-- 2. Select all users and delete
-- OR use Admin API:
-- const { data, error } = await supabase.auth.admin.listUsers()
-- for (const user of data.users) {
--   await supabase.auth.admin.deleteUser(user.id)
-- }
-- =====================================================

-- Verify all user data deleted
DO $$
DECLARE
  table_counts TEXT := '';
BEGIN
  SELECT INTO table_counts
    'booking_cancellations: ' || (SELECT COUNT(*) FROM booking_cancellations) || E'\n' ||
    'bookings: ' || (SELECT COUNT(*) FROM bookings) || E'\n' ||
    'post_gifts: ' || (SELECT COUNT(*) FROM post_gifts) || E'\n' ||
    'chat_messages: ' || (SELECT COUNT(*) FROM chat_messages) || E'\n' ||
    'chat_participants: ' || (SELECT COUNT(*) FROM chat_participants) || E'\n' ||
    'friendships: ' || (SELECT COUNT(*) FROM friendships) || E'\n' ||
    'referrals: ' || (SELECT COUNT(*) FROM referrals) || E'\n' ||
    'point_redemptions: ' || (SELECT COUNT(*) FROM point_redemptions) || E'\n' ||
    'concierge_request_tracking: ' || (SELECT COUNT(*) FROM concierge_request_tracking) || E'\n' ||
    'subscription_events: ' || (SELECT COUNT(*) FROM subscription_events) || E'\n' ||
    'subscriptions: ' || (SELECT COUNT(*) FROM subscriptions) || E'\n' ||
    'user_subscriptions: ' || (SELECT COUNT(*) FROM user_subscriptions) || E'\n' ||
    'profiles: ' || (SELECT COUNT(*) FROM profiles);

  RAISE NOTICE E'\n=== DELETION COMPLETE ===\nRemaining records:\n%', table_counts;
END $$;
