-- ============================================================================
-- HUSH - Complete Database Schema for Supabase
-- ============================================================================
-- This schema supports:
-- - Email/password authenticated users
-- - One-to-one encrypted chats
-- - Group chats with key distribution
-- - Anonymous shared-key sessions
-- - Real-time typing indicators and presence
-- - Encrypted media storage
-- 
-- SECURITY NOTES:
-- - ALL tables have Row Level Security (RLS) enabled
-- - Server NEVER sees plaintext - only ciphertext
-- - Rate limiting on anonymous session joins
-- - Minimal metadata stored for privacy
-- ============================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- PROFILES TABLE
-- Stores user profiles with public keys for E2EE
-- ============================================================================

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  username TEXT UNIQUE,
  display_name TEXT,
  
  -- Cryptographic keys (base64url-encoded)
  public_key TEXT NOT NULL, -- X25519 public key for key exchange
  signing_public_key TEXT NOT NULL, -- Ed25519 public key for signatures
  
  -- Profile metadata
  avatar_url TEXT,
  bio TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_seen_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_email ON profiles(email);

-- RLS Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all profiles"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================================================
-- CONVERSATIONS TABLE
-- Stores conversation metadata (direct, group, anonymous)
-- ============================================================================

CREATE TYPE conversation_type AS ENUM ('direct', 'group', 'anonymous');

CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type conversation_type NOT NULL,
  
  -- Conversation metadata (minimal for privacy)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_message_at TIMESTAMPTZ,
  
  -- For direct chats (encrypted)
  encrypted_name TEXT, -- For groups, encrypted with group key
  
  -- Flags
  is_active BOOLEAN DEFAULT true
);

-- Indexes
CREATE INDEX idx_conversations_type ON conversations(type);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);

-- RLS Policies
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view conversations they are members of"
  ON conversations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversation_members
      WHERE conversation_id = conversations.id
        AND user_id = auth.uid()
    )
    OR type = 'anonymous' -- Anonymous sessions visible during active session
  );

CREATE POLICY "Users can create conversations"
  ON conversations FOR INSERT
  WITH CHECK (true);

-- ============================================================================
-- CONVERSATION MEMBERS TABLE
-- Stores membership and per-member encrypted keys
-- ============================================================================

CREATE TABLE IF NOT EXISTS conversation_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL, -- For anonymous, stores ephemeral ID
  
  -- Encrypted conversation key (encrypted with user's public key)
  encrypted_conversation_key TEXT,
  
  -- For anonymous sessions
  is_anonymous BOOLEAN DEFAULT false,
  ephemeral_public_key TEXT, -- X25519 public key for anonymous participants
  nickname TEXT, -- Optional display name
  
  -- Member metadata
  role TEXT DEFAULT 'member', -- 'owner', 'admin', 'member'
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  left_at TIMESTAMPTZ,
  
  -- Read receipts
  last_read_message_id UUID,
  last_read_at TIMESTAMPTZ,
  
  UNIQUE(conversation_id, user_id)
);

-- Indexes
CREATE INDEX idx_conversation_members_conversation ON conversation_members(conversation_id);
CREATE INDEX idx_conversation_members_user ON conversation_members(user_id);

-- RLS Policies
ALTER TABLE conversation_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view members of their conversations"
  ON conversation_members FOR SELECT
  USING (
    conversation_id IN (
      SELECT conversation_id FROM conversation_members
      WHERE user_id = auth.uid()
    )
    OR is_anonymous = true -- Anonymous participants visible to all in session
  );

CREATE POLICY "Users can insert themselves as members"
  ON conversation_members FOR INSERT
  WITH CHECK (
    user_id = auth.uid()
    OR is_anonymous = true
  );

CREATE POLICY "Users can update their own membership"
  ON conversation_members FOR UPDATE
  USING (user_id = auth.uid());

-- ============================================================================
-- GROUP METADATA TABLE
-- Stores encrypted group information and group keys
-- ============================================================================

