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

-- ============================================================================
-- NOTES:
-- - This trigger extracts username, display_name, and keys from user metadata
-- - The Flutter app must pass these in the signUp() data parameter
-- - Works with email confirmation enabled or disabled
-- - Uses ON CONFLICT to avoid duplicates
-- ============================================================================
