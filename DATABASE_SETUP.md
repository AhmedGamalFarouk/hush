# Hush - Database Schema Setup

This document provides the SQL schema for setting up the Supabase database for the Hush encrypted chat application.

## Prerequisites

- A Supabase project created at https://supabase.com
- Access to the SQL Editor in your Supabase dashboard

## Setup Instructions

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy and execute each SQL block below in order

---

## 1. Profiles Table

```sql
-- Profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT,
    bio TEXT,
    avatar_url TEXT,
    public_key TEXT NOT NULL, -- X25519 public key (base64url)
    signing_public_key TEXT NOT NULL, -- Ed25519 public key (base64url)
    last_seen TIMESTAMPTZ,
    is_online BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Public profiles are viewable by everyone"
    ON public.profiles FOR SELECT
    USING (TRUE);

CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- Indexes
CREATE INDEX idx_profiles_username ON public.profiles(username);
CREATE INDEX idx_profiles_email ON public.profiles(email);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- AUTO-CREATE PROFILE ON USER SIGNUP
-- This trigger creates a profile automatically when a new user is created
-- in auth.users, even when email confirmation is enabled.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    email,
    username,
    display_name,
    public_key,
    signing_public_key
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'public_key',
    NEW.raw_user_meta_data->>'signing_public_key'
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger that runs after user insert
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

---

## 2. Conversations Table

```sql
-- Conversations table
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type TEXT NOT NULL CHECK (type IN ('direct', 'group', 'anonymous')),
    name TEXT,
    description TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_message_id UUID,
    last_message_at TIMESTAMPTZ,
    metadata JSONB -- For anonymous sessions, group settings, etc.
);

