# Hush 🔒

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase" alt="Supabase">
  <img src="https://img.shields.io/badge/Encryption-libsodium-FF6B6B" alt="libsodium">
  <img src="https://img.shields.io/badge/State-Riverpod-00D9FF" alt="Riverpod">
</p>

**Hush** is a cross-platform, end-to-end encrypted (E2EE) chat application built with Flutter and Supabase. It features military-grade encryption using libsodium, supports one-to-one and group chats, and includes a unique **anonymous session mode** for no-account messaging.


## What is Hush?

Hush is designed for users who need **truly private** messaging:

- **Zero-knowledge architecture:** Server never sees plaintext messages
- **End-to-end encryption:** XChaCha20-Poly1305 AEAD for all messages
- **Anonymous sessions:** Chat without creating an account using shared secret keys
- **Cross-platform:** Runs on Android, iOS, Web, Windows, macOS, and Linux
- **Modern UI:** Clean, gradient-free design with light/dark themes

All cryptographic operations use [**libsodium**](https://libsodium.org), a modern, audited cryptography library.

## Key Features

### 🔐 Security & Privacy

- **End-to-end encryption** for all messages using XChaCha20-Poly1305
- **Forward secrecy** with ephemeral X25519 Diffie-Hellman key exchange
- **Digital signatures** using Ed25519 for message authentication
- **Secure key derivation** with HKDF-SHA256
- **No plaintext on server** — only encrypted ciphertext stored in Supabase

### 💬 Messaging

- **One-to-one chats** with real-time message delivery
- **Group chats** with secure key distribution (in progress)
- **Encrypted media sharing** — files and images (in progress)
- **QR-based contact add** — scan to connect instantly (in progress)
- **Typing indicators** and **read receipts** (in progress)
- **Real-time presence** — see who's online (in progress)

### 🎭 Anonymous Sessions *(Unique Feature)*

Chat without creating an account:

- Users share a **secret key** to join the same session
- Ephemeral identities with forward secrecy
- Session expiry and participant limits
- Rate-limited joins to prevent brute-force attacks
- Option to convert anonymous sessions to authenticated accounts *(planned)*

### 🎨 User Interface

- **Flat, modern design** — no gradients, clean surfaces
- **Light and dark themes**
- **Smooth animations** with micro-interactions
- **8dp grid system** for consistent spacing
- **Clear typography hierarchy**

## Why Use Hush?

Hush is ideal for:

- **Privacy-conscious users** who want E2EE messaging
- **Developers** learning about cryptography in Flutter
- **Educational purposes** demonstrating secure messaging architecture
- **Quick, anonymous chats** without account sign-up

**Not suitable for:**
- Production use without a security audit
- High-stakes scenarios requiring certified security
- Use cases requiring metadata protection (Hush doesn't hide who talks to whom)

## Getting Started

### Prerequisites

- **Flutter SDK:** 3.10 or higher ([installation guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK:** 3.10 or higher (comes with Flutter)
- **Supabase account:** Free tier available at [supabase.com](https://supabase.com)

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/AhmedGamalFarouk/hush.git
cd hush
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Supabase**

Create a Supabase project and note your **Project URL** and **Anon Key**.

4. **Set up environment variables**

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and add your Supabase credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

> **Important:** Never commit the `.env` file to version control.

5. **Set up the database**

You'll need to create the database schema in Supabase. See [Database Setup](#database-setup) below.

6. **Generate code** (if using Freezed/JSON serialization)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

7. **Run the app**

```bash
flutter run
```

Choose your target device (Android emulator, iOS simulator, web browser, etc.).

### Database Setup

The app requires specific database tables and Row Level Security (RLS) policies. You'll need to run SQL migrations in your Supabase project:

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Create and run the following tables (basic schema):

```sql
-- Users profiles with public keys
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  username TEXT UNIQUE NOT NULL,
  public_key_x25519 BYTEA NOT NULL,
  public_key_ed25519 BYTEA NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conversations
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('direct', 'group', 'anonymous')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conversation members
CREATE TABLE conversation_members (
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  encrypted_symmetric_key BYTEA NOT NULL,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (conversation_id, user_id)
);

-- Messages (all encrypted)
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(id),
  ciphertext BYTEA NOT NULL,
  nonce BYTEA NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Example RLS policy (add more as needed)
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);
```

4. **Enable Realtime** for the following tables:
   - `messages`
   - `conversation_members`
   - `typing_status` (if implemented)
   - `presence` (if implemented)

5. **Create storage bucket** (for encrypted media):
   - Name: `encrypted-media`
   - Public: No
   - Set appropriate RLS policies

> **Note:** A complete schema with all tables and policies will be provided in future releases.

## Usage Examples

### Starting the App

After installation, the app will:

1. Show a splash screen
2. Check authentication status
3. Route to login/register screen if not authenticated
4. Show the home screen (chat list) if authenticated

### Creating an Account

1. Tap **Register** on the auth screen
2. Enter email and password
3. The app generates cryptographic keypairs (X25519 + Ed25519)
4. Keys are stored securely using `flutter_secure_storage`

### Sending Encrypted Messages

```dart
// Example flow (simplified)
// 1. Derive shared secret with recipient using X25519 DH
// 2. Encrypt message with XChaCha20-Poly1305
// 3. Send ciphertext + nonce to Supabase
// 4. Recipient decrypts using shared secret
```

### Anonymous Session

1. User A creates a session → generates a random 32-byte key
2. User A shares key via QR code or manual entry
3. User B enters the key to join
4. Both derive the same encryption key using HKDF
5. Messages encrypted/decrypted with the derived key

## Architecture

Hush follows **Clean Architecture** principles with **Riverpod** for state management.

### Project Structure

```
lib/
├── main.dart                # App entry point
├── core/                    # Shared utilities, config, theme
│   ├── config/             # App configuration and constants
│   ├── errors/             # Error handling
│   ├── supabase/           # Supabase client provider
│   ├── theme/              # Light/dark theme definitions
│   └── utils/              # Helper functions
├── encryption/              # Cryptographic services
│   ├── services/           # Encryption, key derivation
│   └── providers/          # Riverpod providers for crypto
├── auth/                    # Authentication
│   ├── presentation/       # Login/register screens
│   └── services/           # Auth service (Supabase)
├── chat/                    # Messaging features
│   ├── models/             # Message, conversation models
│   ├── presentation/       # Chat UI screens
│   ├── providers/          # Chat state management
│   └── services/           # Message encryption/decryption
├── groups/                  # Group chat (in progress)
├── qr/                      # QR code generation/scanning
├── media/                   # Encrypted file handling
├── anonymous/               # Anonymous sessions
├── contacts/                # Contact management
├── settings/                # User settings
└── presentation/            # Shared UI components
    ├── home_screen.dart    # Main navigation screen
    ├── splash/             # Splash screen
    └── widgets/            # Reusable widgets
```

### Technology Stack

| Layer              | Technology                          |
|--------------------|-------------------------------------|
| **Frontend**       | Flutter 3.10+                       |
| **State Management** | Riverpod                          |
| **Backend**        | Supabase (PostgreSQL + Realtime)    |
| **Database**       | PostgreSQL with Row Level Security  |
| **Auth**           | Supabase Auth                       |
| **Storage**        | Supabase Storage                    |
| **Encryption**     | sodium (libsodium bindings)         |
| **QR Codes**       | qr_flutter, mobile_scanner          |
| **Secure Storage** | flutter_secure_storage              |

### Encryption Design

All encryption uses **libsodium** primitives:

| Operation              | Algorithm                      |
|------------------------|--------------------------------|
| **Message encryption** | XChaCha20-Poly1305 AEAD        |
| **Key exchange**       | X25519 (Curve25519 DH)         |
| **Signatures**         | Ed25519                        |
| **Key derivation**     | HKDF-SHA256                    |
| **Nonces**             | 24-byte random (crypto_secretbox) |

**Threat Model:**

✅ **Protects against:**
- Server compromise (no plaintext stored)
- Network eavesdropping (E2EE)
- Message tampering (authenticated encryption)
- Replay attacks (unique nonces)



## Where to Get Help

- **Issues:** [GitHub Issues](https://github.com/AhmedGamalFarouk/hush/issues)
- **Flutter Docs:** [docs.flutter.dev](https://docs.flutter.dev)
- **Supabase Docs:** [supabase.com/docs](https://supabase.com/docs)
- **libsodium Docs:** [doc.libsodium.org](https://doc.libsodium.org)

## Contributing

Contributions are welcome! This is an educational/demonstration project.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- Code follows Flutter/Dart style guidelines
- All tests pass (`flutter test`)
- New features include tests
- Crypto changes are well-documented with security assumptions



## Maintainers

- **Ahmed Gamal Farouk** - [@AhmedGamalFarouk](https://github.com/AhmedGamalFarouk)

## Acknowledgments

- [**libsodium**](https://libsodium.org) - Modern cryptography library by Frank Denis
- [**Supabase**](https://supabase.com) - Open-source Firebase alternative
- [**Flutter**](https://flutter.dev) - Google's UI toolkit for cross-platform apps
- [**Riverpod**](https://riverpod.dev) - Reactive state management by Remi Rousselet

---

**Built with security and privacy in mind.** 🔒
