-- =====================================================
-- 1. ADD NEW COLUMNS TO FEEDS TABLE
-- =====================================================

-- Add expiration and duration columns
ALTER TABLE feeds
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS duration_hours INTEGER DEFAULT 24;

-- Add author information (denormalized for performance)
ALTER TABLE feeds
ADD COLUMN IF NOT EXISTS author_name TEXT,
ADD COLUMN IF NOT EXISTS author_avatar TEXT,
ADD COLUMN IF NOT EXISTS follower_count INTEGER DEFAULT 0;

-- Create index for efficient querying of active posts
CREATE INDEX IF NOT EXISTS idx_feeds_expires_at ON feeds(expires_at)
WHERE expires_at IS NOT NULL;

-- Create index for user's feeds
CREATE INDEX IF NOT EXISTS idx_feeds_user_id ON feeds(user_id);

-- =====================================================
-- 2. CREATE BLOGGER FOLLOWS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS blogger_follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Prevent duplicate follows
    UNIQUE(follower_id, following_id),

    -- Prevent self-following
    CHECK (follower_id != following_id)
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_blogger_follows_follower
ON blogger_follows(follower_id);

CREATE INDEX IF NOT EXISTS idx_blogger_follows_following
ON blogger_follows(following_id);

-- =====================================================
-- 3. CREATE FUNCTION TO UPDATE FOLLOWER COUNT
-- =====================================================

CREATE OR REPLACE FUNCTION update_follower_count()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        -- Increment follower count
        UPDATE feeds
        SET follower_count = (
            SELECT COUNT(*)
            FROM blogger_follows
            WHERE following_id = NEW.following_id
        )
        WHERE user_id = NEW.following_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        -- Decrement follower count
        UPDATE feeds
        SET follower_count = (
            SELECT COUNT(*)
            FROM blogger_follows
            WHERE following_id = OLD.following_id
        )
        WHERE user_id = OLD.following_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_update_follower_count ON blogger_follows;
CREATE TRIGGER trigger_update_follower_count
    AFTER INSERT OR DELETE ON blogger_follows
    FOR EACH ROW
    EXECUTE FUNCTION update_follower_count();

-- =====================================================
-- 4. UPDATE EXISTING RPC FUNCTION FOR FEED RETRIEVAL
-- =====================================================

-- Drop existing function
DROP FUNCTION IF EXISTS get_feeds_with_like_status(UUID);

-- Create new function with follow status and random ordering
CREATE OR REPLACE FUNCTION get_feeds_with_like_status(
    current_user_id UUID
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    content TEXT,
    image_url TEXT,
    like_count INTEGER,
    comment_count INTEGER,
    event_id UUID,
    is_liked BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    duration_hours INTEGER,
    is_following_author BOOLEAN,
    author_name TEXT,
    author_avatar TEXT,
    follower_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id,
        f.user_id,
        f.content,
        f.image_url,
        f.like_count,
        f.comment_count,
        f.event_id,
        EXISTS(
            SELECT 1 FROM feed_likes fl
            WHERE fl.feed_id = f.id
            AND fl.user_id = current_user_id
        ) AS is_liked,
        f.created_at,
        f.updated_at,
        f.expires_at,
        f.duration_hours,
        EXISTS(
            SELECT 1 FROM blogger_follows bf
            WHERE bf.follower_id = current_user_id
            AND bf.following_id = f.user_id
        ) AS is_following_author,
        COALESCE(p.full_name, p.email, 'Anonymous') AS author_name,
        p.avatar_url AS author_avatar,
        COALESCE(f.follower_count, 0) AS follower_count
    FROM feeds f
    LEFT JOIN profiles p ON f.user_id = p.id
    WHERE
        -- Only show active posts (not expired)
        (f.expires_at IS NULL OR f.expires_at > NOW())
    ORDER BY RANDOM() -- Random ordering for fresh feed each time
    LIMIT 50;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- 5. CREATE FUNCTION TO GET FOLLOWED BLOGGERS' POSTS
-- =====================================================

CREATE OR REPLACE FUNCTION get_followed_feeds(
    current_user_id UUID
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    content TEXT,
    image_url TEXT,
    like_count INTEGER,
    comment_count INTEGER,
    event_id UUID,
    is_liked BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    duration_hours INTEGER,
    is_following_author BOOLEAN,
    author_name TEXT,
    author_avatar TEXT,
    follower_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id,
        f.user_id,
        f.content,
        f.image_url,
        f.like_count,
        f.comment_count,
        f.event_id,
        EXISTS(
            SELECT 1 FROM feed_likes fl
            WHERE fl.feed_id = f.id
            AND fl.user_id = current_user_id
        ) AS is_liked,
        f.created_at,
        f.updated_at,
        f.expires_at,
        f.duration_hours,
        TRUE AS is_following_author,
        COALESCE(p.full_name, p.email, 'Anonymous') AS author_name,
        p.avatar_url AS author_avatar,
        COALESCE(f.follower_count, 0) AS follower_count
    FROM feeds f
    INNER JOIN blogger_follows bf ON f.user_id = bf.following_id
    LEFT JOIN profiles p ON f.user_id = p.id
    WHERE
        bf.follower_id = current_user_id
        AND (f.expires_at IS NULL OR f.expires_at > NOW())
    ORDER BY f.created_at DESC
    LIMIT 50;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- 6. ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Enable RLS on blogger_follows
ALTER TABLE blogger_follows ENABLE ROW LEVEL SECURITY;

-- Users can view all follows
DROP POLICY IF EXISTS "Users can view all follows" ON blogger_follows;
CREATE POLICY "Users can view all follows" ON blogger_follows
    FOR SELECT USING (true);

-- Users can insert their own follows
DROP POLICY IF EXISTS "Users can insert their own follows" ON blogger_follows;
CREATE POLICY "Users can insert their own follows" ON blogger_follows
    FOR INSERT WITH CHECK (auth.uid() = follower_id);

-- Users can delete their own follows
DROP POLICY IF EXISTS "Users can delete their own follows" ON blogger_follows;
CREATE POLICY "Users can delete their own follows" ON blogger_follows
    FOR DELETE USING (auth.uid() = follower_id);

-- =====================================================
-- 7. CREATE FUNCTION TO CLEANUP EXPIRED POSTS
-- =====================================================

-- Function to delete expired posts (can be run as a cron job)
CREATE OR REPLACE FUNCTION cleanup_expired_feeds()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    WITH deleted AS (
        DELETE FROM feeds
        WHERE expires_at IS NOT NULL
        AND expires_at < NOW()
        RETURNING *
    )
    SELECT COUNT(*) INTO deleted_count FROM deleted;

    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- You can set up a cron job in Supabase to run this daily:
-- SELECT cron.schedule('cleanup-expired-feeds', '0 2 * * *',
--   $$ SELECT cleanup_expired_feeds(); $$);
