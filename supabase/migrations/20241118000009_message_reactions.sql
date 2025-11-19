-- Message Reactions Table
-- Stores emoji reactions on messages

CREATE TABLE IF NOT EXISTS message_reactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  emoji TEXT NOT NULL CHECK (length(emoji) <= 10),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Ensure one user can only react once with same emoji per message
  UNIQUE(message_id, user_id, emoji)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_message_reactions_message_id ON message_reactions(message_id);
CREATE INDEX IF NOT EXISTS idx_message_reactions_user_id ON message_reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_message_reactions_created_at ON message_reactions(created_at);

-- Row Level Security
ALTER TABLE message_reactions ENABLE ROW LEVEL SECURITY;

-- Users can see reactions in their conversations
CREATE POLICY "Users can see reactions in their conversations"
  ON message_reactions
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM messages m
      INNER JOIN conversation_members cm ON cm.conversation_id = m.conversation_id
      WHERE m.id = message_reactions.message_id
        AND cm.user_id = auth.uid()
    )
  );

-- Users can add reactions to messages in their conversations
CREATE POLICY "Users can add reactions to messages in their conversations"
  ON message_reactions
  FOR INSERT
  WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM messages m
      INNER JOIN conversation_members cm ON cm.conversation_id = m.conversation_id
      WHERE m.id = message_reactions.message_id
        AND cm.user_id = auth.uid()
    )
  );

-- Users can remove their own reactions
CREATE POLICY "Users can remove their own reactions"
  ON message_reactions
  FOR DELETE
  USING (user_id = auth.uid());

-- Trigger to notify about new reactions via Realtime
CREATE OR REPLACE FUNCTION notify_reaction_change()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify(
    'message_reactions_change',
    json_build_object(
      'message_id', COALESCE(NEW.message_id, OLD.message_id),
      'operation', TG_OP
    )::text
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER message_reactions_notify
  AFTER INSERT OR UPDATE OR DELETE ON message_reactions
  FOR EACH ROW
  EXECUTE FUNCTION notify_reaction_change();

-- Comments
COMMENT ON TABLE message_reactions IS 'Emoji reactions on messages';
COMMENT ON COLUMN message_reactions.message_id IS 'Reference to the message being reacted to';
COMMENT ON COLUMN message_reactions.user_id IS 'User who added the reaction';
COMMENT ON COLUMN message_reactions.emoji IS 'Emoji character(s) for the reaction';
