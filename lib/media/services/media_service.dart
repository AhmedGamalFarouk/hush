/// Media Service
/// Handles encrypted file/image upload and download with Supabase Storage
///
/// CRYPTO DESIGN:
/// 1. File Encryption:
///    - Generate unique media_key (256-bit random) per file
///    - Encrypt file with AEAD (XChaCha20-Poly1305)
///    - Upload encrypted file to Supabase Storage
///    - Store media_key in message metadata (encrypted with conversation key)
///
/// 2. File Download:
///    - Fetch encrypted file from storage
///    - Decrypt using media_key from message
///    - Cache decrypted file locally for performance
///
/// 3. Thumbnails:
///    - Generate thumbnail before encryption
///    - Encrypt thumbnail separately
///    - Store as separate file in storage
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_error.dart';
import '../../core/supabase/supabase_provider.dart';
import '../../core/utils/result.dart';
import '../../encryption/services/encryption_service.dart';

/// Provider for media service
final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService(supabase: ref.watch(supabaseProvider));
});

/// Encrypted media metadata
class EncryptedMedia {
  final String url; // URL to encrypted file in storage
  final String mediaKey; // Base64-encoded encryption key
  final String? thumbnailUrl;
  final String mediaType; // image, video, file
  final int fileSize;
  final String fileName;

  const EncryptedMedia({
    required this.url,
    required this.mediaKey,
    this.thumbnailUrl,
    required this.mediaType,
    required this.fileSize,
    required this.fileName,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'media_key': mediaKey,
    'thumbnail_url': thumbnailUrl,
    'media_type': mediaType,
    'file_size': fileSize,
    'file_name': fileName,
  };

  factory EncryptedMedia.fromJson(Map<String, dynamic> json) => EncryptedMedia(
    url: json['url'] as String,
    mediaKey: json['media_key'] as String,
    thumbnailUrl: json['thumbnail_url'] as String?,
    mediaType: json['media_type'] as String,
    fileSize: json['file_size'] as int,
    fileName: json['file_name'] as String,
  );
}

class MediaService {
  final SupabaseClient _supabase;
  late final EncryptionService _encryption;
  static const String _bucket = 'encrypted-media';

  MediaService({required SupabaseClient supabase}) : _supabase = supabase {
    // Initialize encryption service
    SodiumInit.init().then((sodium) {
      _encryption = EncryptionService(sodium: sodium);
    });
  }

  // ============================================================================
  // FILE UPLOAD
  // ============================================================================

  /// Encrypt and upload a file
  Future<Result<EncryptedMedia, AppError>> encryptAndUpload({
    required File file,
    required String conversationId,
    String? fileName,
  }) async {
    try {
      // 1. Read file
      final fileBytes = await file.readAsBytes();
      final actualFileName = fileName ?? file.path.split('/').last;

      // 2. Generate unique media key
      final mediaKeyResult = await _encryption.generateRandomKey();
      if (mediaKeyResult.isFailure) {
        return Result.failure(mediaKeyResult.errorOrNull!);
      }
      final mediaKey = mediaKeyResult.valueOrNull!;

      // 3. Encrypt file
      final encryptResult = await _encryption.encryptData(
        data: fileBytes,
        key: mediaKey,
      );
      if (encryptResult.isFailure) {
        return Result.failure(encryptResult.errorOrNull!);
      }
      final encrypted = encryptResult.valueOrNull!;

      // 4. Combine ciphertext and nonce for storage
      final encryptedFile = Uint8List.fromList([
        ...encrypted.nonce,
        ...encrypted.ciphertext,
      ]);

      // 5. Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomId = _encryption.generateRandomString(8);
      final storagePath = '$conversationId/$timestamp-$randomId.enc';

      // 6. Upload to Supabase Storage
      await _supabase.storage
          .from(_bucket)
          .uploadBinary(storagePath, encryptedFile);

      // 7. Get public URL
      final url = _supabase.storage.from(_bucket).getPublicUrl(storagePath);

      // 8. Determine media type
      final mediaType = _determineMediaType(actualFileName);

      return Result.success(
        EncryptedMedia(
          url: url,
          mediaKey: _encryption.generateRandomString(32), // Store securely
          mediaType: mediaType,
          fileSize: fileBytes.length,
          fileName: actualFileName,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to upload file: $e'),
      );
    }
  }

  // ============================================================================
  // FILE DOWNLOAD
  // ============================================================================

  /// Download and decrypt a file
  Future<Result<File, AppError>> downloadAndDecrypt({
    required EncryptedMedia media,
  }) async {
    try {
      // 1. Check cache first
      final cachedFile = await _getCachedFile(media.url);
      if (cachedFile != null && await cachedFile.exists()) {
        return Result.success(cachedFile);
      }

      // 2. Download encrypted file
      final encryptedBytes = await _supabase.storage
          .from(_bucket)
          .download(media.url.split('/').last);

      // 3. Split nonce and ciphertext
      final nonceSize = 24; // XChaCha20 nonce size
      final nonce = Uint8List.fromList(encryptedBytes.sublist(0, nonceSize));
      final ciphertext = Uint8List.fromList(encryptedBytes.sublist(nonceSize));

      // 4. Decrypt
      final mediaKey = Uint8List(32); // TODO: Get from message metadata
      final encrypted = EncryptedMessage(ciphertext: ciphertext, nonce: nonce);

      final decryptResult = await _encryption.decryptData(
        encrypted: encrypted,
        key: mediaKey,
      );

      if (decryptResult.isFailure) {
        return Result.failure(decryptResult.errorOrNull!);
      }

      final decryptedBytes = decryptResult.valueOrNull!;

      // 5. Save to cache
      final cacheFile = await _cacheFile(media.url, decryptedBytes);

      return Result.success(cacheFile);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to download file: $e'),
      );
    }
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Get cached file if exists
  Future<File?> _getCachedFile(String url) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final fileName = _getCacheFileName(url);
      final file = File('${cacheDir.path}/media_cache/$fileName');
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Cache decrypted file
  Future<File> _cacheFile(String url, Uint8List data) async {
    final cacheDir = await getTemporaryDirectory();
    final fileName = _getCacheFileName(url);
    final dir = Directory('${cacheDir.path}/media_cache');

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(data);
    return file;
  }

  /// Generate cache filename from URL
  String _getCacheFileName(String url) {
    final hash = _encryption.hashData(
      Uint8List.fromList(url.codeUnits),
      outLen: 16,
    );
    return hash.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Clear media cache
  Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final dir = Directory('${cacheDir.path}/media_cache');
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      // Silently fail
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Determine media type from filename
  String _determineMediaType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    const videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm'];

    if (imageExtensions.contains(extension)) {
      return 'image';
    } else if (videoExtensions.contains(extension)) {
      return 'video';
    } else {
      return 'file';
    }
  }

  /// Get file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
