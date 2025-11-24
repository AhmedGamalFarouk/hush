// ignore_for_file: deprecated_member_use
/// Secure Key Storage Service
/// Handles encrypted storage of user's private keys using password-derived encryption
///
/// SECURITY DESIGN:
/// 1. User's password is used to derive an encryption key via Argon2id (via libsodium)
/// 2. Private keys are encrypted with the derived key before storage
/// 3. flutter_secure_storage provides OS-level keychain/keystore protection
/// 4. Keys are never stored in plaintext
///
/// KEY DERIVATION:
/// - Uses crypto.pwhash with Argon2id13
/// - Salt is randomly generated per user and stored
/// - Ops/mem limits: interactive (for login performance)
///
/// STORAGE SCHEMA:
/// - key_salt: Random salt for password hashing (base64)
/// - enc_kx_secret: Encrypted X25519 secret key (base64)
/// - enc_sign_secret: Encrypted Ed25519 secret key (base64)
/// - kx_public: X25519 public key (base64, not encrypted)
/// - sign_public: Ed25519 public key (base64, not encrypted)
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sodium/sodium.dart' hide KeyPair;
import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';
import 'encryption_service.dart' show KeyPair;

/// Secure key storage service using password-derived encryption
class SecureKeyStorage {
  SecureKeyStorage({required Sodium sodium, FlutterSecureStorage? storage})
    : _sodium = sodium,
      _storage = storage ?? const FlutterSecureStorage();

  final Sodium _sodium;
  final FlutterSecureStorage _storage;

  // Storage keys
  static const _keySalt = 'key_salt';
  static const _encKxSecret = 'enc_kx_secret';
  static const _encSignSecret = 'enc_sign_secret';
  static const _kxPublic = 'kx_public';
  static const _signPublic = 'sign_public';

  // ===========================================================================
  // STORE KEYS (First time setup or key generation)
  // ===========================================================================

