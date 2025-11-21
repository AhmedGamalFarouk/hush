-- ============================================================================
-- Anonymous Session Automatic Cleanup
-- ============================================================================
-- This migration adds automatic cleanup of expired anonymous sessions
-- and their associated data (messages, members) to ensure:
-- 1. Sessions expire after their configured expiry time (default 24 hours)
-- 2. All associated data is automatically deleted
-- 3. Database stays clean and performant
-- ============================================================================

-- ============================================================================
-- ENHANCED CLEANUP FUNCTION
-- ============================================================================

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS expire_anonymous_sessions();

-- Create improved cleanup function that also deletes conversations and messages
CREATE OR REPLACE FUNCTION cleanup_expired_anonymous_sessions()
RETURNS INTEGER AS $$
DECLARE
  v_deleted_count INTEGER := 0;
  v_session_ids UUID[];
BEGIN
  -- Find all expired sessions
  SELECT ARRAY_AGG(session_id) INTO v_session_ids
  FROM anonymous_sessions
  WHERE expires_at <= NOW() AND is_active = true;
  
  -- If no expired sessions, exit early
  IF v_session_ids IS NULL OR array_length(v_session_ids, 1) = 0 THEN
    RETURN 0;
  END IF;
  
  -- Delete messages from expired sessions (cascades will handle conversation_members)
  DELETE FROM messages
  WHERE conversation_id = ANY(v_session_ids);
  
  -- Delete conversation members
  DELETE FROM conversation_members
  WHERE conversation_id = ANY(v_session_ids);
  
  -- Delete conversations
  DELETE FROM conversations
  WHERE id = ANY(v_session_ids) AND type = 'anonymous';
  
  -- Mark sessions as inactive and get count
  UPDATE anonymous_sessions
  SET is_active = false
  WHERE session_id = ANY(v_session_ids);
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  
  -- Optional: Delete the anonymous_sessions records entirely after cleanup
  -- Uncomment if you want to completely remove expired sessions
  -- DELETE FROM anonymous_sessions WHERE session_id = ANY(v_session_ids);
  
  RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- SCHEDULED CLEANUP JOB
-- ============================================================================
-- Note: pg_cron extension is required for automatic scheduling
-- If pg_cron is not available, you can call this function manually or
-- use Supabase Edge Functions to trigger it periodically

-- Check if pg_cron extension exists, create if available
DO $$
BEGIN
  -- Try to enable pg_cron (may require superuser privileges)
  IF EXISTS (
    SELECT 1 FROM pg_available_extensions WHERE name = 'pg_cron'
  ) THEN
    CREATE EXTENSION IF NOT EXISTS pg_cron;
    
    -- Remove existing job if it exists
    PERFORM cron.unschedule('cleanup-expired-anonymous-sessions');
    
    -- Schedule cleanup to run every hour
    PERFORM cron.schedule(
      'cleanup-expired-anonymous-sessions',
      '0 * * * *', -- Every hour at minute 0
      $cron$SELECT cleanup_expired_anonymous_sessions();$cron$
    );
    
    RAISE NOTICE 'pg_cron job scheduled successfully';
  ELSE
    RAISE NOTICE 'pg_cron extension not available. Please run cleanup_expired_anonymous_sessions() manually or via Edge Functions';
  END IF;
EXCEPTION
  WHEN insufficient_privilege THEN
    RAISE NOTICE 'Insufficient privileges to enable pg_cron. Please enable manually or use alternative scheduling';
  WHEN OTHERS THEN
    RAISE NOTICE 'Could not schedule cleanup job: %. Please schedule manually.', SQLERRM;
END;
$$;

-- ============================================================================
-- MANUAL CLEANUP HELPER
-- ============================================================================
-- If automatic scheduling is not available, you can call this function
-- periodically from your application or set up a manual cron job

COMMENT ON FUNCTION cleanup_expired_anonymous_sessions() IS 
'Cleans up expired anonymous sessions and their associated data.
Returns the number of sessions cleaned up.
Should be called periodically (e.g., hourly) to maintain database hygiene.';

-- ============================================================================
-- ALTERNATIVE: TRIGGER-BASED PREVENTION
-- ============================================================================
-- Prevent joining expired sessions at the database level

CREATE OR REPLACE FUNCTION prevent_expired_session_join()
RETURNS TRIGGER AS $$
DECLARE
  v_expires_at TIMESTAMPTZ;
  v_is_active BOOLEAN;
BEGIN
  -- Check if joining an anonymous session
  IF NEW.is_anonymous = true THEN
    -- Get session expiry
    SELECT expires_at, is_active INTO v_expires_at, v_is_active
    FROM anonymous_sessions
    WHERE session_id = NEW.conversation_id;
    
    -- Prevent joining if expired or inactive
    IF v_expires_at IS NOT NULL AND (
      v_expires_at <= NOW() OR v_is_active = false
    ) THEN
      RAISE EXCEPTION 'Cannot join expired or inactive anonymous session';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to prevent joining expired sessions
DROP TRIGGER IF EXISTS check_session_expiry_on_join ON conversation_members;
CREATE TRIGGER check_session_expiry_on_join
  BEFORE INSERT ON conversation_members
  FOR EACH ROW
  EXECUTE FUNCTION prevent_expired_session_join();

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================
-- These help with cleanup performance when there are many sessions

CREATE INDEX IF NOT EXISTS idx_anonymous_sessions_cleanup 
  ON anonymous_sessions(expires_at, is_active) 
  WHERE is_active = true;

-- Simple index on conversation_id for messages cleanup
-- (subqueries not allowed in index predicates)
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id
  ON messages(conversation_id);

-- ============================================================================
-- TESTING & VERIFICATION
-- ============================================================================
-- Test the cleanup function (this won't delete anything if no expired sessions)

DO $$
DECLARE
  v_cleaned INTEGER;
BEGIN
  SELECT cleanup_expired_anonymous_sessions() INTO v_cleaned;
  RAISE NOTICE 'Cleaned up % expired anonymous sessions', v_cleaned;
END;
$$;

-- ============================================================================
-- MIGRATION NOTES
-- ============================================================================
-- 1. This migration adds automatic cleanup of expired anonymous sessions
-- 2. If pg_cron is available, cleanup runs automatically every hour
-- 3. If not, call cleanup_expired_anonymous_sessions() manually via:
--    - Supabase Edge Functions (recommended)
--    - Application-level cron job
--    - Manual SQL execution
-- 
-- EDGE FUNCTION EXAMPLE (TypeScript):
-- ```typescript
-- import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
-- import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
-- 
-- serve(async (req) => {
--   const supabase = createClient(
--     Deno.env.get('SUPABASE_URL') ?? '',
--     Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
--   )
--   
--   const { data, error } = await supabase.rpc('cleanup_expired_anonymous_sessions')
--   
--   return new Response(
--     JSON.stringify({ cleaned: data, error }),
--     { headers: { 'Content-Type': 'application/json' } }
--   )
-- })
-- ```
-- 
-- Then schedule this Edge Function with a cron job in Supabase Dashboard
-- ============================================================================

