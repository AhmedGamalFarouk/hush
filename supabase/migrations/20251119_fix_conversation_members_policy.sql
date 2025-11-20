-- Fix RLS policy for conversation_members to allow adding other users
-- This is required for creating direct conversations where one user adds another

DROP POLICY IF EXISTS "Users can insert themselves as members" ON conversation_members;

CREATE POLICY "Users can manage conversation members"
  ON conversation_members FOR INSERT
  WITH CHECK (
    -- User is adding themselves
    user_id = auth.uid()
    OR
    -- User is adding someone to a conversation they are already a member of
    EXISTS (
      SELECT 1 FROM conversation_members cm
      WHERE cm.conversation_id = conversation_members.conversation_id
      AND cm.user_id = auth.uid()
    )
    OR
    -- Anonymous users
    is_anonymous = true
  );
