-- =====================================================
-- DELETE USER: developer.kdrtech.in@gmail.com
-- =====================================================
-- Generated: May 30, 2026
-- ⚠️ WARNING: This will permanently delete the user
-- =====================================================

-- Step 1: Find the user UUID
DO $$
DECLARE
  v_user_id UUID;
  v_email TEXT := 'developer.kdrtech.in@gmail.com';
  v_full_name TEXT;
  v_created_at TIMESTAMPTZ;
BEGIN
  -- Get user details
  SELECT id, full_name, created_at
  INTO v_user_id, v_full_name, v_created_at
  FROM profiles
  WHERE email = v_email;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User with email % not found', v_email;
  END IF;

  RAISE NOTICE '==========================================';
  RAISE NOTICE 'DELETING USER:';
  RAISE NOTICE 'Email: %', v_email;
  RAISE NOTICE 'Name: %', v_full_name;
  RAISE NOTICE 'UUID: %', v_user_id;
  RAISE NOTICE 'Created: %', v_created_at;
  RAISE NOTICE '==========================================';

  -- Count records before deletion
  RAISE NOTICE 'Records to delete:';
  RAISE NOTICE '  booking_cancellations: %', (SELECT COUNT(*) FROM booking_cancellations WHERE user_id = v_user_id);
  RAISE NOTICE '  bookings: %', (SELECT COUNT(*) FROM bookings WHERE user_id = v_user_id);
  RAISE NOTICE '  post_gifts: %', (SELECT COUNT(*) FROM post_gifts WHERE gifter_user_id = v_user_id OR receiver_user_id = v_user_id);
  RAISE NOTICE '  chat_messages: %', (SELECT COUNT(*) FROM chat_messages WHERE sender_id = v_user_id);
  RAISE NOTICE '  chat_participants: %', (SELECT COUNT(*) FROM chat_participants WHERE user_id = v_user_id);
  RAISE NOTICE '  friendships: %', (SELECT COUNT(*) FROM friendships WHERE user_id = v_user_id OR friend_id = v_user_id);
  RAISE NOTICE '  referrals: %', (SELECT COUNT(*) FROM referrals WHERE referrer_user_id = v_user_id OR referred_user_id = v_user_id);
  RAISE NOTICE '  point_redemptions: %', (SELECT COUNT(*) FROM point_redemptions WHERE user_id = v_user_id);
  RAISE NOTICE '  concierge_request_tracking: %', (SELECT COUNT(*) FROM concierge_request_tracking WHERE user_id = v_user_id);
  RAISE NOTICE '  subscription_events: %', (SELECT COUNT(*) FROM subscription_events WHERE user_id = v_user_id);
  RAISE NOTICE '  subscriptions: %', (SELECT COUNT(*) FROM subscriptions WHERE user_id = v_user_id);
  RAISE NOTICE '  user_subscriptions: %', (SELECT COUNT(*) FROM user_subscriptions WHERE user_id = v_user_id);
  RAISE NOTICE '==========================================';

  -- Perform deletions in correct order
  DELETE FROM booking_cancellations WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Deleted booking_cancellations';

  DELETE FROM bookings WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Deleted bookings';

  DELETE FROM post_gifts WHERE gifter_user_id = v_user_id OR receiver_user_id = v_user_id;
  RAISE NOTICE '✓ Deleted post_gifts';

  DELETE FROM chat_messages WHERE sender_id = v_user_id;
  RAISE NOTICE '✓ Deleted chat_messages';

  DELETE FROM chat_participants WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Deleted chat_participants';

  DELETE FROM friendships WHERE user_id = v_user_id OR friend_id = v_user_id;
  RAISE NOTICE '✓ Deleted friendships';

  DELETE FROM referrals WHERE referrer_user_id = v_user_id OR referred_user_id = v_user_id;
  RAISE NOTICE '✓ Deleted referrals';

  DELETE FROM point_redemptions WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Deleted point_redemptions';

  DELETE FROM concierge_request_tracking WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Deleted concierge_request_tracking';

  DELETE FROM subscription_events WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Deleted subscription_events';

  DELETE FROM subscriptions WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Deleted subscriptions';

  DELETE FROM user_subscriptions WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Deleted user_subscriptions';

  DELETE FROM profiles WHERE id = v_user_id;
  RAISE NOTICE '✓ Deleted profile';

  RAISE NOTICE '==========================================';
  RAISE NOTICE 'DATABASE DELETION COMPLETE!';
  RAISE NOTICE 'User UUID: %', v_user_id;
  RAISE NOTICE '==========================================';
  RAISE NOTICE 'NEXT STEP: Delete from auth.users';
  RAISE NOTICE 'Run this command:';
  RAISE NOTICE '  curl -X DELETE \';
  RAISE NOTICE '    "https://yvnfhsipyfxdmulajbgl.supabase.co/auth/v1/admin/users/%s" \', v_user_id;
  RAISE NOTICE '    -H "apikey: YOUR_SERVICE_ROLE_KEY" \';
  RAISE NOTICE '    -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY"';
  RAISE NOTICE '==========================================';
END $$;
