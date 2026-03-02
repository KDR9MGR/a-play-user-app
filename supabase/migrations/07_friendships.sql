CREATE TABLE IF NOT EXISTS friendships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'accepted' CHECK (status IN ('pending', 'accepted', 'blocked')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT friendships_no_self CHECK (user_id <> friend_id),
  CONSTRAINT friendships_unique UNIQUE (user_id, friend_id)
);

CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON friendships(friend_id);
CREATE INDEX IF NOT EXISTS idx_friendships_status ON friendships(status);

ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "friendships_select_own" ON friendships;
DROP POLICY IF EXISTS "friendships_insert_own" ON friendships;
DROP POLICY IF EXISTS "friendships_update_own" ON friendships;
DROP POLICY IF EXISTS "friendships_delete_own" ON friendships;

CREATE POLICY "friendships_select_own"
  ON friendships FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "friendships_insert_own"
  ON friendships FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "friendships_update_own"
  ON friendships FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "friendships_delete_own"
  ON friendships FOR DELETE
  USING (auth.uid() = user_id);
