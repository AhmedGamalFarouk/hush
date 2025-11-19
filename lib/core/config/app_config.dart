/// Core configuration for the Hush application
/// Manages environment variables and app constants
library;

class AppConfig {
  static const String appName = 'Hush';
  static const String appVersion = '1.0.0';

  // Supabase
  static late String supabaseUrl;
  static late String supabaseAnonKey;

  // Encryption
  static const int sessionKeyBytes = 32; // 256 bits
  static const int nonceBytes = 24; // XChaCha20 nonce
  static const int macBytes = 16; // Poly1305 MAC

  // Anonymous Sessions
  static const Duration defaultSessionExpiry = Duration(hours: 24);
  static const int defaultMaxParticipants = 10;
  static const int minSessionKeyLength = 32; // bytes
  static const int maxSessionKeyLength = 64; // bytes

  // Rate Limiting (for brute-force protection)
  static const int maxJoinAttemptsPerMinute = 5;
  static const Duration joinAttemptWindow = Duration(minutes: 1);

  // Message limits
  static const int maxMessageLength = 10000; // characters
  static const int maxFileSize = 100 * 1024 * 1024; // 100 MB

  // UI
  static const Duration typingIndicatorTimeout = Duration(seconds: 3);
  static const Duration messageAnimationDuration = Duration(milliseconds: 200);

  static void initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) {
    AppConfig.supabaseUrl = supabaseUrl;
    AppConfig.supabaseAnonKey = supabaseAnonKey;
  }
}
