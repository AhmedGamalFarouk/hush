-- Fix infinite recursion in RLS policies by using a SECURITY DEFINER function
-- This function bypasses RLS to check membership, breaking the recursion loop

CREATE OR REPLACE FUNCTION is_conversation_member(_conversation_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM conversation_members
    WHERE conversation_id = _conversation_id
    AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated and anon users
GRANT EXECUTE ON FUNCTION is_conversation_member(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION is_conversation_member(UUID) TO anon;

-- Update conversation_members SELECT policy
DROP POLICY IF EXISTS "Users can view members of their conversations" ON conversation_members;

CREATE POLICY "Users can view members of their conversations"
  ON conversation_members FOR SELECT
  USING (
    -- User can see entry if they are a member of the conversation
    is_conversation_member(conversation_id)
    OR 
    -- Or if it's their own entry (explicit check)
    user_id = auth.uid()
    OR 
    -- Anonymous participants visible to all (simplified for now)
    is_anonymous = true
  );

-- Update conversation_members INSERT policy
DROP POLICY IF EXISTS "Users can manage conversation members" ON conversation_members;
DROP POLICY IF EXISTS "Users can insert themselves as members" ON conversation_members;

CREATE POLICY "Users can manage conversation members"
  ON conversation_members FOR INSERT
  WITH CHECK (
    -- User is adding themselves
    user_id = auth.uid()
    OR
    -- User is adding someone to a conversation they are already a member of
    is_conversation_member(conversation_id)
    OR
    -- Anonymous users
    is_anonymous = true
  );

-- Update conversations SELECT policy to be safe as well
DROP POLICY IF EXISTS "Users can view conversations they are members of" ON conversations;

CREATE POLICY "Users can view conversations they are members of"
  ON conversations FOR SELECT
  USING (
    is_conversation_member(id)
    OR 
    type = 'anonymous'
  );
