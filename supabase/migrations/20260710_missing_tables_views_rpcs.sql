-- Applied live via `supabase db query` on 2026-07-10; tracked here.

-- Objects referenced by app code but missing from the live database,
-- found by an exhaustive scan of every .from()/.rpc() call across all
-- three apps diffed against the live schema. Each feature below was
-- silently or loudly broken at runtime without these.

-- 1. Concierge monthly request limits (user app concierge tab)
CREATE TABLE IF NOT EXISTS concierge_request_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  month INTEGER NOT NULL,
  year INTEGER NOT NULL,
  request_count INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, month, year)
);
ALTER TABLE concierge_request_tracking ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own concierge tracking" ON concierge_request_tracking
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 2. Feed post reports (App Store UGC moderation requirement)
CREATE TABLE IF NOT EXISTS feed_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  feed_id UUID NOT NULL REFERENCES feeds(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE feed_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "report feeds" ON feed_reports
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "admins review feed reports" ON feed_reports
  FOR ALL USING (is_user_admin());

-- 3. User blocking (App Store UGC moderation requirement)
CREATE TABLE IF NOT EXISTS user_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (blocker_id, blocked_id)
);
ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own blocks" ON user_blocks
  FOR ALL USING (auth.uid() = blocker_id) WITH CHECK (auth.uid() = blocker_id);

-- 4. User reports from chat (App Store UGC moderation requirement)
CREATE TABLE IF NOT EXISTS user_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reported_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  report_type TEXT NOT NULL DEFAULT 'general',
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE user_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "report users" ON user_reports
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "admins review user reports" ON user_reports
  FOR ALL USING (is_user_admin());

-- 5. Gift presets for feed gifting (public catalog; ids match GiftType enum)
CREATE TABLE IF NOT EXISTS gift_presets (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  emoji TEXT NOT NULL,
  points_amount INTEGER NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE gift_presets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "gift presets are public" ON gift_presets FOR SELECT USING (true);
CREATE POLICY "admins manage gift presets" ON gift_presets FOR ALL USING (is_user_admin());
INSERT INTO gift_presets (id, name, emoji, points_amount, display_order) VALUES
  ('small', 'Like', '👍', 10, 1),
  ('medium', 'Love', '❤️', 50, 2),
  ('large', 'Fire', '🔥', 100, 3)
ON CONFLICT (id) DO NOTHING;

-- 6. In-app notifications (tier upgrades etc)
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own notifications" ON notifications
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 7. User tier tracking (subscription tier/points screen).
-- id is TEXT because the client generates millisecond-timestamp ids.
CREATE TABLE IF NOT EXISTS user_tiers (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  current_tier TEXT NOT NULL DEFAULT 'gold',
  total_points INTEGER NOT NULL DEFAULT 0,
  tier_progress INTEGER NOT NULL DEFAULT 0,
  next_tier_threshold INTEGER NOT NULL DEFAULT 1000,
  tier_benefits TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ
);
ALTER TABLE user_tiers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own tier row" ON user_tiers
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 8. Explore-by-category view (explore tab category browsing)
CREATE OR REPLACE VIEW events_with_categories AS
  SELECT
    e.id,
    e.title,
    e.description,
    e.cover_image,
    e.start_date,
    e.end_date,
    e.club_id,
    e.location,
    e.created_at,
    c.name AS category_name
  FROM events e
  JOIN event_categories ec ON ec.event_id = e.id
  JOIN categories c ON c.id = ec.category_id;
GRANT SELECT ON events_with_categories TO authenticated, anon;

-- 9. Single-feed variant of get_feeds_with_like_status (feed detail screen)
CREATE OR REPLACE FUNCTION public.get_feed_with_like_status(feed_id uuid, current_user_id uuid)
RETURNS TABLE(id uuid, user_id uuid, content text, image_url text, like_count integer, comment_count integer, event_id uuid, is_liked boolean, created_at timestamptz, updated_at timestamptz, expires_at timestamptz, duration_hours integer, is_following_author boolean, author_name text, author_avatar text, follower_count integer)
LANGUAGE plpgsql
STABLE
AS $function$
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
            WHERE fl.feed_id = f.id AND fl.user_id = current_user_id
        ) AS is_liked,
        f.created_at,
        f.updated_at,
        f.expires_at,
        f.duration_hours,
        EXISTS(
            SELECT 1 FROM blogger_follows bf
            WHERE bf.follower_id = current_user_id AND bf.following_id = f.user_id
        ) AS is_following_author,
        COALESCE(p.full_name, p.email, 'Anonymous') AS author_name,
        p.avatar_url AS author_avatar,
        COALESCE(f.follower_count, 0) AS follower_count
    FROM feeds f
    LEFT JOIN profiles p ON f.user_id = p.id
    WHERE f.id = get_feed_with_like_status.feed_id;
END;
$function$;