CREATE TABLE IF NOT EXISTS group_metadata (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL UNIQUE REFERENCES conversations(id) ON DELETE CASCADE,
  
  -- Encrypted group data
  encrypted_name TEXT NOT NULL,
  encrypted_description TEXT,
  encrypted_avatar_url TEXT,
  
  -- Group key management
  current_key_version INTEGER DEFAULT 1,
  key_rotation_at TIMESTAMPTZ,
  
  -- Group settings
  max_members INTEGER DEFAULT 100,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_group_metadata_conversation ON group_metadata(conversation_id);

-- RLS Policies
ALTER TABLE group_metadata ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view metadata of groups they belong to"
  ON group_metadata FOR SELECT
  USING (
    conversation_id IN (
      SELECT conversation_id FROM conversation_members
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Group admins can update metadata"
  ON group_metadata FOR UPDATE
  USING (
    conversation_id IN (
      SELECT conversation_id FROM conversation_members
      WHERE user_id = auth.uid()
        AND role IN ('owner', 'admin')
    )
  );

-- ============================================================================
-- MESSAGES TABLE
-- Stores encrypted messages (ciphertext only - NO plaintext)
-- ============================================================================

CREATE TYPE message_type AS ENUM ('text', 'image', 'video', 'audio', 'file');

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL, -- For anonymous, ephemeral ID
  
  -- Encrypted message data
  ciphertext TEXT NOT NULL, -- Base64url-encoded encrypted message
  nonce TEXT NOT NULL, -- Base64url-encoded nonce (24 bytes for XChaCha20)
  
  -- For anonymous sessions: encrypted sender info
  sender_blob TEXT, -- JSON with ephemeral_id, public_key, nickname
  
  -- Message metadata
  type message_type DEFAULT 'text',
  
  -- For media messages
  encrypted_media_url TEXT, -- Encrypted URL to Supabase Storage
  encrypted_media_key TEXT, -- Key to decrypt media (encrypted per-recipient)
  media_mime_type TEXT,
  media_size_bytes BIGINT,
  
  -- Reply/thread support
  reply_to_message_id UUID REFERENCES messages(id),
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  
  -- Flags
  is_edited BOOLEAN DEFAULT false,
  is_deleted BOOLEAN DEFAULT false
);

-- Indexes
CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- RLS Policies
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view messages in their conversations"
  ON messages FOR SELECT
  USING (
    conversation_id IN (
      SELECT conversation_id FROM conversation_members
      WHERE user_id = auth.uid()
        OR is_anonymous = true
    )
  );

CREATE POLICY "Users can insert messages to their conversations"
  ON messages FOR INSERT
  WITH CHECK (
    conversation_id IN (
      SELECT conversation_id FROM conversation_members
      WHERE user_id = auth.uid()
        OR (is_anonymous = true AND user_id = sender_id)
    )
  );

CREATE POLICY "Users can update their own messages"
  ON messages FOR UPDATE
  USING (sender_id = auth.uid());

-- ============================================================================
-- ANONYMOUS SESSIONS TABLE
-- Stores metadata for anonymous shared-key sessions
-- ============================================================================

CREATE TABLE IF NOT EXISTS anonymous_sessions (
  session_id UUID PRIMARY KEY,
  
  -- Session metadata (encrypted on client before storing sensitive fields)
  session_meta JSONB, -- {human_code, owner_hash}
  
  -- Session settings
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  max_participants INTEGER DEFAULT 10,
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  
  -- Rate limiting tracking
  join_attempts INTEGER DEFAULT 0,
  last_join_attempt_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_anonymous_sessions_expires ON anonymous_sessions(expires_at);
CREATE INDEX idx_anonymous_sessions_active ON anonymous_sessions(is_active);

-- RLS Policies
ALTER TABLE anonymous_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active sessions"
  ON anonymous_sessions FOR SELECT
  USING (is_active = true AND expires_at > NOW());

CREATE POLICY "Anyone can create sessions"
  ON anonymous_sessions FOR INSERT
  WITH CHECK (true);

-- Auto-expire sessions (run periodically)
CREATE OR REPLACE FUNCTION expire_anonymous_sessions()
RETURNS void AS $$
BEGIN
  UPDATE anonymous_sessions
  SET is_active = false
  WHERE expires_at <= NOW() AND is_active = true;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TYPING STATUS TABLE
-- Real-time typing indicators
-- ============================================================================

CREATE TABLE IF NOT EXISTS typing_status (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  
  is_typing BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(conversation_id, user_id)
);

-- Indexes
CREATE INDEX idx_typing_status_conversation ON typing_status(conversation_id);

-- RLS Policies
ALTER TABLE typing_status ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view typing status in their conversations"
  ON typing_status FOR SELECT
  USING (
    conversation_id IN (
      SELECT conversation_id FROM conversation_members
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own typing status"
  ON typing_status FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- PRESENCE TABLE
-- Online/offline status
-- ============================================================================

CREATE TABLE IF NOT EXISTS presence (
  user_id UUID PRIMARY KEY,
  status TEXT DEFAULT 'offline', -- 'online', 'away', 'offline'
  last_seen_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE presence ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all presence"
  ON presence FOR SELECT
  USING (true);

CREATE POLICY "Users can update their own presence"
  ON presence FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- PENDING CONTACTS TABLE
-- Friend/contact requests
-- ============================================================================

CREATE TABLE IF NOT EXISTS pending_contacts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  requester_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  requestee_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
  
  -- Encrypted introduction message
  encrypted_message TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(requester_id, requestee_id)
);

-- Indexes
CREATE INDEX idx_pending_contacts_requester ON pending_contacts(requester_id);
CREATE INDEX idx_pending_contacts_requestee ON pending_contacts(requestee_id);

-- RLS Policies
ALTER TABLE pending_contacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their contact requests"
  ON pending_contacts FOR SELECT
  USING (
    requester_id = auth.uid() OR requestee_id = auth.uid()
  );

CREATE POLICY "Users can create contact requests"
  ON pending_contacts FOR INSERT
  WITH CHECK (requester_id = auth.uid());

CREATE POLICY "Users can update requests they're involved in"
  ON pending_contacts FOR UPDATE
  USING (
    requester_id = auth.uid() OR requestee_id = auth.uid()
  );

-- ============================================================================
-- RATE LIMITING FUNCTION
-- Prevent brute-force attacks on anonymous sessions
-- ============================================================================

CREATE OR REPLACE FUNCTION check_anonymous_join_rate_limit(p_session_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_attempts INTEGER;
  v_last_attempt TIMESTAMPTZ;
  v_window INTERVAL := '1 minute';
  v_max_attempts INTEGER := 5;
BEGIN
  SELECT join_attempts, last_join_attempt_at
  INTO v_attempts, v_last_attempt
  FROM anonymous_sessions
  WHERE session_id = p_session_id;
  
  -- Reset counter if window has passed
  IF v_last_attempt IS NULL OR (NOW() - v_last_attempt) > v_window THEN
    UPDATE anonymous_sessions
    SET join_attempts = 1, last_join_attempt_at = NOW()
    WHERE session_id = p_session_id;
    RETURN true;
  END IF;
  
  -- Check if under limit
  IF v_attempts < v_max_attempts THEN
    UPDATE anonymous_sessions
    SET join_attempts = join_attempts + 1, last_join_attempt_at = NOW()
    WHERE session_id = p_session_id;
    RETURN true;
  END IF;
  
  -- Rate limited
  RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Update updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_metadata_updated_at BEFORE UPDATE ON group_metadata
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update conversation last_message_at on new message
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations
  SET last_message_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_conversation_on_message AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION update_conversation_last_message();

-- ============================================================================
-- REALTIME PUBLICATION
-- Enable realtime for tables that need it
-- ============================================================================

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE typing_status;
ALTER PUBLICATION supabase_realtime ADD TABLE presence;
ALTER PUBLICATION supabase_realtime ADD TABLE conversation_members;

-- ============================================================================
-- STORAGE BUCKETS
-- For encrypted media files
-- ============================================================================

-- Run this in Supabase Dashboard > Storage

-- Create bucket for encrypted media
-- INSERT INTO storage.buckets (id, name, public) VALUES ('encrypted-media', 'encrypted-media', false);

-- RLS policies for storage
-- CREATE POLICY "Users can upload encrypted media"
--   ON storage.objects FOR INSERT
--   WITH CHECK (bucket_id = 'encrypted-media' AND auth.role() = 'authenticated');

-- CREATE POLICY "Users can read encrypted media"
--   ON storage.objects FOR SELECT
--   USING (bucket_id = 'encrypted-media');

-- ============================================================================
-- SEED DATA (Optional)
-- ============================================================================

-- Example: Create a system user for notifications
-- INSERT INTO auth.users (id, email) VALUES 
--   ('00000000-0000-0000-0000-000000000000', 'system@hush.app');

-- ============================================================================
-- MIGRATION NOTES
-- ============================================================================
-- 1. Run this schema in your Supabase SQL editor
-- 2. Enable realtime for required tables in Dashboard > Database > Replication
-- 3. Create storage buckets in Dashboard > Storage
-- 4. Update Flutter app .env with your Supabase URL and anon key
-- 5. Test authentication and encryption flows
-- 
-- SECURITY AUDIT CHECKLIST:
-- [ ] All tables have RLS enabled
-- [ ] No plaintext messages stored
-- [ ] Rate limiting implemented for anonymous joins
-- [ ] Proper indexes for performance
-- [ ] Realtime publications configured
-- [ ] Storage policies configured
-- [ ] Triggers working correctly
-- ============================================================================
