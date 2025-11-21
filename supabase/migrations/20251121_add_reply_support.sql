-- Add reply_to_id column to messages table (if not exists)
-- This migration ensures reply functionality works correctly

-- Add the column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'messages' AND column_name = 'reply_to_id'
  ) THEN
    ALTER TABLE messages ADD COLUMN reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL;
    CREATE INDEX IF NOT EXISTS idx_messages_reply_to ON messages(reply_to_id);
    COMMENT ON COLUMN messages.reply_to_id IS 'Reference to the message being replied to';
  END IF;
END $$;

-- Also ensure we have the reply_to_message_id column mapped to reply_to_id for backwards compatibility
-- (The schema uses reply_to_message_id but the app uses reply_to_id)
-- We'll standardize on reply_to_id

-- If reply_to_message_id exists and reply_to_id doesn't, rename it
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'messages' AND column_name = 'reply_to_message_id'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'messages' AND column_name = 'reply_to_id'
  ) THEN
    ALTER TABLE messages RENAME COLUMN reply_to_message_id TO reply_to_id;
  END IF;
END $$;

COMMENT ON TABLE messages IS 'Encrypted messages with support for replies and reactions';
