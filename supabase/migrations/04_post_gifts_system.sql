-- =====================================================
-- POST GIFTS SYSTEM - Points Gifting for Feed Posts
-- =====================================================
-- Created: December 24, 2024
-- Purpose: Allow users to gift points to bloggers/content creators
-- Run this AFTER: 00_initial_schema.sql, 01_rls_policies.sql, 02_functions_triggers.sql, 03_seed_data.sql
-- =====================================================

-- =====================================================
-- 1. POST_GIFTS TABLE
-- =====================================================
-- Tracks points gifted to feed posts by users

CREATE TABLE IF NOT EXISTS post_gifts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Relationships
  feed_id UUID NOT NULL,  -- References feed.id (from feed table)
  gifter_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,  -- User who gave the gift
  receiver_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,  -- Post author who receives the gift

  -- Gift details
  points_amount INTEGER NOT NULL CHECK (points_amount > 0),  -- Points gifted
  message TEXT,  -- Optional message with the gift

  -- Gift options (predefined amounts or custom)
  gift_type TEXT NOT NULL CHECK (gift_type IN ('small', 'medium', 'large', 'custom')) DEFAULT 'small',

  -- Status tracking
  status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'refunded', 'failed')) DEFAULT 'completed',

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Prevent duplicate gifts (user can only gift once per post)
  UNIQUE(feed_id, gifter_user_id)
);

-- Indexes for post_gifts
CREATE INDEX idx_post_gifts_feed_id ON post_gifts(feed_id);
CREATE INDEX idx_post_gifts_gifter_user_id ON post_gifts(gifter_user_id);
CREATE INDEX idx_post_gifts_receiver_user_id ON post_gifts(receiver_user_id);
CREATE INDEX idx_post_gifts_created_at ON post_gifts(created_at DESC);
CREATE INDEX idx_post_gifts_status ON post_gifts(status);

-- Composite index for feed gift summary queries
CREATE INDEX idx_post_gifts_feed_status ON post_gifts(feed_id, status);

-- =====================================================
-- 2. ADD GIFT TRACKING TO FEED TABLE
-- =====================================================
-- Note: This assumes you have a 'feed' or 'feeds' table
-- Adjust table name if different

-- Check if column exists before adding (prevents error on re-run)
DO $$
BEGIN
  -- Add gift_count to track total gifts received
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'feed'
    AND column_name = 'gift_count'
  ) THEN
    ALTER TABLE feed ADD COLUMN gift_count INTEGER DEFAULT 0;
  END IF;

  -- Add total_points_received to track monetary value
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'feed'
    AND column_name = 'total_points_received'
  ) THEN
    ALTER TABLE feed ADD COLUMN total_points_received INTEGER DEFAULT 0;
  END IF;
END $$;

-- =====================================================
-- 3. GIFT PRESET CONFIGURATIONS TABLE
-- =====================================================
-- Stores predefined gift amounts and their emoji/labels

CREATE TABLE IF NOT EXISTS gift_presets (
  id TEXT PRIMARY KEY,  -- e.g., 'small', 'medium', 'large'
  name TEXT NOT NULL,
  emoji TEXT NOT NULL,  -- e.g., '👍', '❤️', '🔥'
  points_amount INTEGER NOT NULL CHECK (points_amount > 0),
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default gift presets
INSERT INTO gift_presets (id, name, emoji, points_amount, display_order, is_active)
VALUES
  ('small', 'Like', '👍', 10, 1, true),
  ('medium', 'Love', '❤️', 50, 2, true),
  ('large', 'Fire', '🔥', 100, 3, true)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 4. FUNCTIONS FOR GIFTING SYSTEM
-- =====================================================

-- Function: Process a gift to a post
CREATE OR REPLACE FUNCTION process_post_gift(
  p_feed_id UUID,
  p_gifter_user_id UUID,
  p_receiver_user_id UUID,
  p_points_amount INTEGER,
  p_gift_type TEXT,
  p_message TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_gifter_points INTEGER;
  v_gift_id UUID;
  v_result JSONB;
BEGIN
  -- 1. Check if gifter has enough points
  SELECT reward_points INTO v_gifter_points
  FROM user_subscriptions
  WHERE user_id = p_gifter_user_id
    AND status = 'active'
  LIMIT 1;

  IF v_gifter_points IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'No active subscription found'
    );
  END IF;

  IF v_gifter_points < p_points_amount THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Insufficient points',
      'current_points', v_gifter_points,
      'required_points', p_points_amount
    );
  END IF;

  -- 2. Check if user already gifted this post
  IF EXISTS (
    SELECT 1 FROM post_gifts
    WHERE feed_id = p_feed_id
      AND gifter_user_id = p_gifter_user_id
  ) THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'You have already gifted this post'
    );
  END IF;

  -- 3. Create the gift record
  INSERT INTO post_gifts (
    feed_id,
    gifter_user_id,
    receiver_user_id,
    points_amount,
    gift_type,
    message,
    status
  ) VALUES (
    p_feed_id,
    p_gifter_user_id,
    p_receiver_user_id,
    p_points_amount,
    p_gift_type,
    p_message,
    'completed'
  )
  RETURNING id INTO v_gift_id;

  -- 4. Deduct points from gifter
  UPDATE user_subscriptions
  SET reward_points = reward_points - p_points_amount,
      updated_at = NOW()
  WHERE user_id = p_gifter_user_id
    AND status = 'active';

  -- 5. Add points to receiver
  UPDATE user_subscriptions
  SET reward_points = reward_points + p_points_amount,
      updated_at = NOW()
  WHERE user_id = p_receiver_user_id
    AND status = 'active';

  -- 6. Update feed statistics
  UPDATE feed
  SET gift_count = gift_count + 1,
      total_points_received = total_points_received + p_points_amount
  WHERE id = p_feed_id;

  -- 7. Return success response
  SELECT jsonb_build_object(
    'success', true,
    'gift_id', v_gift_id,
    'points_gifted', p_points_amount,
    'remaining_points', reward_points
  ) INTO v_result
  FROM user_subscriptions
  WHERE user_id = p_gifter_user_id
    AND status = 'active'
  LIMIT 1;

  RETURN v_result;

EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object(
    'success', false,
    'error', SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Get gift summary for a post
CREATE OR REPLACE FUNCTION get_post_gift_summary(p_feed_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'total_gifts', COUNT(*),
    'total_points', COALESCE(SUM(points_amount), 0),
    'unique_gifters', COUNT(DISTINCT gifter_user_id),
    'gift_breakdown', jsonb_agg(
      jsonb_build_object(
        'gift_type', gift_type,
        'count', count
      )
    )
  ) INTO v_result
  FROM (
    SELECT
      gift_type,
      COUNT(*) as count
    FROM post_gifts
    WHERE feed_id = p_feed_id
      AND status = 'completed'
    GROUP BY gift_type
  ) gifts;

  RETURN COALESCE(v_result, jsonb_build_object(
    'total_gifts', 0,
    'total_points', 0,
    'unique_gifters', 0,
    'gift_breakdown', '[]'::jsonb
  ));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Get user's gifting history
CREATE OR REPLACE FUNCTION get_user_gift_history(
  p_user_id UUID,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  gift_id UUID,
  feed_id UUID,
  receiver_name TEXT,
  receiver_avatar TEXT,
  points_amount INTEGER,
  gift_type TEXT,
  message TEXT,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    pg.id as gift_id,
    pg.feed_id,
    p.full_name as receiver_name,
    p.avatar_url as receiver_avatar,
    pg.points_amount,
    pg.gift_type,
    pg.message,
    pg.created_at
  FROM post_gifts pg
  JOIN profiles p ON p.id = pg.receiver_user_id
  WHERE pg.gifter_user_id = p_user_id
    AND pg.status = 'completed'
  ORDER BY pg.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Get gifts received by a user
CREATE OR REPLACE FUNCTION get_user_gifts_received(
  p_user_id UUID,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  gift_id UUID,
  feed_id UUID,
  gifter_name TEXT,
  gifter_avatar TEXT,
  points_amount INTEGER,
  gift_type TEXT,
  message TEXT,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    pg.id as gift_id,
    pg.feed_id,
    p.full_name as gifter_name,
    p.avatar_url as gifter_avatar,
    pg.points_amount,
    pg.gift_type,
    pg.message,
    pg.created_at
  FROM post_gifts pg
  JOIN profiles p ON p.id = pg.gifter_user_id
  WHERE pg.receiver_user_id = p_user_id
    AND pg.status = 'completed'
  ORDER BY pg.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 5. ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Enable RLS on post_gifts table
ALTER TABLE post_gifts ENABLE ROW LEVEL SECURITY;

-- Users can view all gifts (for transparency)
CREATE POLICY "post_gifts_select_all"
  ON post_gifts FOR SELECT
  USING (true);

-- Users can insert their own gifts
CREATE POLICY "post_gifts_insert_own"
  ON post_gifts FOR INSERT
  WITH CHECK (auth.uid() = gifter_user_id);

-- Only system can update/delete (via functions)
CREATE POLICY "post_gifts_update_system"
  ON post_gifts FOR UPDATE
  USING (false);

CREATE POLICY "post_gifts_delete_system"
  ON post_gifts FOR DELETE
  USING (false);

-- Enable RLS on gift_presets (read-only for users)
ALTER TABLE gift_presets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "gift_presets_select_all"
  ON gift_presets FOR SELECT
  USING (is_active = true);

-- =====================================================
-- 6. TRIGGERS
-- =====================================================

-- Note: The main gift processing logic is in the process_post_gift function
-- which handles all updates atomically to prevent race conditions

-- =====================================================
-- 7. INDEXES FOR PERFORMANCE
-- =====================================================

-- Index for checking if user already gifted a post (UNIQUE constraint handles this)
-- Index for getting top gifted posts
CREATE INDEX idx_post_gifts_points_desc ON post_gifts(points_amount DESC) WHERE status = 'completed';

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Post Gifts System installed successfully!';
  RAISE NOTICE '📊 Tables created: post_gifts, gift_presets';
  RAISE NOTICE '⚙️  Functions created: process_post_gift, get_post_gift_summary, get_user_gift_history, get_user_gifts_received';
  RAISE NOTICE '🔒 RLS policies enabled';
  RAISE NOTICE '🎁 Gift presets: 👍 Like (10pts), ❤️ Love (50pts), 🔥 Fire (100pts)';
  RAISE NOTICE '';
  RAISE NOTICE '📱 Next steps:';
  RAISE NOTICE '   1. Update Flutter models to include post_gifts';
  RAISE NOTICE '   2. Add gift button UI to feed items';
  RAISE NOTICE '   3. Test gifting with sample users';
END $$;
