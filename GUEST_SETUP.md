# Guest Login Feature - Quick Setup Guide

## Prerequisites
- Flutter SDK installed
- Supabase project created
- `.env` file configured with Supabase credentials

## Installation Steps

### 1. Install Dependencies

Run this command in the project root:

```powershell
flutter pub get
```

This will install the new dependency:
- `flutter_secure_storage` - For secure local session storage

### 2. Database Setup

Execute the SQL migrations in your Supabase SQL Editor:

#### a. Ensure base schema is applied
```sql
-- Run if not already done
-- File: supabase/migrations/001_initial_schema.sql
```

#### b. Apply anonymous session cleanup migration
```sql
-- File: supabase/migrations/20251121_anonymous_session_cleanup.sql
```

Copy and paste the contents of `supabase/migrations/20251121_anonymous_session_cleanup.sql` into the Supabase SQL Editor and execute.

### 3. Set Up Automatic Cleanup (Choose One)

#### Option A: Using pg_cron (Recommended)
The migration already sets this up if pg_cron is available. Verify:

```sql
-- Check if scheduled
SELECT * FROM cron.job WHERE jobname = 'cleanup-expired-anonymous-sessions';
```

#### Option B: Using Supabase Edge Functions
1. Create a new Edge Function in Supabase Dashboard
2. Name it: `cleanup-anonymous-sessions`
3. Use this code:

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  const { data, error } = await supabase.rpc('cleanup_expired_anonymous_sessions')
  
  return new Response(
    JSON.stringify({ cleaned: data, error }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
```

4. Deploy the function
5. In Supabase Dashboard → Edge Functions → Cron, add:
   - Schedule: `0 * * * *` (every hour)
   - Function: `cleanup-anonymous-sessions`

### 4. Test the Setup

#### Test 1: Create Guest Session
```powershell
flutter run
```

1. Tap "Continue as Guest"
2. Tap "Create New Session"
3. Configure settings and create
4. Verify QR code and session code appear

#### Test 2: Join Session
1. Open app on another device/emulator
2. Tap "Continue as Guest"
3. Tap "Join Existing Session"
4. Enter the session code from Test 1
5. Verify you can see the lobby

#### Test 3: Chat
1. From lobby, tap "Start Chat"
2. Send a message
3. Verify it appears encrypted on the other device
4. Check the expiry banner shows correct time

#### Test 4: Database Cleanup
```sql
-- Manually trigger cleanup (safe, won't delete active sessions)
SELECT cleanup_expired_anonymous_sessions();

-- Check result
SELECT * FROM anonymous_sessions WHERE is_active = false;
```

### 5. Platform-Specific Setup

#### Android
No additional setup needed. Secure storage works out of the box.

#### iOS
No additional setup needed. Keychain access is automatic.

#### Web
flutter_secure_storage uses browser localStorage on web (not as secure). For production web, consider alternative storage or disable guest login on web.

## Verification Checklist

- [ ] `flutter pub get` completed successfully
- [ ] Database migrations applied
- [ ] Cleanup job scheduled (pg_cron or Edge Function)
- [ ] Can create anonymous session from app
- [ ] Can join session with code
- [ ] Can join session with QR scan
- [ ] Messages encrypt/decrypt properly
- [ ] Expiry banner shows in chat
- [ ] Sessions auto-cleanup after expiry
- [ ] Session state persists across app restarts
- [ ] Rate limiting prevents brute force

## Common Issues

### Issue: `flutter_secure_storage` not found
**Solution**: Run `flutter pub get` and restart your IDE

### Issue: QR scanner not working
**Solution**: 
- Android: Add camera permission to `AndroidManifest.xml`
- iOS: Add camera usage description to `Info.plist`

### Issue: Session cleanup not running
**Solution**: 
- Check pg_cron is enabled: `SELECT * FROM pg_extension WHERE extname = 'pg_cron';`
- Or set up Edge Function as fallback
- Or call cleanup manually for testing

### Issue: "Session not found" when joining
**Solution**:
- Verify session was created in database
- Check RLS policies allow anonymous access
- Ensure session hasn't expired

### Issue: Messages not decrypting
**Solution**:
- Verify both users have same session_secret
- Check session_id matches
- Review encryption service logs

## Performance Tuning

For high-traffic deployments:

1. **Increase cleanup frequency**
   ```sql
   -- Run every 15 minutes instead of hourly
   SELECT cron.schedule(
     'cleanup-expired-anonymous-sessions',
     '*/15 * * * *',
     $$SELECT cleanup_expired_anonymous_sessions();$$
   );
   ```

2. **Add database indexes** (already in migration)
   ```sql
   CREATE INDEX idx_anonymous_sessions_cleanup 
     ON anonymous_sessions(expires_at, is_active);
   ```

3. **Monitor cleanup performance**
   ```sql
   -- Check how many sessions cleaned
   SELECT cleanup_expired_anonymous_sessions();
   ```

## Security Hardening

1. **Rate Limiting**: Already implemented in migration
2. **Session Key Length**: Use QR codes (longer keys) instead of manual entry
3. **Expiry Defaults**: Consider shorter default (6h instead of 24h)
4. **Max Participants**: Adjust based on use case (default 10)

## Next Steps

After setup:
1. Read [GUEST_LOGIN_GUIDE.md](GUEST_LOGIN_GUIDE.md) for user documentation
2. Test all user flows
3. Configure your preferred expiry defaults
4. Set up monitoring for session metrics
5. Plan migration path to authenticated users

## Support

If you encounter issues:
1. Check Flutter logs: `flutter logs`
2. Check Supabase logs in Dashboard
3. Verify database schema matches migration
4. Test cleanup function manually
5. Review security settings and RLS policies

---

**Important**: This is a production-ready feature but should be tested thoroughly in your specific deployment environment before releasing to users.
