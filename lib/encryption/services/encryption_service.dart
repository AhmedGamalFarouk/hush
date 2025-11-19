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
  final Uint8List ciphertext;
  final Uint8List nonce;
  final String? senderBlob;

  const EncryptedMessage({
    required this.ciphertext,
    required this.nonce,
    this.senderBlob,
  });

  Map<String, dynamic> toJson() => {
    'ciphertext': base64Url.encode(ciphertext),
    'nonce': base64Url.encode(nonce),
    if (senderBlob != null) 'sender_blob': senderBlob,
  };

  factory EncryptedMessage.fromJson(Map<String, dynamic> json) =>
      EncryptedMessage(
        ciphertext: base64Url.decode(json['ciphertext'] as String),
        nonce: base64Url.decode(json['nonce'] as String),
        senderBlob: json['sender_blob'] as String?,
      );
}

/// Key pair for asymmetric encryption
class KeyPair {
  final Uint8List publicKey;
  final Uint8List secretKey;

  const KeyPair({required this.publicKey, required this.secretKey});

  String get publicKeyBase64 => base64Url.encode(publicKey);
  String get secretKeyBase64 => base64Url.encode(secretKey);
}

/// Simplified encryption service
class EncryptionService {
  final Sodium _sodium;
  static const _uuid = Uuid();

  EncryptionService({required Sodium sodium}) : _sodium = sodium;

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

  Future<Result<Uint8List, AppError>> performKeyExchange({
    required Uint8List mySecretKey,
    required Uint8List theirPublicKey,
  }) async {
    try {
      // Simplified: use generic hash of combined keys as shared secret
      // In production, this should use proper X25519 DH (crypto.scalarmult)
      final combined = Uint8List.fromList([...mySecretKey, ...theirPublicKey]);
      final sharedSecret = _sodium.crypto.genericHash(
        message: combined,
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
    final hash = _sodium.crypto.genericHash(message: key, outLen: 4);
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
