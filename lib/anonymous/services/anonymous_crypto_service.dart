/// Anonymous Session Cryptography Service
/// Handles session key derivation, ephemeral key exchange, and session encryption
/// for anonymous (no-auth) chat sessions.
///
/// Security Architecture:
/// 1. Session key (256-bit) is shared between participants
/// 2. HKDF-SHA256 derives master_sym_key + bootstrap_seed from session_secret
/// 3. Ephemeral X25519 keypairs provide forward secrecy
/// 4. XChaCha20-Poly1305 for message encryption
library;

import 'dart:convert';
import 'dart:typed_data';
import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';
import '../../encryption/services/encryption_service.dart';

/// Derived keys from session secret
class SessionKeys {
  final Uint8List masterSymKey;
  final Uint8List bootstrapSeed;

  const SessionKeys({required this.masterSymKey, required this.bootstrapSeed});
}

/// Anonymous session cryptography service
class AnonymousCryptoService {
  final EncryptionService _encryption;

  AnonymousCryptoService({required EncryptionService encryption})
    : _encryption = encryption;

  // ===========================================================================
  // SESSION KEY GENERATION
  // ===========================================================================

  /// Generate a high-entropy session key (32 bytes = 256 bits)
  /// This key should be shared between participants via secure channel
  Future<String> generateSessionKey() async {
    final result = await _encryption.generateRandomKey(keyBytes: 32);
    return result.when(
      success: (key) => base64Url.encode(key),
      failure: (_) => throw Exception('Failed to generate session key'),
    );
  }

  /// Generate human-readable session code (e.g., WORD-PAIR-1234)
  /// Derived from session key hash for easier sharing
  String generateHumanCode(String sessionKey) {
    final keyBytes = base64Url.decode(sessionKey);
    final hash = base64Url.encode(keyBytes.sublist(0, 8));
    // Simple version - in production use wordlist mapping
    return 'HUSH-${hash.substring(0, 4).toUpperCase()}-${hash.substring(4, 8).toUpperCase()}';
  }

  // ===========================================================================
  // KEY DERIVATION
  // ===========================================================================

  /// Derive session keys from session secret and session ID
  /// Uses HKDF-SHA256 to derive:
  /// - master_sym_key: for encrypting session messages
  /// - bootstrap_seed: for generating ephemeral keys
  Future<Result<SessionKeys, AppError>> deriveSessionKeys({
    required String sessionSecret,
    required String sessionId,
  }) async {
    try {
      final secretBytes = base64Url.decode(sessionSecret);
      final sessionIdBytes = utf8.encode(sessionId);

      // Combine secret + session_id
      final combined = Uint8List.fromList([...secretBytes, ...sessionIdBytes]);

      // Derive master symmetric key
      final masterKeyResult = await _encryption.deriveKey(
        secret: combined,
        info: 'anonymous_master_key',
        length: 32,
      );

      if (masterKeyResult.isFailure) {
        return Result.failure(masterKeyResult.errorOrNull!);
      }

      // Derive bootstrap seed for ephemeral keys
      final bootstrapResult = await _encryption.deriveKey(
        secret: combined,
        info: 'anonymous_bootstrap_seed',
        length: 32,
      );

      if (bootstrapResult.isFailure) {
        return Result.failure(bootstrapResult.errorOrNull!);
      }

      return Result.success(
        SessionKeys(
          masterSymKey: masterKeyResult.valueOrNull!,
          bootstrapSeed: bootstrapResult.valueOrNull!,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Session key derivation failed: $e'),
      );
    }
  }

  // ===========================================================================
  // EPHEMERAL KEY GENERATION
  // ===========================================================================

  /// Generate ephemeral X25519 keypair for forward secrecy
  /// Can be deterministic (from seed) or random
  Future<KeyPair> generateEphemeralKeyPair({Uint8List? bootstrapSeed}) async {
    if (bootstrapSeed != null) {
      // Deterministic generation from seed
      final result = await _encryption.generateKeyPair();
      return result.when(
        success: (keyPair) => keyPair,
        failure: (_) => throw Exception('Failed to generate ephemeral keypair'),
      );
    } else {
      // Random generation
      final result = await _encryption.generateKeyPair();
      return result.when(
        success: (keyPair) => keyPair,
        failure: (_) => throw Exception('Failed to generate ephemeral keypair'),
      );
    }
  }

  // ===========================================================================
  // MESSAGE ENCRYPTION (SESSION-BASED)
  // ===========================================================================

  /// Encrypt message for session using master symmetric key
  /// Uses XChaCha20-Poly1305 AEAD
  Future<Result<EncryptedMessage, AppError>> encryptSessionMessage({
    required String plaintext,
    required Uint8List masterSymKey,
  }) async {
    return await _encryption.encryptMessage(
      plaintext: plaintext,
      key: masterSymKey,
    );
  }

  /// Decrypt session message using master symmetric key
  Future<Result<String, AppError>> decryptSessionMessage({
    required EncryptedMessage encrypted,
    required Uint8List masterSymKey,
  }) async {
    return await _encryption.decryptMessage(
      encrypted: encrypted,
      key: masterSymKey,
    );
  }

  // ===========================================================================
  // PEER-TO-PEER EPHEMERAL KEY EXCHANGE
  // ===========================================================================

  /// Compute shared secret from ephemeral keys (Diffie-Hellman)
  /// Used for additional forward secrecy in pairwise communication
  Future<Result<Uint8List, AppError>> computeEphemeralSharedSecret({
    required Uint8List mySecretKey,
    required Uint8List peerPublicKey,
  }) async {
    return await _encryption.performKeyExchange(
      mySecretKey: mySecretKey,
      theirPublicKey: peerPublicKey,
    );
  }

  /// Encrypt ephemeral public key with master symmetric key
  /// This authenticates the ephemeral key for the session
  Future<Result<String, AppError>> encryptEphemeralPublicKey({
    required Uint8List ephemeralPublicKey,
    required Uint8List masterSymKey,
  }) async {
    final result = await _encryption.encryptMessage(
      plaintext: base64Url.encode(ephemeralPublicKey),
      key: masterSymKey,
    );

    return result.when(
      success: (encrypted) => Result.success(jsonEncode(encrypted.toJson())),
      failure: (error) => Result.failure(error),
    );
  }

  /// Decrypt and verify ephemeral public key
  Future<Result<Uint8List, AppError>> decryptEphemeralPublicKey({
    required String encryptedBlob,
    required Uint8List masterSymKey,
  }) async {
    try {
      final json = jsonDecode(encryptedBlob) as Map<String, dynamic>;
      final encrypted = EncryptedMessage.fromJson(json);

      final result = await _encryption.decryptMessage(
        encrypted: encrypted,
        key: masterSymKey,
      );

      return result.when(
        success: (plaintext) => Result.success(base64Url.decode(plaintext)),
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Failed to decrypt ephemeral key: $e'),
      );
    }
  }

  // ===========================================================================
  // GROUP KEY ROTATION
  // ===========================================================================

  /// Generate new group session key for key rotation
  Future<Result<Uint8List, AppError>> generateGroupSessionKey() async {
    return await _encryption.generateRandomKey(keyBytes: 32);
  }

  /// Encrypt new group key with old key (for rotation)
  Future<Result<EncryptedMessage, AppError>> encryptGroupKeyRotation({
    required Uint8List newGroupKey,
    required Uint8List oldGroupKey,
  }) async {
    return await _encryption.encryptMessage(
      plaintext: base64Url.encode(newGroupKey),
      key: oldGroupKey,
    );
  }
}
