-- Feed moderation tables and policies

-- Create feed_reports table
CREATE TABLE IF NOT EXISTS public.feed_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  feed_id UUID NOT NULL REFERENCES public.feeds(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','resolved','rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create user_blocks table
CREATE TABLE IF NOT EXISTS public.user_blocks (
  blocker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (blocker_id, blocked_id)
);

-- Enable Row Level Security
ALTER TABLE public.feed_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Reporters can insert and view their own reports
CREATE POLICY IF NOT EXISTS "Users can insert own feed reports" 
ON public.feed_reports FOR INSERT TO authenticated
WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY IF NOT EXISTS "Users can view own feed reports" 
ON public.feed_reports FOR SELECT TO authenticated
USING (auth.uid() = reporter_id);

-- Admins can view and update all reports
CREATE POLICY IF NOT EXISTS "Admins can manage all feed reports" 
ON public.feed_reports FOR ALL TO authenticated
USING (
  auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin')
)
WITH CHECK (
  auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin')
);

-- Users can insert and view their own blocks
CREATE POLICY IF NOT EXISTS "Users can manage own blocks" 
ON public.user_blocks FOR ALL TO authenticated
USING (auth.uid() = blocker_id)
WITH CHECK (auth.uid() = blocker_id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_feed_reports_feed ON public.feed_reports(feed_id);
CREATE INDEX IF NOT EXISTS idx_feed_reports_reporter ON public.feed_reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_feed_reports_status ON public.feed_reports(status);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker ON public.user_blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocked ON public.user_blocks(blocked_id);

COMMENT ON TABLE public.feed_reports IS 'Stores user reports for objectionable feed content for 24-hour action';
COMMENT ON TABLE public.user_blocks IS 'Stores user-to-user block relationships';