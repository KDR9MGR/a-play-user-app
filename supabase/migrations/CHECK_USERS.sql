-- ============================================================================
-- CHECK ALL USERS AND THEIR DATA
-- ============================================================================
-- Run this to see what users exist and how much data they have
-- ============================================================================

-- User count summary
SELECT
  'auth.users' as table_name,
  COUNT(*) as count
FROM auth.users

UNION ALL

SELECT
  'profiles' as table_name,
  COUNT(*) as count
FROM profiles

UNION ALL

SELECT
  'user_subscriptions' as table_name,
  COUNT(*) as count
FROM user_subscriptions

UNION ALL

SELECT
  'bookings' as table_name,
  COUNT(*) as count
FROM bookings

UNION ALL

SELECT
  'posts' as table_name,
  COUNT(*) as count
FROM posts

UNION ALL

SELECT
  'chat_messages' as table_name,
  COUNT(*) as count
FROM chat_messages

ORDER BY count DESC;

-- ============================================================================
-- Detailed user list
-- ============================================================================

SELECT
  u.id,
  u.email,
  u.created_at as user_created_at,
  u.last_sign_in_at,
  p.display_name,
  p.subscription_tier,
  p.is_subscribed,
  (SELECT COUNT(*) FROM user_subscriptions WHERE user_id = u.id) as subscription_count,
  (SELECT COUNT(*) FROM bookings WHERE user_id = u.id) as booking_count,
  (SELECT COUNT(*) FROM posts WHERE user_id = u.id) as post_count
FROM auth.users u
LEFT JOIN profiles p ON p.id = u.id
ORDER BY u.created_at DESC;

-- ============================================================================
-- Active subscriptions
-- ============================================================================

SELECT
  us.user_id,
  u.email,
  us.tier,
  us.plan_type,
  us.status,
  us.amount,
  us.start_date,
  us.end_date,
  us.payment_method
FROM user_subscriptions us
LEFT JOIN auth.users u ON u.id = us.user_id
WHERE us.status = 'active'
ORDER BY us.created_at DESC;
