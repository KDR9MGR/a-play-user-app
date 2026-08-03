-- =====================================================
-- USER DELETION FUNCTION
-- =====================================================
-- Purpose: Reusable PostgreSQL function for complete user deletion
-- Can be called from SQL, Supabase Dashboard, or backend code
-- =====================================================

CREATE OR REPLACE FUNCTION delete_user_completely(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_email TEXT;
  v_full_name TEXT;
  v_counts JSON;
  v_deleted_counts JSON;
BEGIN
  -- Verify user exists
  SELECT email, full_name INTO v_email, v_full_name
  FROM profiles
  WHERE id = p_user_id;

  IF v_email IS NULL THEN
    RAISE EXCEPTION 'User with ID % not found', p_user_id;
  END IF;

  RAISE NOTICE 'Deleting user: % (%) - ID: %', v_full_name, v_email, p_user_id;

  -- Count records before deletion
  SELECT json_build_object(
    'booking_cancellations', (SELECT COUNT(*) FROM booking_cancellations WHERE user_id = p_user_id),
    'bookings', (SELECT COUNT(*) FROM bookings WHERE user_id = p_user_id),
    'post_gifts', (SELECT COUNT(*) FROM post_gifts WHERE gifter_user_id = p_user_id OR receiver_user_id = p_user_id),
    'chat_messages', (SELECT COUNT(*) FROM chat_messages WHERE sender_id = p_user_id),
    'chat_participants', (SELECT COUNT(*) FROM chat_participants WHERE user_id = p_user_id),
    'friendships', (SELECT COUNT(*) FROM friendships WHERE user_id = p_user_id OR friend_id = p_user_id),
    'referrals', (SELECT COUNT(*) FROM referrals WHERE referrer_user_id = p_user_id OR referred_user_id = p_user_id),
    'point_redemptions', (SELECT COUNT(*) FROM point_redemptions WHERE user_id = p_user_id),
    'concierge_request_tracking', (SELECT COUNT(*) FROM concierge_request_tracking WHERE user_id = p_user_id),
    'subscription_events', (SELECT COUNT(*) FROM subscription_events WHERE user_id = p_user_id),
    'subscriptions', (SELECT COUNT(*) FROM subscriptions WHERE user_id = p_user_id),
    'user_subscriptions', (SELECT COUNT(*) FROM user_subscriptions WHERE user_id = p_user_id)
  ) INTO v_counts;

  -- Perform deletions in correct order
  DELETE FROM booking_cancellations WHERE user_id = p_user_id;
  DELETE FROM bookings WHERE user_id = p_user_id;
  DELETE FROM post_gifts WHERE gifter_user_id = p_user_id OR receiver_user_id = p_user_id;
  DELETE FROM chat_messages WHERE sender_id = p_user_id;
  DELETE FROM chat_participants WHERE user_id = p_user_id;
  DELETE FROM friendships WHERE user_id = p_user_id OR friend_id = p_user_id;
  DELETE FROM referrals WHERE referrer_user_id = p_user_id OR referred_user_id = p_user_id;
  DELETE FROM point_redemptions WHERE user_id = p_user_id;
  DELETE FROM concierge_request_tracking WHERE user_id = p_user_id;
  DELETE FROM subscription_events WHERE user_id = p_user_id;
  DELETE FROM subscriptions WHERE user_id = p_user_id;
  DELETE FROM user_subscriptions WHERE user_id = p_user_id;
  DELETE FROM profiles WHERE id = p_user_id;

  -- Return deletion summary
  RETURN json_build_object(
    'success', true,
    'user_id', p_user_id,
    'email', v_email,
    'full_name', v_full_name,
    'deleted_records', v_counts,
    'message', 'User data deleted from all tables. IMPORTANT: You must also delete from auth.users using Supabase Admin API.',
    'next_step', format('await supabase.auth.admin.deleteUser("%s")', p_user_id)
  );

EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error deleting user %: %', p_user_id, SQLERRM;
END;
$$;

-- Grant execute permission to authenticated users (optional - restrict as needed)
-- REVOKE ALL ON FUNCTION delete_user_completely(UUID) FROM PUBLIC;
-- GRANT EXECUTE ON FUNCTION delete_user_completely(UUID) TO service_role;

-- =====================================================
-- USAGE EXAMPLES
-- =====================================================

-- Example 1: Call from SQL
-- SELECT delete_user_completely('550e8400-e29b-41d4-a716-446655440000');

-- Example 2: Call from Supabase RPC (JavaScript)
-- const { data, error } = await supabase.rpc('delete_user_completely', {
--   p_user_id: '550e8400-e29b-41d4-a716-446655440000'
-- })
-- console.log(data) // Returns deletion summary
--
-- // Then delete from auth.users
-- await supabase.auth.admin.deleteUser(userId)

-- Example 3: Call from backend (Node.js)
-- const result = await supabase
--   .rpc('delete_user_completely', { p_user_id: userId })
--
-- if (result.data.success) {
--   await supabase.auth.admin.deleteUser(userId)
--   console.log('User completely deleted')
-- }

-- =====================================================
-- HELPER: Delete multiple users
-- =====================================================

CREATE OR REPLACE FUNCTION delete_users_batch(p_user_ids UUID[])
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_results JSON[] := ARRAY[]::JSON[];
  v_result JSON;
BEGIN
  FOREACH v_user_id IN ARRAY p_user_ids
  LOOP
    BEGIN
      v_result := delete_user_completely(v_user_id);
      v_results := array_append(v_results, v_result);
    EXCEPTION
      WHEN OTHERS THEN
        v_results := array_append(v_results, json_build_object(
          'success', false,
          'user_id', v_user_id,
          'error', SQLERRM
        ));
    END;
  END LOOP;

  RETURN json_build_object(
    'success', true,
    'total_users', array_length(p_user_ids, 1),
    'results', array_to_json(v_results)
  );
END;
$$;

-- Example: Delete multiple users
-- SELECT delete_users_batch(ARRAY[
--   '550e8400-e29b-41d4-a716-446655440000'::UUID,
--   '6ba7b810-9dad-11d1-80b4-00c04fd430c8'::UUID
-- ]);

-- =====================================================
-- HELPER: Find orphaned profiles (no auth.users record)
-- =====================================================

CREATE OR REPLACE FUNCTION find_orphaned_profiles()
RETURNS TABLE(
  profile_id UUID,
  email TEXT,
  full_name TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT
    p.id AS profile_id,
    p.email,
    p.full_name,
    p.created_at
  FROM profiles p
  LEFT JOIN auth.users u ON p.id = u.id
  WHERE u.id IS NULL
  ORDER BY p.created_at DESC;
$$;

-- Usage: SELECT * FROM find_orphaned_profiles();

-- =====================================================
-- HELPER: Clean orphaned profiles
-- =====================================================

CREATE OR REPLACE FUNCTION clean_orphaned_profiles()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_orphaned_ids UUID[];
  v_count INTEGER;
BEGIN
  -- Get all orphaned profile IDs
  SELECT ARRAY_AGG(p.id) INTO v_orphaned_ids
  FROM profiles p
  LEFT JOIN auth.users u ON p.id = u.id
  WHERE u.id IS NULL;

  v_count := array_length(v_orphaned_ids, 1);

  IF v_count IS NULL OR v_count = 0 THEN
    RETURN json_build_object(
      'success', true,
      'message', 'No orphaned profiles found',
      'deleted_count', 0
    );
  END IF;

  -- Delete orphaned profiles (cascades to related tables)
  RETURN delete_users_batch(v_orphaned_ids);
END;
$$;

-- Usage: SELECT clean_orphaned_profiles();

COMMENT ON FUNCTION delete_user_completely(UUID) IS
  'Completely deletes a user from all application tables (except auth.users which must be deleted via Supabase Admin API)';

COMMENT ON FUNCTION delete_users_batch(UUID[]) IS
  'Batch delete multiple users from all application tables';

COMMENT ON FUNCTION find_orphaned_profiles() IS
  'Find profiles that exist without corresponding auth.users records';

COMMENT ON FUNCTION clean_orphaned_profiles() IS
  'Automatically delete all orphaned profiles and their related data';
