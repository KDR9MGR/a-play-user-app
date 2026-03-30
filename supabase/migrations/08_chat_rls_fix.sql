DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('chat_rooms', 'chat_messages', 'chat_participants')
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
  END LOOP;
END $$;

ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "chat_rooms_select_authenticated"
  ON chat_rooms FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND (
      auth.uid()::text = ANY(participant_ids)
      OR name = 'Global Chat'
    )
  );

CREATE POLICY "chat_rooms_insert_authenticated"
  ON chat_rooms FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
    AND auth.uid()::text = ANY(participant_ids)
  );

CREATE POLICY "chat_rooms_update_authenticated"
  ON chat_rooms FOR UPDATE
  USING (
    auth.role() = 'authenticated'
    AND auth.uid()::text = ANY(participant_ids)
  )
  WITH CHECK (
    auth.role() = 'authenticated'
    AND auth.uid()::text = ANY(participant_ids)
  );

CREATE POLICY "chat_messages_select_authenticated"
  ON chat_messages FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND EXISTS (
      SELECT 1
      FROM chat_rooms r
      WHERE r.id = chat_messages.room_id
        AND (
          auth.uid()::text = ANY(r.participant_ids)
          OR r.name = 'Global Chat'
        )
    )
  );

CREATE POLICY "chat_messages_insert_authenticated"
  ON chat_messages FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
    AND auth.uid() = sender_id
    AND EXISTS (
      SELECT 1
      FROM chat_rooms r
      WHERE r.id = chat_messages.room_id
        AND (
          auth.uid()::text = ANY(r.participant_ids)
          OR r.name = 'Global Chat'
        )
    )
  );

CREATE POLICY "chat_messages_update_own"
  ON chat_messages FOR UPDATE
  USING (
    auth.role() = 'authenticated'
    AND auth.uid() = sender_id
  )
  WITH CHECK (
    auth.role() = 'authenticated'
    AND auth.uid() = sender_id
  );

CREATE POLICY "chat_messages_delete_own"
  ON chat_messages FOR DELETE
  USING (
    auth.role() = 'authenticated'
    AND auth.uid() = sender_id
  );

CREATE POLICY "chat_participants_select_room_member"
  ON chat_participants FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND EXISTS (
      SELECT 1
      FROM chat_rooms r
      WHERE r.id = chat_participants.chat_room_id
        AND (
          auth.uid()::text = ANY(r.participant_ids)
          OR r.name = 'Global Chat'
        )
    )
  );

CREATE POLICY "chat_participants_insert_room_member"
  ON chat_participants FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
    AND EXISTS (
      SELECT 1
      FROM chat_rooms r
      WHERE r.id = chat_participants.chat_room_id
        AND auth.uid()::text = ANY(r.participant_ids)
        AND chat_participants.user_id::text = ANY(r.participant_ids)
    )
  );
CREATE POLICY "chat_participants_update_own"
  ON chat_participants FOR UPDATE
  USING (
    auth.role() = 'authenticated'
    AND chat_participants.user_id = auth.uid()
  )
  WITH CHECK (
    auth.role() = 'authenticated'
    AND chat_participants.user_id = auth.uid()
  );

CREATE POLICY "chat_participants_delete_own"
  ON chat_participants FOR DELETE
  USING (
    auth.role() = 'authenticated'
    AND chat_participants.user_id = auth.uid()
  );
