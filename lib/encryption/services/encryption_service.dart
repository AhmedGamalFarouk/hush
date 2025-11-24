/// Simplified Encryption Service
/// Uses sodium/sodium_libs for cryptographic operations
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:sodium/sodium.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';

/// Encrypted message structure
class EncryptedMessage {
  const EncryptedMessage({
    required this.ciphertext,
    required this.nonce,
    this.senderBlob,
  });

  factory EncryptedMessage.fromJson(Map<String, dynamic> json) =>
      EncryptedMessage(
        ciphertext: base64Url.decode(json['ciphertext'] as String),
        nonce: base64Url.decode(json['nonce'] as String),
        senderBlob: json['sender_blob'] as String?,
      );

  final Uint8List ciphertext;
  final Uint8List nonce;
  final String? senderBlob;

  Map<String, dynamic> toJson() => {
    'ciphertext': base64Url.encode(ciphertext),
    'nonce': base64Url.encode(nonce),
    if (senderBlob != null) 'sender_blob': senderBlob,
  };
}

/// Key pair for asymmetric encryption
class KeyPair {
  const KeyPair({required this.publicKey, required this.secretKey});

  final Uint8List publicKey;
  final Uint8List secretKey;

  String get publicKeyBase64 => base64Url.encode(publicKey);

  String get secretKeyBase64 => base64Url.encode(secretKey);
}

/// Simplified encryption service
class EncryptionService {
  EncryptionService({required Sodium sodium}) : _sodium = sodium;

  static const _uuid = Uuid();

  final Sodium _sodium;

  // ===========================================================================
  // KEY GENERATION
  // ===========================================================================

