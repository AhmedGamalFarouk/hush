# Hush - End-to-End Encrypted Chat Application

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase" alt="Supabase">
  <img src="https://img.shields.io/badge/Encryption-libsodium-FF6B6B" alt="Encryption">
  <img src="https://img.shields.io/badge/State-Riverpod-00D9FF" alt="Riverpod">
</p>

A production-ready Flutter chat application with **complete end-to-end encryption (E2EE)**, powered by Supabase and libsodium cryptography.

## ✨ Features

### 🔐 Security First
- **End-to-End Encryption** using XChaCha20-Poly1305 AEAD
- **Forward Secrecy** via ephemeral X25519 key exchange
- **Digital Signatures** with Ed25519
- **Secure Key Derivation** using HKDF-SHA256
- **No plaintext on server** - only encrypted ciphertext stored

### 💬 Core Features
- ✅ Email/password authentication
- ✅ One-to-one encrypted chats
- 🚧 Group chats with secure key distribution
- 🚧 QR-based quick contact add
- 🚧 Encrypted media/file sharing
- 🚧 Real-time typing indicators & presence
- 🚧 Read receipts

### 🎭 Anonymous Sessions (Unique Feature)
- **No-account chat sessions** - users share a secret key
- Ephemeral identities with forward secrecy
- Session expiry and participant limits
- Rate-limited joins to prevent brute-force
- Convert to authenticated accounts (planned)

### 🎨 Modern UI
- **Gradient-free design** - clean, flat surfaces
- Light and dark themes
- Smooth micro-interactions
- 8dp grid spacing system
- Clear typography hierarchy

## 🏗️ Architecture

### Clean Architecture + Riverpod
```
lib/
├── core/           # Configuration, theme, errors, utilities
├── encryption/     # Cryptographic services (libsodium)
├── anonymous/      # Anonymous session feature
├── auth/           # Authentication (Supabase)
├── chat/           # Messaging features
├── groups/         # Group chat management
├── qr/             # QR code generation/scanning
├── media/          # Encrypted file handling
└── presentation/   # UI screens
```

### Technology Stack
- **Frontend:** Flutter 3.10+ (cross-platform)
- **Backend:** Supabase (PostgreSQL + Realtime + Storage + Auth)
- **State Management:** Riverpod
- **Encryption:** sodium (libsodium Dart bindings)
- **Database:** PostgreSQL with Row Level Security (RLS)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10 or higher
- Dart SDK 3.10 or higher
- A Supabase account (free tier available)

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd hush
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Set up Supabase**
   - Create a project at [supabase.com](https://supabase.com)
   - Run the SQL migration: `supabase/migrations/001_initial_schema.sql`
   - Enable Realtime for: `messages`, `typing_status`, `presence`, `conversation_members`
   - Create storage bucket: `encrypted-media`

4. **Configure environment**
   - Copy `.env.example` to `.env`
   - Add your Supabase credentials:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

5. **Generate code** (for Freezed/JSON serialization)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

6. **Run the app**
```bash
flutter run
```

## 🔒 Security Architecture

### Encryption Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    ENCRYPTION LAYER                          │
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │   AEAD       │    │  Key Deriv.  │    │  DH Exchange │ │
│  │ XChaCha20-   │    │ HKDF-SHA256  │    │   X25519     │ │
│  │  Poly1305    │    │              │    │              │ │
│  └──────────────┘    └──────────────┘    └──────────────┘ │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  All encryption uses libsodium (NaCl crypto library) │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Anonymous Session Crypto Design

1. **Session Creation:**
   ```
   session_secret (32 bytes random) + session_id (UUID)
   ↓ HKDF-SHA256
   master_sym_key + bootstrap_seed
   ```

2. **Ephemeral Keys (Forward Secrecy):**
   ```
   Each participant generates X25519 keypair
   Public key encrypted with master_sym_key
   DH exchange with peers → unique session keys
   ```

3. **Message Encryption:**
   ```
   Plaintext → XChaCha20-Poly1305(key, nonce) → Ciphertext
   ✓ Authenticated encryption (MAC verification)
   ✓ Unique nonce per message (24 bytes random)
   ```

### Threat Model

**✓ PROTECTS AGAINST:**
- Server compromise (no plaintext stored)
- Network eavesdropping (E2EE)
- Message tampering (authenticated encryption)
- Replay attacks (unique nonces)

**✗ DOES NOT PROTECT:**
- Device compromise / malware
- Traffic analysis / metadata
- Screenshots / screen recording
- Weak passwords / brute-force on weak keys

## 📁 Project Status

### ✅ Completed
- [x] Project structure and clean architecture
- [x] Complete database schema with RLS
- [x] Encryption service (libsodium integration)
- [x] Anonymous session architecture
- [x] Theme system (gradient-free design)
- [x] Authentication flow (UI + service)
- [x] Splash screen
- [x] Chat list screen (skeleton)
- [x] Configuration and error handling

### 🚧 In Progress / To Be Implemented
- [ ] Chat screen (messages UI)
- [ ] Message encryption/decryption flow
- [ ] Real-time message updates
- [ ] Group chat implementation
- [ ] QR code generation/scanning
- [ ] Media encryption and storage
- [ ] Typing indicators
- [ ] Presence system
- [ ] Read receipts
- [ ] Anonymous session UI
- [ ] Contact management
- [ ] Settings screen
- [ ] Unit tests
- [ ] Integration tests

## 📚 Documentation

- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Complete implementation guide with:
  - Detailed architecture documentation
  - API references for all services
  - Security documentation and threat model
  - Setup instructions
  - Testing guidelines
  - Operational recommendations

- **[development plan.md](development%20plan.md)** - Original specification

- **Database Schema:** `supabase/migrations/001_initial_schema.sql`

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## 🔧 Development

### Code Generation
```bash
# Watch mode (auto-rebuild on changes)
flutter pub run build_runner watch

# One-time build
flutter pub run build_runner build --delete-conflicting-outputs
```

### Format Code
```bash
flutter format lib/
```

### Analyze
```bash
flutter analyze
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🤝 Contributing

This is a demonstration/educational project. Contributions welcome!

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## ⚠️ Important Security Notes

1. **Supabase RLS:** Ensure all Row Level Security policies are active
2. **Environment Variables:** Never commit `.env` to version control
3. **Key Management:** Implement secure key storage for production
4. **Rate Limiting:** Anonymous session joins are rate-limited server-side
5. **Session Keys:** Recommend 32+ byte random keys for anonymous sessions
6. **Audit:** Complete security audit required before production deployment

## 📄 License

[Your chosen license]

## 🙏 Acknowledgments

- **libsodium** - Modern cryptography library
- **Supabase** - Open-source Firebase alternative
- **Flutter** - Cross-platform UI framework
- **Riverpod** - Reactive state management

---

**Built with security and privacy in mind. 🔒**

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
