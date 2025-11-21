# Guest Login & Anonymous Sessions - User Guide

## Overview

Hush now supports **guest login** with temporary, anonymous chat sessions. Users can create or join encrypted chat sessions without creating an account, perfect for quick, secure conversations that auto-delete after 24 hours (configurable).

---

## Features

### 🔒 **No Account Required**
- Skip registration entirely
- Start chatting in seconds
- No email, no password, no personal data

### ⏰ **Temporary Sessions**
- Auto-expire after 24 hours (default)
- Configurable expiry: 1 hour, 6 hours, 24 hours, or 7 days
- Automatic cleanup of messages and data after expiry

### 👥 **Group Support**
- Support for up to 50 participants per session
- Real-time typing indicators
- Presence status
- Read receipts

### 🔐 **End-to-End Encrypted**
- XChaCha20-Poly1305 AEAD encryption
- Forward secrecy via ephemeral key exchange
- Server never sees plaintext
- Same security guarantees as authenticated chats

### 📱 **Cross-Platform**
- Share session codes or QR codes
- Join from any device
- Session state persists across app restarts (until expiry)

---

## User Journey

### 1. **Login Screen**

When you open the app, you'll see:
- Standard email/password login
- Registration option
- **NEW**: "Continue as Guest" button

Tap **"Continue as Guest"** to enter anonymous mode.

### 2. **Anonymous Home Screen**

After entering guest mode, you have two options:

#### **Option A: Create New Session**
1. Tap **"Create New Session"**
2. Configure session settings:
   - **Nickname** (optional): How others see you
   - **Expiry**: Choose from 1h, 6h, 24h, or 7 days
   - **Max Participants**: 2-50 people
3. Tap **"Create Session"**
4. Share the session:
   - **Session Code**: Human-readable code (e.g., `HUSH-AB12CD`)
   - **QR Code**: Scan to join instantly
   - **Share Button**: Send via any app

#### **Option B: Join Existing Session**
1. Tap **"Join Existing Session"**
2. Enter session information:
   - Type the session code manually, OR
   - Tap **"Scan QR Code"** to scan
3. Add your nickname (optional)
4. Tap **"Join Session"**

### 3. **Session Lobby**

Before entering the chat, you'll see:
- **Session info**: Expiry time, participant count
- **Participant list**: All current members
- **Session details**: Code, creation time, settings

Tap **"Start Chat"** when ready.

### 4. **Anonymous Chat**

The chat experience is identical to regular chats with:
- ✅ End-to-end encryption
- ✅ Media sharing (images, videos, files)
- ✅ Typing indicators
- ✅ Message reactions
- ✅ Reply/forward messages
- ⚠️ **Expiry banner**: Shows time remaining before auto-delete

### 5. **Session Expiry**

When a session expires:
- All messages are permanently deleted
- All participants are removed
- Session state is cleared from all devices
- Cannot be recovered (by design)

---

## Security & Privacy

### ✅ **What's Protected**

- **Message Confidentiality**: All messages encrypted end-to-end
- **Forward Secrecy**: Ephemeral keys provide PFS
- **Authenticity**: Messages verified via session key
- **Automatic Deletion**: No trace after expiry

### ⚠️ **Security Limitations**

- **Link-based security**: Anyone with the session code can join
- **No long-term identity**: No way to verify participant identity
- **Session key = full access**: If leaked, session is compromised
- **No recovery**: Deleted sessions cannot be restored

### 🛡️ **Best Practices**

1. **Share session codes securely**
   - Don't post publicly
   - Use encrypted channels (Signal, Wire)
   - Share in person when possible

2. **Use short expiry for sensitive topics**
   - 1-6 hours for confidential discussions
   - 24 hours for casual chats
   - Avoid 7-day sessions for sensitive data

