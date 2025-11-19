# Hush - Setup and Running Guide

## Quick Start

This guide will help you set up and run the Hush encrypted chat application.

## Prerequisites

- Flutter SDK (3.10.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- A code editor (VS Code, Android Studio, or IntelliJ)
- A Supabase account - [Sign up at supabase.com](https://supabase.com)
- Android Studio (for Android) or Xcode (for iOS)

## Step 1: Clone and Setup Project

```bash
# Navigate to the project directory
cd hush

# Install Flutter dependencies
flutter pub get

# Generate code for Freezed models
flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 2: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait for the project to be provisioned (2-3 minutes)
3. Note down your project credentials:
   - Project URL (looks like: `https://xxxxx.supabase.co`)
   - Anon/Public Key (starts with `eyJ...`)

## Step 3: Setup Database

1. Go to your Supabase project dashboard
2. Click on **SQL Editor** in the left sidebar
3. Follow the instructions in `DATABASE_SETUP.md` to create all tables
4. Execute each SQL block in order

**Important:** Make sure to:
- Create all tables (profiles, conversations, messages, etc.)
- Enable Row Level Security (RLS) on all tables
- Set up the storage bucket for encrypted media

## Step 4: Configure Environment

Create a `.env` file in the project root:

```bash
# Copy the example file
cp .env.example .env
```

Edit `.env` and add your Supabase credentials:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Note:** The `.env` file is gitignored and contains sensitive credentials. Never commit it to version control.

## Step 5: Run the App

### On Android

```bash
# List available devices
flutter devices

# Run on connected Android device/emulator
flutter run
```

### On iOS (macOS only)

```bash
# Install CocoaPods dependencies
cd ios
pod install
cd ..

# Run on iOS simulator or device
flutter run
```

### On Web

```bash
flutter run -d chrome
```

## Step 6: Test the Application

### Create an Account

1. Launch the app
2. Tap "Register" on the login screen
3. Enter:
   - Email address
   - Username (unique)
   - Password (min 6 characters)
4. Tap "Register"

### Start a Conversation

1. After logging in, you'll see the chat list (empty initially)
2. Tap the **+** button (floating action button)
3. Select "Add Contact"
4. Search for another user by username
5. Tap the chat icon to start a conversation
6. Send encrypted messages!

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core utilities
│   ├── config/              # App configuration
│   ├── theme/               # UI theme (gradient-free)
│   ├── errors/              # Error handling
│   └── supabase/            # Supabase client
├── encryption/              # Encryption services
│   └── services/           # Libsodium crypto operations
├── auth/                    # Authentication
│   ├── presentation/       # Login/Register screens
│   └── services/           # Auth service
├── chat/                    # Chat features
│   ├── models/             # Message, Conversation, Profile
│   ├── services/           # Message & conversation services
│   └── presentation/       # Chat screens
├── contacts/                # Contact management
│   └── presentation/       # Search contacts screen
├── anonymous/               # Anonymous sessions (coming soon)
├── groups/                  # Group chats (coming soon)
└── presentation/            # Shared UI components
```

## Features Implemented

✅ **Core Features**
- Email/password authentication
- End-to-end encrypted messaging
- Real-time message delivery
- Contact search and discovery
- Conversation management
- Modern flat UI design

🚧 **In Progress**
- QR code contact sharing
- Anonymous sessions
- Group chats
- Media encryption
- Typing indicators

## Development Commands

```bash
# Run the app in debug mode
flutter run

# Build for production
flutter build apk          # Android APK
flutter build appbundle    # Android App Bundle
flutter build ios          # iOS (requires macOS)

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Clean build artifacts
flutter clean

# Regenerate model code
flutter pub run build_runner build --delete-conflicting-outputs
```

## Troubleshooting

### "Target of URI doesn't exist" errors

Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Supabase connection issues

1. Check your `.env` file has correct credentials
2. Verify the Supabase URL and key in your dashboard
3. Make sure you're connected to the internet
4. Check if database tables are created

### Build errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Android signing issues

For debug builds, Flutter handles signing automatically. For release builds, see [Flutter's Android deployment guide](https://flutter.dev/docs/deployment/android).

## Security Notes

### Encryption

- All messages are encrypted with **XChaCha20-Poly1305** (AEAD cipher)
- Key exchange uses **X25519** (Diffie-Hellman)
- Digital signatures use **Ed25519**
- Supabase stores **only ciphertext**, never plaintext

### Key Storage

**Current Implementation (Demo):**
- Keys are stored in simplified format for demonstration
- NOT suitable for production without enhancement

**Production Requirements:**
- Encrypt user keys with device-specific encryption
- Use platform secure storage (Keychain on iOS, Keystore on Android)
- Implement key backup and recovery mechanism
- Consider using `flutter_secure_storage` package

### Rate Limiting

Anonymous session joins should be rate-limited in production:
- Implement in Supabase Edge Functions
- Or use Postgres row-level security with custom functions

## Next Steps

1. **Test messaging**: Register 2 accounts and send messages
2. **Explore the code**: Check `lib/encryption/services/encryption_service.dart`
3. **Add features**: Implement QR codes, groups, or anonymous sessions
4. **Deploy**: Build release versions for Android/iOS
5. **Contribute**: See `FEATURE_CHECKLIST.md` for remaining features

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Libsodium Documentation](https://libsodium.gitbook.io/)
- [Development Plan](development%20plan.md) - Full specification
- [Database Setup](DATABASE_SETUP.md) - SQL schema
- [Feature Checklist](FEATURE_CHECKLIST.md) - Track progress

## Getting Help

- Check existing issues in the repository
- Review the development plan for architecture details
- Consult the inline code documentation
- Test encryption with the provided service

## License

See LICENSE file for details.

---

**Happy coding!** 🚀🔒