  Future<Result<Uint8List, AppError>> generateRandomKey({
    int keyBytes = 32,
  }) async {
    try {
      final key = _sodium.randombytes.buf(keyBytes);
      return Result.success(Uint8List.fromList(key));
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Failed to generate key: $e'),
      );
    }
  }

  Future<Result<KeyPair, AppError>> generateKeyPair() async {
    try {
      final keyPair = _sodium.crypto.box.keyPair();
      return Result.success(
        KeyPair(
          publicKey: Uint8List.fromList(keyPair.publicKey),
          secretKey: Uint8List.fromList(keyPair.secretKey.extractBytes()),
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Failed to generate keypair: $e'),
      );
    }
  }

  Future<Result<KeyPair, AppError>> generateSigningKeyPair() async {
    try {
      final keyPair = _sodium.crypto.sign.keyPair();
      return Result.success(
        KeyPair(
          publicKey: Uint8List.fromList(keyPair.publicKey),
          secretKey: Uint8List.fromList(keyPair.secretKey.extractBytes()),
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Failed to generate signing keypair: $e'),
      );
    }
  }

  // ===========================================================================
  // KEY DERIVATION
  // ===========================================================================

  Future<Result<Uint8List, AppError>> deriveKey({
    required Uint8List secret,
    Uint8List? salt,
    required String info,
    int length = 32,
  }) async {
    try {
      final combined = Uint8List.fromList([
        ...secret,
        if (salt != null) ...salt,
        ...utf8.encode(info),
      ]);

      final derived = _sodium.crypto.genericHash(
        message: combined,
        outLen: length,
      );

      return Result.success(Uint8List.fromList(derived));
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Key derivation failed: $e'),
      );
    }
  }

  Future<Result<List<Uint8List>, AppError>> deriveMultipleKeys({
    required Uint8List secret,
    required List<String> contexts,
    int keyLength = 32,
  }) async {
    try {
      final keys = <Uint8List>[];
      for (final context in contexts) {
        final result = await deriveKey(
          secret: secret,
          info: context,
          length: keyLength,
        );
        if (result.isFailure) {
          return Result.failure(result.errorOrNull!);
        }
        keys.add(result.valueOrNull!);
      }
      return Result.success(keys);
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Multiple key derivation failed: $e'),
      );
    }
  }

  // ===========================================================================
  // DIFFIE-HELLMAN KEY EXCHANGE
  // ===========================================================================

  /// Perform X25519 Diffie-Hellman key exchange
  ///
  /// Computes shared secret using X25519 key exchange.
  /// The shared secret can be used directly as an encryption key.
  ///
  /// Note: This uses crypto.box.easy internally which performs X25519 DH.
  /// For a pure shared secret, we derive from an ephemeral encryption.
  Future<Result<Uint8List, AppError>> performKeyExchange({
    required Uint8List mySecretKey,
    required Uint8List theirPublicKey,
  }) async {
    try {
      // Create a deterministic "context" message for key derivation
      final context = Uint8List.fromList(utf8.encode('hush_kx_v1'));
      final nonce = Uint8List(24); // Zero nonce for deterministic result

      // Use box to create shared secret (involves X25519 DH)
      final encrypted = _sodium.crypto.box.easy(
        message: context,
        nonce: nonce,
        publicKey: theirPublicKey,
        secretKey: SecureKey.fromList(_sodium, mySecretKey),
      );

      // Hash the result to get clean 32-byte key
      final sharedSecret = _sodium.crypto.genericHash(
        message: Uint8List.fromList(encrypted),
        outLen: 32,
      );

      return Result.success(Uint8List.fromList(sharedSecret));
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Key exchange failed: $e'),
      );
    }
  }

  // ===========================================================================
  // ASYMMETRIC ENCRYPTION (Box / Sealed Box)
  // ===========================================================================

  /// Encrypt data for a recipient using their public key (sealed box)
  ///
  /// This uses crypto.box.seal which provides anonymous encryption:
  /// - Recipient can decrypt with their secret key
  /// - No sender authentication (anonymous)
  /// - Perfect for encrypting conversation keys for group members
  ///
  /// Use case: Encrypt a conversation key for a new group member
  Future<Result<Uint8List, AppError>> sealBox({
    required Uint8List plaintext,
    required Uint8List recipientPublicKey,
  }) async {
    try {
      final ciphertext = _sodium.crypto.box.seal(
        message: plaintext,
        publicKey: recipientPublicKey,
      );
      return Result.success(Uint8List.fromList(ciphertext));
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Sealed box encryption failed: $e'),
      );
    }
  }

  /// Decrypt data encrypted with sealed box using my secret key
  ///
  /// Requires both public and secret key to decrypt sealed box.
  Future<Result<Uint8List, AppError>> openSealedBox({
    required Uint8List ciphertext,
    required Uint8List myPublicKey,
    required Uint8List mySecretKey,
  }) async {
    try {
      final plaintext = _sodium.crypto.box.sealOpen(
        cipherText: ciphertext,
        publicKey: myPublicKey,
        secretKey: SecureKey.fromList(_sodium, mySecretKey),
      );
      return Result.success(Uint8List.fromList(plaintext));
    } catch (e) {
      return Result.failure(
        AppError.decryption(message: 'Sealed box decryption failed: $e'),
      );
    }
  }

  /// Authenticated encryption from sender to recipient
  ///
  /// Unlike sealed box, this includes sender authentication.
  /// Recipient knows the message came from the claimed sender.
  ///
  /// Use case: Sending encrypted messages in a conversation
  Future<Result<EncryptedMessage, AppError>> encryptBox({
    required Uint8List plaintext,
    required Uint8List mySecretKey,
    required Uint8List theirPublicKey,
  }) async {
    try {
      final nonce = _sodium.randombytes.buf(_sodium.crypto.box.nonceBytes);

      final ciphertext = _sodium.crypto.box.easy(
        message: plaintext,
        nonce: Uint8List.fromList(nonce),
        publicKey: theirPublicKey,
        secretKey: SecureKey.fromList(_sodium, mySecretKey),
      );

      return Result.success(
        EncryptedMessage(
          ciphertext: Uint8List.fromList(ciphertext),
          nonce: Uint8List.fromList(nonce),
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Box encryption failed: $e'),
      );
    }
  }

  /// Decrypt authenticated box message
  Future<Result<Uint8List, AppError>> decryptBox({
    required EncryptedMessage encrypted,
    required Uint8List mySecretKey,
    required Uint8List theirPublicKey,
  }) async {
    try {
      final plaintext = _sodium.crypto.box.openEasy(
        cipherText: encrypted.ciphertext,
        nonce: encrypted.nonce,
        publicKey: theirPublicKey,
        secretKey: SecureKey.fromList(_sodium, mySecretKey),
      );

      return Result.success(Uint8List.fromList(plaintext));
    } catch (e) {
      return Result.failure(
        AppError.decryption(message: 'Box decryption failed: $e'),
      );
    }
  }

  // ===========================================================================
  // MESSAGE ENCRYPTION (using secretBox)
  // ===========================================================================

  Future<Result<EncryptedMessage, AppError>> encryptMessage({
    required String plaintext,
    required Uint8List key,
    String? additionalData,
  }) async {
    try {
      final nonce = _sodium.randombytes.buf(
        _sodium.crypto.secretBox.nonceBytes,
      );
      final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));

      final ciphertext = _sodium.crypto.secretBox.easy(
        message: plaintextBytes,
        nonce: Uint8List.fromList(nonce),
        key: SecureKey.fromList(_sodium, key),
      );

      return Result.success(
        EncryptedMessage(
          ciphertext: Uint8List.fromList(ciphertext),
          nonce: Uint8List.fromList(nonce),
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Message encryption failed: $e'),
      );
    }
  }

  Future<Result<String, AppError>> decryptMessage({
    required EncryptedMessage encrypted,
    required Uint8List key,
    String? additionalData,
  }) async {
    try {
      final plaintext = _sodium.crypto.secretBox.openEasy(
        cipherText: encrypted.ciphertext,
        nonce: encrypted.nonce,
        key: SecureKey.fromList(_sodium, key),
      );

      return Result.success(utf8.decode(plaintext));
    } catch (e) {
      return Result.failure(
        AppError.decryption(message: 'Message decryption failed: $e'),
      );
    }
  }

  // ===========================================================================
  // DATA ENCRYPTION
  // ===========================================================================

  Future<Result<EncryptedMessage, AppError>> encryptData({
    required Uint8List data,
    required Uint8List key,
  }) async {
    try {
      final nonce = _sodium.randombytes.buf(
        _sodium.crypto.secretBox.nonceBytes,
      );

      final ciphertext = _sodium.crypto.secretBox.easy(
        message: data,
        nonce: Uint8List.fromList(nonce),
        key: SecureKey.fromList(_sodium, key),
      );

      return Result.success(
        EncryptedMessage(
          ciphertext: Uint8List.fromList(ciphertext),
          nonce: Uint8List.fromList(nonce),
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Data encryption failed: $e'),
      );
    }
  }

  Future<Result<Uint8List, AppError>> decryptData({
    required EncryptedMessage encrypted,
    required Uint8List key,
  }) async {
    try {
      final plaintext = _sodium.crypto.secretBox.openEasy(
        cipherText: encrypted.ciphertext,
        nonce: encrypted.nonce,
        key: SecureKey.fromList(_sodium, key),
      );

      return Result.success(Uint8List.fromList(plaintext));
    } catch (e) {
      return Result.failure(
        AppError.decryption(message: 'Data decryption failed: $e'),
      );
    }
  }

  // ===========================================================================
  // DIGITAL SIGNATURES
  // ===========================================================================

  Future<Result<Uint8List, AppError>> signData({
    required Uint8List data,
    required Uint8List secretKey,
  }) async {
    try {
      final signature = _sodium.crypto.sign.detached(
        message: data,
        secretKey: SecureKey.fromList(_sodium, secretKey),
      );
      return Result.success(Uint8List.fromList(signature));
    } catch (e) {
      return Result.failure(AppError.encryption(message: 'Signing failed: $e'));
    }
  }

  Future<Result<bool, AppError>> verifySignature({
    required Uint8List data,
    required Uint8List signature,
    required Uint8List publicKey,
  }) async {
    try {
      final isValid = _sodium.crypto.sign.verifyDetached(
        signature: signature,
        message: data,
        publicKey: publicKey,
      );
      return Result.success(isValid);
    } catch (e) {
      return Result.failure(
        AppError.encryption(message: 'Signature verification failed: $e'),
      );
    }
  }

  // ===========================================================================
  // UTILITIES
  // ===========================================================================

  String generateSessionId() => _uuid.v4();

  String generateHumanCode(Uint8List key) {
    final hash = _sodium.crypto.genericHash(message: key, outLen: 16);
    final number = hash[0] << 24 | hash[1] << 16 | hash[2] << 8 | hash[3];
    return 'HUSH-${number.toRadixString(36).toUpperCase()}';
  }

  bool validateKeyLength(Uint8List key, {int expectedLength = 32}) {
    return key.length == expectedLength;
  }

  String generateRandomString(int byteLength) {
    final bytes = _sodium.randombytes.buf(byteLength);
    return base64Url.encode(Uint8List.fromList(bytes)).replaceAll('=', '');
  }

  Uint8List hashData(Uint8List data, {int outLen = 32}) {
    return Uint8List.fromList(
      _sodium.crypto.genericHash(message: data, outLen: outLen),
    );
  }
}