3. **Create high-entropy keys**
   - Use generated codes (don't make up your own)
   - Longer keys = better security
   - QR codes preferred over manual entry

4. **Verify participants**
   - Check nicknames
   - Confirm via out-of-band channel
   - Be cautious with unknown joiners

5. **Know when to use accounts**
   - Recurring conversations → use accounts
   - Long-term relationships → use accounts
   - Identity verification needed → use accounts

---

## Technical Details

### Architecture

```
User Flow:
1. User taps "Continue as Guest"
2. App generates/joins session:
   - session_secret (256-bit random key)
   - session_id (UUID v4)
   - Derives master_sym_key via HKDF
3. Creates ephemeral X25519 keypair
4. Stores LocalSessionState securely (flutter_secure_storage)
5. Enters chat with E2EE enabled

Message Flow:
1. User sends message
2. Encrypted with XChaCha20-Poly1305
3. Sent to Supabase as ciphertext only
4. Realtime broadcast to participants
5. Each participant decrypts locally

Expiry Flow:
1. Database triggers check expires_at
2. Cleanup function runs hourly (pg_cron or Edge Function)
3. Deletes messages, members, conversations
4. Marks session inactive
5. Clients detect expiry and clear local state
```

### Cryptography

- **KDF**: HKDF-SHA256 for key derivation
- **AEAD**: XChaCha20-Poly1305 for messages
- **Key Exchange**: X25519 for ephemeral DH
- **Nonces**: Random 24-byte nonces per message
- **Library**: flutter_sodium (libsodium bindings)

### Database Schema

```sql
-- Anonymous Sessions
CREATE TABLE anonymous_sessions (
  session_id UUID PRIMARY KEY,
  session_meta JSONB,        -- {human_code, owner_hash}
  created_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,    -- Auto-delete trigger
  max_participants INTEGER,
  is_active BOOLEAN
);

-- Messages (same table as authenticated users)
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  conversation_id UUID,      -- = session_id for anonymous
  ciphertext TEXT,           -- Encrypted message
  nonce TEXT,                -- 24-byte nonce
  sender_blob TEXT,          -- {ephemeral_id, public_key, nickname}
  created_at TIMESTAMPTZ
);
```

### Rate Limiting

To prevent brute-force attacks on session codes:
- Max 5 join attempts per minute per session
- Enforced via Postgres function
- Tracks attempts in `anonymous_sessions.join_attempts`

---

## Migration Path

### Converting Anonymous to Authenticated

If you start with a guest session and want to keep the conversation:

1. **Register an account** from Anonymous Home
2. System will offer to migrate session (future feature)
3. Session keys re-encrypted with your account keys
4. Conversation persists beyond 24 hours

**Note**: This feature is planned but not yet implemented. For now, sessions are ephemeral only.

---

## Troubleshooting

### Q: "Session not found" when joining
- Check the code is correct (case-sensitive)
- Session may have expired
- Ask creator to reshare code

### Q: Messages not decrypting
- Ensure you have the correct session key
- Check you're using the same session_id
- Try rejoining the session

### Q: Session disappeared
- Check expiry time (likely expired)
- All data is deleted after expiry
- No recovery possible

### Q: Can't create session
- Check internet connection
- Verify Supabase is accessible
- Try again or contact support

### Q: Storage permission error (Android)
- Grant storage permission for QR sharing
- Check Settings → Apps → Hush → Permissions

---

## Database Setup

To enable anonymous sessions on your Supabase instance:

1. **Run initial schema**:
   ```bash
   psql -h your-db.supabase.co -d postgres -U postgres -f supabase/migrations/001_initial_schema.sql
   ```

2. **Run cleanup migration**:
   ```bash
   psql -h your-db.supabase.co -d postgres -U postgres -f supabase/migrations/20251121_anonymous_session_cleanup.sql
   ```

3. **Set up automatic cleanup** (choose one):

   **Option A: pg_cron (preferred)**
   - Enable pg_cron extension in Supabase Dashboard
   - Migration automatically schedules hourly cleanup

   **Option B: Edge Function**
   - Deploy the cleanup Edge Function
   - Schedule via Supabase cron in Dashboard
   - See migration file for example code

   **Option C: Manual**
   - Run `SELECT cleanup_expired_anonymous_sessions();` periodically
   - Not recommended for production

4. **Verify setup**:
   ```sql
   -- Check cleanup function exists
   SELECT proname FROM pg_proc WHERE proname = 'cleanup_expired_anonymous_sessions';
   
   -- Test cleanup (safe, won't delete active sessions)
   SELECT cleanup_expired_anonymous_sessions();
   ```

---

## Configuration

### Default Settings

```dart
// lib/anonymous/models/anonymous_session.dart
class CreateSessionParams {
  final Duration expiry;              // Default: 24 hours
  final int maxParticipants;          // Default: 10
  final String? nickname;             // Default: null
}
```

### Customization

To change defaults, edit:
- `lib/anonymous/presentation/create_session_screen.dart`
- Modify `_expiry` and `_maxParticipants` initial values

### Environment Variables

No additional env vars needed for anonymous sessions. Uses existing:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

---

## Future Enhancements

- [ ] Session key rotation
- [ ] Anonymous → Authenticated migration
- [ ] Voice/video calls in anonymous sessions
- [ ] Disappearing messages (client-side)
- [ ] Multi-device sync for anonymous sessions
- [ ] Session transfer between devices
- [ ] Admin controls (kick participants, etc.)
- [ ] Custom session branding/themes

---

## Support

For issues or questions:
1. Check this guide first
2. Review [Development Plan](development plan.md)
3. Check Supabase logs for errors
4. File an issue on GitHub

---

**Remember**: Anonymous sessions are designed for temporary, ephemeral communication. For long-term conversations, create a full account with email/password authentication.
