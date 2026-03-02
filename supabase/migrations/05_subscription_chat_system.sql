-- =====================================================
-- SUBSCRIPTION-BASED CHAT SYSTEM
-- =====================================================
-- Created: December 24, 2024
-- Purpose: Enable chat only for users with active subscriptions
-- Run this AFTER: 04_post_gifts_system.sql
-- =====================================================

-- =====================================================
-- 1. FUNCTION: Search users with active subscriptions
-- =====================================================

CREATE OR REPLACE FUNCTION search_subscribed_users(
  search_query TEXT,
  requesting_user_id UUID
)
RETURNS TABLE (
  id UUID,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  current_tier TEXT,
  subscription_status TEXT,
  plan_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id,
    p.email,
    p.full_name,
    p.avatar_url,
    p.current_tier,
    us.status as subscription_status,
    sp.name as plan_name
  FROM profiles p
  INNER JOIN user_subscriptions us ON us.user_id = p.id
  INNER JOIN subscription_plans sp ON sp.id = us.plan_id
  WHERE
    -- User must have active subscription
    us.status = 'active'
    -- Exclude current user from results
    AND p.id != requesting_user_id
    -- Match search query (case-insensitive)
    AND (
      p.full_name ILIKE '%' || search_query || '%'
      OR p.email ILIKE '%' || search_query || '%'
    )
    -- Account must be active
    AND p.is_active = true
  ORDER BY p.full_name
  LIMIT 50;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 2. FUNCTION: Check if user can access chat
-- =====================================================

CREATE OR REPLACE FUNCTION can_user_access_chat(user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_has_subscription BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM user_subscriptions
    WHERE user_id = $1
      AND status = 'active'
      AND end_date > NOW()
  ) INTO v_has_subscription;

  RETURN v_has_subscription;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. FUNCTION: Validate chat room access
-- =====================================================

CREATE OR REPLACE FUNCTION validate_chat_room_access(
  room_id UUID,
  user_id UUID
)
RETURNS JSONB AS $$
DECLARE
  v_has_subscription BOOLEAN;
  v_is_participant BOOLEAN;
  v_all_participants_subscribed BOOLEAN;
BEGIN
  -- Check if user has active subscription
  SELECT can_user_access_chat(user_id) INTO v_has_subscription;

  IF NOT v_has_subscription THEN
    RETURN jsonb_build_object(
      'can_access', false,
      'reason', 'You need an active subscription to access chat.',
      'action_required', 'subscribe'
    );
  END IF;

  -- Check if user is participant in this room
  SELECT EXISTS (
    SELECT 1
    FROM chat_participants
    WHERE chat_room_id = room_id
      AND user_id = $2
      AND left_at IS NULL
  ) INTO v_is_participant;

  IF NOT v_is_participant THEN
    RETURN jsonb_build_object(
      'can_access', false,
      'reason', 'You are not a participant in this chat room.',
      'action_required', 'join'
    );
  END IF;

  -- Check if all participants have active subscriptions
  SELECT NOT EXISTS (
    SELECT 1
    FROM chat_participants cp
    LEFT JOIN user_subscriptions us ON us.user_id = cp.user_id AND us.status = 'active'
    WHERE cp.chat_room_id = room_id
      AND cp.left_at IS NULL
      AND us.id IS NULL  -- No active subscription found
  ) INTO v_all_participants_subscribed;

  IF NOT v_all_participants_subscribed THEN
    RETURN jsonb_build_object(
      'can_access', true,
      'reason', 'Some participants do not have active subscriptions.',
      'action_required', 'warn',
      'warning', 'This chat room has participants without active subscriptions.'
    );
  END IF;

  RETURN jsonb_build_object(
    'can_access', true,
    'reason', 'Access granted',
    'action_required', null
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 4. UPDATE RLS POLICIES FOR CHAT TABLES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "chat_rooms_select" ON chat_rooms;
DROP POLICY IF EXISTS "chat_rooms_insert" ON chat_rooms;
DROP POLICY IF EXISTS "chat_messages_select" ON chat_messages;
DROP POLICY IF EXISTS "chat_messages_insert" ON chat_messages;
DROP POLICY IF EXISTS "chat_participants_select" ON chat_participants;

-- Chat Rooms: Only subscribed users can view and create
CREATE POLICY "chat_rooms_select_subscribed"
  ON chat_rooms FOR SELECT
  USING (
    -- User must have active subscription
    can_user_access_chat(auth.uid())
    AND (
      -- User is a participant
      auth.uid() = ANY(participant_ids)
    )
  );

CREATE POLICY "chat_rooms_insert_subscribed"
  ON chat_rooms FOR INSERT
  WITH CHECK (
    -- User must have active subscription
    can_user_access_chat(auth.uid())
    -- User must be in participant list
    AND auth.uid() = ANY(participant_ids)
  );

-- Chat Messages: Only subscribed participants can view and send
CREATE POLICY "chat_messages_select_subscribed"
  ON chat_messages FOR SELECT
  USING (
    -- User must have active subscription
    can_user_access_chat(auth.uid())
    AND (
      -- User is participant in the room
      EXISTS (
        SELECT 1
        FROM chat_rooms
        WHERE id = chat_messages.room_id
          AND auth.uid() = ANY(participant_ids)
      )
    )
  );

CREATE POLICY "chat_messages_insert_subscribed"
  ON chat_messages FOR INSERT
  WITH CHECK (
    -- User must have active subscription
    can_user_access_chat(auth.uid())
    -- User is the sender
    AND auth.uid() = sender_id
    -- User is participant in the room
    AND EXISTS (
      SELECT 1
      FROM chat_rooms
      WHERE id = chat_messages.room_id
        AND auth.uid() = ANY(participant_ids)
    )
  );

-- Chat Participants: Only subscribed users can view
CREATE POLICY "chat_participants_select_subscribed"
  ON chat_participants FOR SELECT
  USING (
    -- User must have active subscription
    can_user_access_chat(auth.uid())
    AND (
      -- User is viewing their own participation
      auth.uid() = user_id
      OR
      -- User is in the same chat room
      EXISTS (
        SELECT 1
        FROM chat_participants cp2
        WHERE cp2.chat_room_id = chat_participants.chat_room_id
          AND cp2.user_id = auth.uid()
      )
    )
  );

-- =====================================================
-- 5. CREATE VIEW: Active Subscribed Users
-- =====================================================

CREATE OR REPLACE VIEW active_subscribed_users AS
SELECT
  p.id,
  p.email,
  p.full_name,
  p.avatar_url,
  p.current_tier,
  p.is_active,
  us.status as subscription_status,
  us.end_date as subscription_end_date,
  sp.name as plan_name,
  sp.tier_level
FROM profiles p
INNER JOIN user_subscriptions us ON us.user_id = p.id
INNER JOIN subscription_plans sp ON sp.id = us.plan_id
WHERE
  us.status = 'active'
  AND us.end_date > NOW()
  AND p.is_active = true;

-- Grant access to the view
GRANT SELECT ON active_subscribed_users TO authenticated;

-- =====================================================
-- 6. CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Index for fast subscription status lookup
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_status_active
  ON user_subscriptions(user_id, status)
  WHERE status = 'active';

-- Index for user search by name
CREATE INDEX IF NOT EXISTS idx_profiles_full_name_trgm
  ON profiles USING gin(full_name gin_trgm_ops);

-- Index for user search by email
CREATE INDEX IF NOT EXISTS idx_profiles_email_trgm
  ON profiles USING gin(email gin_trgm_ops);

-- Note: Requires pg_trgm extension for fuzzy text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- =====================================================
-- 7. FUNCTION: Get chat-eligible users count
-- =====================================================

CREATE OR REPLACE FUNCTION get_chat_eligible_users_count()
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(DISTINCT user_id)
  FROM user_subscriptions
  WHERE status = 'active'
    AND end_date > NOW()
  INTO v_count;

  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Subscription-Based Chat System installed successfully!';
  RAISE NOTICE '🔒 Chat access restricted to subscribed users only';
  RAISE NOTICE '⚙️  Functions created:';
  RAISE NOTICE '   - search_subscribed_users()';
  RAISE NOTICE '   - can_user_access_chat()';
  RAISE NOTICE '   - validate_chat_room_access()';
  RAISE NOTICE '   - get_chat_eligible_users_count()';
  RAISE NOTICE '📊 Views created: active_subscribed_users';
  RAISE NOTICE '🔐 RLS policies updated for chat tables';
  RAISE NOTICE '';
  RAISE NOTICE '📱 Next steps:';
  RAISE NOTICE '   1. Update Flutter app to use subscription chat helper';
  RAISE NOTICE '   2. Add subscription prompts in chat UI';
  RAISE NOTICE '   3. Test with subscribed and non-subscribed users';
END $$;
