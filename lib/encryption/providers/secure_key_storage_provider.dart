/// Provider for SecureKeyStorage
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_key_storage.dart';
import 'encryption_provider.dart';

final secureKeyStorageProvider = Provider<SecureKeyStorage>((ref) {
  final sodium = ref.watch(sodiumProvider);
  return SecureKeyStorage(sodium: sodium);
});
