CREATE OR REPLACE FUNCTION can_user_access_chat(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION validate_chat_room_access(
  room_id UUID,
  user_id UUID
)
RETURNS JSONB AS $$
DECLARE
  v_is_participant BOOLEAN;
  v_is_public_room BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM chat_rooms
    WHERE id = room_id
      AND name = 'Global Chat'
  ) INTO v_is_public_room;

  IF v_is_public_room THEN
    RETURN jsonb_build_object(
      'can_access', true,
      'reason', 'Access granted',
      'action_required', null
    );
  END IF;

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

  RETURN jsonb_build_object(
    'can_access', true,
    'reason', 'Access granted',
    'action_required', null
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP POLICY IF EXISTS "chat_rooms_select_subscribed" ON chat_rooms;
DROP POLICY IF EXISTS "chat_rooms_insert_subscribed" ON chat_rooms;
DROP POLICY IF EXISTS "chat_messages_select_subscribed" ON chat_messages;
DROP POLICY IF EXISTS "chat_messages_insert_subscribed" ON chat_messages;
DROP POLICY IF EXISTS "chat_participants_select_subscribed" ON chat_participants;

DROP POLICY IF EXISTS "chat_rooms_select" ON chat_rooms;
DROP POLICY IF EXISTS "chat_rooms_insert" ON chat_rooms;
DROP POLICY IF EXISTS "chat_messages_select" ON chat_messages;
DROP POLICY IF EXISTS "chat_messages_insert" ON chat_messages;
DROP POLICY IF EXISTS "chat_participants_select" ON chat_participants;

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

CREATE POLICY "chat_participants_select_authenticated"
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

CREATE POLICY "chat_participants_insert_authenticated"
  ON chat_participants FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
    AND EXISTS (
      SELECT 1
      FROM chat_rooms r
      WHERE r.id = chat_participants.chat_room_id
        AND auth.uid() = ANY(r.participant_ids)
        -- Cast uid to text to match participant_ids text[]
        -- Note: If participant_ids is uuid[], remove this cast
        AND chat_participants.user_id::text = ANY(r.participant_ids)
    )
  );

CREATE POLICY "chat_participants_update_authenticated"
  ON chat_participants FOR UPDATE
  USING (
    auth.role() = 'authenticated'
    AND user_id = auth.uid()
  )
  WITH CHECK (
    auth.role() = 'authenticated'
    AND user_id = auth.uid()
  );
