import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodium_libs/sodium_libs.dart';
import '../services/encryption_service.dart';

/// Provider for the Sodium instance
/// Must be overridden in main.dart with the initialized instance
final sodiumProvider = Provider<Sodium>((ref) {
  throw UnimplementedError(
    'Sodium must be initialized in main.dart and overridden',
  );
});

/// Provider for the EncryptionService
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  final sodium = ref.watch(sodiumProvider);
  return EncryptionService(sodium: sodium);
});