  /// Store user's key pairs encrypted with password
  ///
  /// This should be called after signup or when generating new keys.
  /// The password should be the user's actual login password.
  ///
  /// Security: Uses Argon2id to derive encryption key from password
  Future<Result<void, AppError>> storeKeyPairs({
    required String password,
    required KeyPair kxKeyPair,
    required KeyPair signKeyPair,
  }) async {
    try {
      // 1. Generate random salt for this user
      final salt = _sodium.randombytes.buf(_sodium.crypto.pwhash.saltBytes);

      // 2. Derive encryption key from password using Argon2id
      final encryptionKey = _sodium.crypto.pwhash(
        outLen: 32,
        password: Int8List.fromList(utf8.encode(password)),
        salt: Uint8List.fromList(salt),
        opsLimit: _sodium.crypto.pwhash.opsLimitInteractive,
        memLimit: _sodium.crypto.pwhash.memLimitInteractive,
      );

      // 3. Encrypt both secret keys
      final encKxSecret = await _encryptKey(
        kxKeyPair.secretKey,
        Uint8List.fromList(encryptionKey.extractBytes()),
      );
      final encSignSecret = await _encryptKey(
        signKeyPair.secretKey,
        Uint8List.fromList(encryptionKey.extractBytes()),
      );

      // 4. Store everything
      await Future.wait([
        _storage.write(key: _keySalt, value: base64Url.encode(salt)),
        _storage.write(key: _encKxSecret, value: encKxSecret),
        _storage.write(key: _encSignSecret, value: encSignSecret),
        _storage.write(
          key: _kxPublic,
          value: base64Url.encode(kxKeyPair.publicKey),
        ),
        _storage.write(
          key: _signPublic,
          value: base64Url.encode(signKeyPair.publicKey),
        ),
      ]);

      encryptionKey.dispose();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Failed to store keys: $e'),
      );
    }
  }

  // ===========================================================================
  // RETRIEVE KEYS (On login)
  // ===========================================================================

  /// Retrieve and decrypt user's key pairs using password
  ///
  /// This should be called on login to unlock the user's keys.
  /// Returns both key pairs if password is correct, error otherwise.
  Future<Result<StoredKeyPairs, AppError>> retrieveKeyPairs({
    required String password,
  }) async {
    try {
      // 1. Load salt and encrypted keys
      final salt = await _storage.read(key: _keySalt);
      final encKxSecret = await _storage.read(key: _encKxSecret);
      final encSignSecret = await _storage.read(key: _encSignSecret);
      final kxPublic = await _storage.read(key: _kxPublic);
      final signPublic = await _storage.read(key: _signPublic);

      if (salt == null ||
          encKxSecret == null ||
          encSignSecret == null ||
          kxPublic == null ||
          signPublic == null) {
        return Result.failure(
          AppError.encryption(message: 'Keys not found in storage'),
        );
      }

      // 2. Derive decryption key from password
      final decryptionKey = _sodium.crypto.pwhash(
        outLen: 32,
        password: Int8List.fromList(utf8.encode(password)),
        salt: base64Url.decode(salt),
        opsLimit: _sodium.crypto.pwhash.opsLimitInteractive,
        memLimit: _sodium.crypto.pwhash.memLimitInteractive,
      );

      // 3. Decrypt secret keys
      final kxSecretResult = await _decryptKey(
        encKxSecret,
        Uint8List.fromList(decryptionKey.extractBytes()),
      );
      if (kxSecretResult.isFailure) {
        decryptionKey.dispose();
        return Result.failure(
          AppError.authentication(
            message: 'Invalid password or corrupted keys',
          ),
        );
      }

      final signSecretResult = await _decryptKey(
        encSignSecret,
        Uint8List.fromList(decryptionKey.extractBytes()),
      );
      if (signSecretResult.isFailure) {
        decryptionKey.dispose();
        return Result.failure(
          AppError.authentication(
            message: 'Invalid password or corrupted keys',
          ),
        );
      }

      decryptionKey.dispose();

      // 4. Return key pairs
      return Result.success(
        StoredKeyPairs(
          kxKeyPair: KeyPair(
            publicKey: base64Url.decode(kxPublic),
            secretKey: kxSecretResult.valueOrNull!,
          ),
          signKeyPair: KeyPair(
            publicKey: base64Url.decode(signPublic),
            secretKey: signSecretResult.valueOrNull!,
          ),
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Failed to retrieve keys: $e'),
      );
    }
  }

  // ===========================================================================
  // PUBLIC KEY RETRIEVAL (No password needed)
  // ===========================================================================

  /// Get user's public keys without needing password
  Future<Result<PublicKeys, AppError>> getPublicKeys() async {
    try {
      final kxPublic = await _storage.read(key: _kxPublic);
      final signPublic = await _storage.read(key: _signPublic);

      if (kxPublic == null || signPublic == null) {
        return Result.failure(
          AppError.encryption(message: 'Public keys not found'),
        );
      }

      return Result.success(
        PublicKeys(
          kxPublicKey: base64Url.decode(kxPublic),
          signPublicKey: base64Url.decode(signPublic),
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Failed to retrieve public keys: $e'),
      );
    }
  }

  // ===========================================================================
  // KEY EXISTENCE CHECK
  // ===========================================================================

  /// Check if user has keys stored
  Future<bool> hasStoredKeys() async {
    try {
      final salt = await _storage.read(key: _keySalt);
      return salt != null;
    } catch (e) {
      return false;
    }
  }

  // ===========================================================================
  // PASSWORD UPDATE
  // ===========================================================================

  /// Re-encrypt keys with new password
  ///
  /// Used when user changes their password.
  /// Requires old password to decrypt, then re-encrypts with new password.
  Future<Result<void, AppError>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // 1. Retrieve keys with old password
      final keysResult = await retrieveKeyPairs(password: oldPassword);
      if (keysResult.isFailure) {
        return Result.failure(keysResult.errorOrNull!);
      }

      final keys = keysResult.valueOrNull!;

      // 2. Re-encrypt with new password
      return await storeKeyPairs(
        password: newPassword,
        kxKeyPair: keys.kxKeyPair,
        signKeyPair: keys.signKeyPair,
      );
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Failed to update password: $e'),
      );
    }
  }

  // ===========================================================================
  // CLEAR KEYS (Logout or account deletion)
  // ===========================================================================

  /// Delete all stored keys
  Future<void> clearKeys() async {
    await Future.wait([
      _storage.delete(key: _keySalt),
      _storage.delete(key: _encKxSecret),
      _storage.delete(key: _encSignSecret),
      _storage.delete(key: _kxPublic),
      _storage.delete(key: _signPublic),
    ]);
  }

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

  /// Encrypt a key using secretbox (symmetric encryption)
  Future<String> _encryptKey(Uint8List key, Uint8List encryptionKey) async {
    final nonce = _sodium.randombytes.buf(_sodium.crypto.secretBox.nonceBytes);

    final ciphertext = _sodium.crypto.secretBox.easy(
      message: key,
      nonce: Uint8List.fromList(nonce),
      key: SecureKey.fromList(_sodium, encryptionKey),
    );

    // Combine nonce + ciphertext and encode
    final combined = Uint8List.fromList([...nonce, ...ciphertext]);
    return base64Url.encode(combined);
  }

  /// Decrypt a key
  Future<Result<Uint8List, AppError>> _decryptKey(
    String encryptedKey,
    Uint8List decryptionKey,
  ) async {
    try {
      final combined = base64Url.decode(encryptedKey);

      // Split nonce and ciphertext
      final nonceSize = _sodium.crypto.secretBox.nonceBytes;
      final nonce = Uint8List.fromList(combined.sublist(0, nonceSize));
      final ciphertext = Uint8List.fromList(combined.sublist(nonceSize));

      final plaintext = _sodium.crypto.secretBox.openEasy(
        cipherText: ciphertext,
        nonce: nonce,
        key: SecureKey.fromList(_sodium, decryptionKey),
      );

      return Result.success(Uint8List.fromList(plaintext));
    } catch (e) {
      return Result.failure(
        AppError.decryption(message: 'Key decryption failed'),
      );
    }
  }
}

/// Container for stored key pairs
class StoredKeyPairs {
  final KeyPair kxKeyPair;
  final KeyPair signKeyPair;

  const StoredKeyPairs({required this.kxKeyPair, required this.signKeyPair});
}

/// Container for public keys only
class PublicKeys {
  final Uint8List kxPublicKey;
  final Uint8List signPublicKey;

  const PublicKeys({required this.kxPublicKey, required this.signPublicKey});
}
