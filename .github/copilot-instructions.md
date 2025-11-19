# Hush - AI Agent Instructions

## Project Overview
Hush is a production-ready Flutter chat application with **end-to-end encryption (E2EE)**, Supabase backend, and unique features including:
- Email/password authentication
- One-to-one and group encrypted chats
- QR-based quick contact add
- **Anonymous shared-key (no-auth) chat sessions** - users enter the same secret key to connect without accounts
- Encrypted media/file sharing
- Real-time typing indicators, read receipts, presence

## Architecture Principles

### Clean Architecture with Riverpod
- **Folder structure**: `lib/{feature}/` with subfolders:
  - `presentation/` - UI widgets and screens
  - `providers/` - Riverpod state management
  - `services/` - Business logic and API calls
  - `models/` - Data classes
- **Key modules**: `auth/`, `chat/`, `groups/`, `qr/`, `anonymous/`, `encryption/`, `media/`
- Use Riverpod for all state management (not BLoC)
- Dependency injection via Riverpod providers

### Encryption First
All crypto operations use **flutter_sodium** (libsodium bindings):
- **AEAD**: XChaCha20-Poly1305 for message encryption
- **KDF**: HKDF-SHA256 for key derivation; Argon2/scrypt for human passphrases
- **Asymmetric**: X25519 for DH key exchange; Ed25519 for signatures
- **Critical**: Never store plaintext on Supabase - only ciphertext
- Document all crypto assumptions inline with references to libsodium APIs

### Anonymous Sessions Architecture
**Key crypto design** (see `lib/anonymous/` when implemented):
1. Generate `session_secret` (256-bit) + `session_id` (UUID)
2. Use HKDF-SHA256 on `session_secret || session_id` → derive `master_sym_key` + `bootstrap_seed`
3. Each device generates ephemeral X25519 keypair for forward secrecy
4. Ephemeral public keys encrypted/signed with `master_sym_key` for peer authentication
5. Messages encrypted with XChaCha20-Poly1305 using derived session keys
6. Support group key rotation on membership changes

**Supabase role**: Dumb relay storing only ciphertext, session_id, timestamps. No plaintext ever.

## Supabase Integration

### Database Schema
Key tables (create in Supabase SQL editor):
- `profiles` - User profiles with public keys
- `conversations` - Chat metadata (type: 'direct' | 'group' | 'anonymous')
- `conversation_members` - Membership and per-member encrypted keys
- `group_metadata` - Group info and encrypted group keys
- `messages` - Encrypted messages (ciphertext, nonce, sender_blob)
- `anonymous_sessions` - Session metadata (session_id, expires_at, max_participants)
- `typing_status`, `presence` - Real-time indicators
- `pending_contacts` - Friend requests

### Row Level Security (RLS)
- Enable RLS on ALL tables
- Rate-limit anonymous session joins in Postgres functions to prevent brute-force
- Use `auth.uid()` for authenticated users; `session_id` hash for anonymous
- Example policy pattern: `CREATE POLICY "Users see own data" ON profiles FOR SELECT USING (auth.uid() = id)`

### Realtime Channels
- Subscribe to `messages:{conversation_id}` for new messages
- Subscribe to `typing:{conversation_id}` for typing indicators
- Subscribe to `presence:{conversation_id}` for online status
- Handle reconnection and message ordering client-side

## UI/UX Guidelines

### Design System - NO GRADIENTS
- **Strictly flat surfaces only** - no gradients anywhere
- Use modern typography with clear hierarchy
- Generous spacing and padding (8dp grid)
- Smooth micro-interactions (subtle animations, no heavy shadows)
- Color palette: neutral base + 1-2 accent colors
- Theme defined in `lib/core/theme/` with light/dark modes

### Key Screens to Implement
1. **Auth**: Login, Register (email/password via Supabase)
2. **Chat List**: Conversations list with unread badges
3. **Chat**: Message thread, typing indicators, encrypted media
4. **Group**: Create/manage groups, member list, key rotation UI
5. **QR**: Generate QR (user ID + public key), Scan to add contact
6. **Anonymous**: 
   - Create session (show key + QR + human code)
   - Join session (enter key or scan)
   - Session lobby (participants, settings, expiry countdown)
   - In-chat banner for anonymous sessions

## Development Workflow

### Setup Commands
```powershell
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Generate code (if using freezed/json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Testing Strategy
- Unit tests for all crypto functions (KDF, encrypt/decrypt, key rotation)
- Widget tests for UI components
- Integration tests for auth and message flows
- Test anonymous session join/leave scenarios
- Mock Supabase with `mocktail` package

### Environment Variables
Create `.env` file (add to .gitignore):
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```
Load with `flutter_dotenv` or `envied` package

## Critical Patterns & Conventions

### Error Handling
- Use `Result<T, E>` pattern or `dartz` Either for service layer
- Never throw exceptions across async boundaries
- Show user-friendly error messages (never expose crypto internals)

### Encryption Service Pattern
```dart
// lib/encryption/services/encryption_service.dart
class EncryptionService {
  // All methods must be thoroughly documented with:
  // - Input/output formats
  // - Security assumptions
  // - Libsodium API references
  
  Future<EncryptedMessage> encryptMessage(String plaintext, Uint8List key) {
    // Use crypto_aead_xchacha20poly1305_ietf_encrypt
  }
  
  Future<Uint8List> deriveSessionKey(String sessionSecret, String sessionId) {
    // Use crypto_kdf_hkdf_sha256
  }
}
```

### State Management Pattern
```dart
// Use Riverpod AsyncNotifier for async state
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  Future<List<Message>> build(String conversationId) async {
    // Load and decrypt messages
  }
  
  Future<void> sendMessage(String content) async {
    // Encrypt and send
  }
}
```

### Supabase Client Singleton
```dart
// lib/core/supabase/supabase_client.dart
final supabaseProvider = Provider((ref) => Supabase.instance.client);
```

## Security Checklist (for AI agents)

When implementing crypto features:
- [ ] All keys generated with cryptographically secure RNG
- [ ] Nonces are unique per message (use random or monotonic counter)
- [ ] Key derivation uses proper salt and context info
- [ ] Forward secrecy via ephemeral key exchange
- [ ] No plaintext logged or stored on server
- [ ] Rate limiting on anonymous session joins
- [ ] Document threat model and what attack vectors are NOT protected
- [ ] Recommend high-entropy keys (32-64 bytes base64)
- [ ] Warn users about anonymous session link-based security

## Future Extensions (documented but not yet implemented)
- Convert anonymous sessions to authenticated accounts (key migration)
- Voice/video calls with WebRTC
- Message search (encrypted index)
- Multi-device sync with encrypted device keys
- Disappearing messages (client-side deletion)

## References
- [Development Plan](../development plan.md) - Full specification
- [Flutter Sodium](https://pub.dev/packages/flutter_sodium) - Crypto library
- [Supabase Docs](https://supabase.com/docs) - Backend platform
- [Riverpod Docs](https://riverpod.dev) - State management