-- Enable RLS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view conversations they are members of"
    ON public.conversations FOR SELECT
    USING (
        id IN (
            SELECT conversation_id FROM public.conversation_members
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create conversations"
    ON public.conversations FOR INSERT
    WITH CHECK (TRUE);

CREATE POLICY "Members can update conversations"
    ON public.conversations FOR UPDATE
    USING (
        id IN (
            SELECT conversation_id FROM public.conversation_members
            WHERE user_id = auth.uid()
        )
    );

-- Indexes
CREATE INDEX idx_conversations_type ON public.conversations(type);
CREATE INDEX idx_conversations_updated_at ON public.conversations(updated_at DESC);

-- Updated_at trigger
CREATE TRIGGER update_conversations_updated_at
    BEFORE UPDATE ON public.conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

## 3. Conversation Members Table

```sql
-- Conversation members table
CREATE TABLE IF NOT EXISTS public.conversation_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    encrypted_conversation_key TEXT NOT NULL, -- Conversation key encrypted with user's public key
    role TEXT DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    last_read_message_id UUID,
    last_read_at TIMESTAMPTZ,
    UNIQUE(conversation_id, user_id)
);

-- Enable RLS
ALTER TABLE public.conversation_members ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view members of their conversations"
    ON public.conversation_members FOR SELECT
    USING (
        conversation_id IN (
            SELECT conversation_id FROM public.conversation_members
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can join conversations"
    ON public.conversation_members FOR INSERT
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Members can add other members"
    ON public.conversation_members FOR INSERT
    WITH CHECK (
        conversation_id IN (
            SELECT conversation_id FROM public.conversation_members
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own member record"
    ON public.conversation_members FOR UPDATE
    USING (user_id = auth.uid());

CREATE POLICY "Admins can delete members"
    ON public.conversation_members FOR DELETE
    USING (
        conversation_id IN (
            SELECT conversation_id FROM public.conversation_members
            WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
        )
    );

-- Indexes
CREATE INDEX idx_conversation_members_conversation_id ON public.conversation_members(conversation_id);
CREATE INDEX idx_conversation_members_user_id ON public.conversation_members(user_id);
```

---

## 4. Messages Table

```sql
-- Messages table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    ciphertext TEXT NOT NULL, -- Encrypted message content (base64url)
    nonce TEXT NOT NULL, -- Encryption nonce (base64url)
    sender_blob TEXT, -- Encrypted sender info for anonymous chats
    type TEXT DEFAULT 'text' CHECK (type IN ('text', 'image', 'file', 'video', 'audio', 'system')),
    status TEXT DEFAULT 'sent' CHECK (status IN ('sending', 'sent', 'delivered', 'read', 'failed')),
    metadata JSONB, -- For media: encrypted URLs, thumbnails, etc.
    reply_to_id UUID REFERENCES public.messages(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Enable RLS
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view messages in their conversations"
    ON public.messages FOR SELECT
    USING (
        conversation_id IN (
            SELECT conversation_id FROM public.conversation_members
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can send messages to their conversations"
    ON public.messages FOR INSERT
    WITH CHECK (
        conversation_id IN (
            SELECT conversation_id FROM public.conversation_members
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own messages"
    ON public.messages FOR UPDATE
    USING (sender_id = auth.uid());

CREATE POLICY "Users can delete own messages"
    ON public.messages FOR DELETE
    USING (sender_id = auth.uid());

-- Indexes
CREATE INDEX idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);

-- Updated_at trigger
CREATE TRIGGER update_messages_updated_at
    BEFORE UPDATE ON public.messages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

## 5. Anonymous Sessions Table

```sql
-- Anonymous sessions table
CREATE TABLE IF NOT EXISTS public.anonymous_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id TEXT UNIQUE NOT NULL, -- External session identifier
    session_meta JSONB, -- Encrypted session metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    max_participants INTEGER DEFAULT 10,
    owner_hash TEXT, -- Hash of owner identifier
    is_active BOOLEAN DEFAULT TRUE
);

-- Enable RLS
ALTER TABLE public.anonymous_sessions ENABLE ROW LEVEL SECURITY;

-- Policies (minimal - anonymous sessions are link-based security)
CREATE POLICY "Anyone can view active sessions"
    ON public.anonymous_sessions FOR SELECT
    USING (is_active = TRUE AND expires_at > NOW());

CREATE POLICY "Anyone can create sessions"
    ON public.anonymous_sessions FOR INSERT
    WITH CHECK (TRUE);

-- Index
CREATE INDEX idx_anonymous_sessions_session_id ON public.anonymous_sessions(session_id);
CREATE INDEX idx_anonymous_sessions_expires_at ON public.anonymous_sessions(expires_at);
```

---

## 6. Additional Tables (Optional)

### Typing Status

```sql
-- Typing status table
CREATE TABLE IF NOT EXISTS public.typing_status (
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (conversation_id, user_id)
);

ALTER TABLE public.typing_status ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view typing in their conversations"
    ON public.typing_status FOR SELECT
    USING (
        conversation_id IN (
            SELECT conversation_id FROM public.conversation_members
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own typing status"
    ON public.typing_status FOR ALL
    USING (user_id = auth.uid());
```

### Presence

```sql
-- Presence table
CREATE TABLE IF NOT EXISTS public.presence (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    is_online BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.presence ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view presence"
    ON public.presence FOR SELECT
    USING (TRUE);

CREATE POLICY "Users can update own presence"
    ON public.presence FOR ALL
    USING (user_id = auth.uid());
```

---

## 7. Enable Realtime

Run this to enable Realtime for the tables:

```sql
-- Enable Realtime for conversations
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;

-- Enable Realtime for messages
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;

-- Enable Realtime for typing status
ALTER PUBLICATION supabase_realtime ADD TABLE public.typing_status;

-- Enable Realtime for presence
ALTER PUBLICATION supabase_realtime ADD TABLE public.presence;

-- Enable Realtime for conversation members
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversation_members;
```

---

## 8. Storage Buckets (for encrypted media)

Go to **Storage** in your Supabase dashboard and create:

1. **Bucket name**: `encrypted-media`
2. **Public**: No (private)
3. **File size limit**: 100MB
4. **Allowed MIME types**: (leave empty for all types)

Then add RLS policies:

```sql
-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload media"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'encrypted-media' 
    AND auth.role() = 'authenticated'
);

-- Allow users to download media they have access to
CREATE POLICY "Users can download media"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'encrypted-media'
    AND auth.role() = 'authenticated'
);

-- Allow users to delete own media
CREATE POLICY "Users can delete own media"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'encrypted-media'
    AND auth.uid()::text = owner
);
```

---

## Verification

After running all the SQL commands, verify your setup:

1. Check **Table Editor** to see all tables created
2. Check **Authentication** > **Policies** to verify RLS is enabled
3. Check **Storage** to confirm the bucket exists
4. Test by running your Flutter app and trying to register a user

---

## Next Steps

1. Update your `.env` file with your Supabase credentials
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app
4. Test registration, login, and messaging features

## Security Notes

- All message content is encrypted client-side before being stored
- Supabase only stores ciphertext, never plaintext messages
- Row Level Security (RLS) ensures users can only access their own data
- For production, implement additional rate limiting and monitoring
- Consider adding audit logs for security events
