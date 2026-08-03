-- Create post_gifts table to fix profile edit error
-- This table tracks gifts given to posts/feeds

CREATE TABLE IF NOT EXISTS post_gifts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  feed_id UUID NOT NULL REFERENCES feeds(id) ON DELETE CASCADE,
  gifter_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  receiver_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  points_amount INTEGER NOT NULL CHECK (points_amount > 0),
  gift_type TEXT NOT NULL,
  message TEXT,
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_post_gifts_feed_id ON post_gifts(feed_id);
CREATE INDEX IF NOT EXISTS idx_post_gifts_gifter ON post_gifts(gifter_user_id);
CREATE INDEX IF NOT EXISTS idx_post_gifts_receiver ON post_gifts(receiver_user_id);
CREATE INDEX IF NOT EXISTS idx_post_gifts_status ON post_gifts(status);

-- Function to get post gift summary
CREATE OR REPLACE FUNCTION get_post_gift_summary(p_feed_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_total_gifts INTEGER;
  v_total_points INTEGER;
  v_unique_gifters INTEGER;
BEGIN
  -- Get aggregated gift data
  SELECT
    COALESCE(COUNT(*), 0),
    COALESCE(SUM(points_amount), 0),
    COALESCE(COUNT(DISTINCT gifter_user_id), 0)
  INTO
    v_total_gifts,
    v_total_points,
    v_unique_gifters
  FROM post_gifts
  WHERE feed_id = p_feed_id
    AND status = 'completed';

  -- Return JSON summary
  RETURN json_build_object(
    'totalGifts', v_total_gifts,
    'totalPoints', v_total_points,
    'uniqueGifters', v_unique_gifters,
    'userHasGifted', false,
    'userGiftType', null
  );
END;
$$;

-- Function to process post gift (placeholder - full implementation needed)
CREATE OR REPLACE FUNCTION process_post_gift(
  p_feed_id UUID,
  p_gifter_user_id UUID,
  p_receiver_user_id UUID,
  p_points_amount INTEGER,
  p_gift_type TEXT,
  p_message TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- For now, just return success
  -- Full implementation would:
  -- 1. Check gifter has enough points
  -- 2. Deduct points from gifter
  -- 3. Add points to receiver
  -- 4. Create gift record
  -- 5. Update post statistics

  RETURN json_build_object(
    'success', false,
    'error', 'Gift feature not yet enabled'
  );
END;
$$;

-- Grant permissions
GRANT SELECT, INSERT ON post_gifts TO authenticated;
GRANT EXECUTE ON FUNCTION get_post_gift_summary TO authenticated;
GRANT EXECUTE ON FUNCTION process_post_gift TO authenticated;
