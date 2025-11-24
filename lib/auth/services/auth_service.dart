/// Authentication Service
/// Handles user signup, login, logout with key pair generation
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_error.dart';
import '../../core/supabase/supabase_provider.dart';
import '../../core/utils/result.dart';
import '../../encryption/providers/encryption_provider.dart';
import '../../encryption/providers/secure_key_storage_provider.dart';
import '../../encryption/services/encryption_service.dart';
import '../../encryption/services/secure_key_storage.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    supabase: ref.watch(supabaseProvider),
    encryptionService: ref.watch(encryptionServiceProvider),
    secureKeyStorage: ref.watch(secureKeyStorageProvider),
  );
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((event) {
    return event.session != null
        ? AuthState.authenticated(event.session!.user)
        : const AuthState.unauthenticated();
  });
});

sealed class AuthState {
  const AuthState();

  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
}

class _Authenticated extends AuthState {
  final User user;
  const _Authenticated(this.user);
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated();
}

class AuthService {
  final SupabaseClient _supabase;
  final EncryptionService _encryptionService;
  final SecureKeyStorage _secureKeyStorage;

  AuthService({
    required SupabaseClient supabase,
    required EncryptionService encryptionService,
    required SecureKeyStorage secureKeyStorage,
  }) : _supabase = supabase,
       _encryptionService = encryptionService,
       _secureKeyStorage = secureKeyStorage;

  /// Sign up with email and password
  /// Generates X25519 and Ed25519 keypairs and stores them securely
  Future<Result<User, AppError>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    try {
      // Generate key pairs
      final kxKeyPairResult = await _encryptionService.generateKeyPair();
      if (kxKeyPairResult.isFailure) {
        return Result.failure(kxKeyPairResult.errorOrNull!);
      }
      final kxKeyPair = kxKeyPairResult.valueOrNull!;

      final signKeyPairResult = await _encryptionService
          .generateSigningKeyPair();
      if (signKeyPairResult.isFailure) {
        return Result.failure(signKeyPairResult.errorOrNull!);
      }
      final signKeyPair = signKeyPairResult.valueOrNull!;

      // Sign up with Supabase
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'display_name': displayName ?? username,
          'public_key': base64Url.encode(kxKeyPair.publicKey),
          'signing_public_key': base64Url.encode(signKeyPair.publicKey),
        },
      );

      if (authResponse.user == null) {
        return Result.failure(
          AppError.authentication(message: 'Signup failed'),
        );
      }

      final user = authResponse.user!;

      // Only insert profile if session exists (email confirmation disabled)
      // If email confirmation is enabled, profile will be created via database trigger
      if (authResponse.session != null) {
        try {
          await _supabase.from('profiles').insert({
            'id': user.id,
            'email': email,
            'username': username,
            'display_name': displayName ?? username,
            'public_key': base64Url.encode(kxKeyPair.publicKey),
            'signing_public_key': base64Url.encode(signKeyPair.publicKey),
          });
        } catch (e) {
          // Profile might already exist from trigger, ignore
        }
      }

      // CRITICAL SECURITY: Store keys encrypted with user's password
      final storeResult = await _secureKeyStorage.storeKeyPairs(
        password: password,
        kxKeyPair: kxKeyPair,
        signKeyPair: signKeyPair,
      );

      if (storeResult.isFailure) {
        // Keys not stored - this is critical, should rollback signup
        await _supabase.auth.signOut();
        return Result.failure(
          AppError.encryption(
            message:
                'Failed to securely store keys: ${storeResult.errorOrNull?.message}',
          ),
        );
      }

      return Result.success(user);
    } on AuthException catch (e) {
      return Result.failure(AppError.authentication(message: e.message));
    } catch (e) {
      return Result.failure(AppError.unknown(message: 'Signup failed: $e'));
    }
  }

  /// Sign in with email and password
  /// Retrieves and decrypts user's private keys
  Future<Result<User, AppError>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return Result.failure(AppError.authentication(message: 'Login failed'));
      }

      // CRITICAL SECURITY: Retrieve and decrypt keys with password
      final keysResult = await _secureKeyStorage.retrieveKeyPairs(
        password: password,
      );

      if (keysResult.isFailure) {
        // Failed to decrypt keys - sign out for security
        await _supabase.auth.signOut();
        return Result.failure(
          AppError.authentication(
            message: 'Failed to decrypt keys. Password may have changed.',
          ),
        );
      }

      // Keys successfully decrypted and loaded into memory
      // They're now available for encryption/decryption operations
      // Note: In production, consider storing in a secure in-memory cache

      return Result.success(authResponse.user!);
    } on AuthException catch (e) {
      return Result.failure(AppError.authentication(message: e.message));
    } catch (e) {
      return Result.failure(AppError.unknown(message: 'Login failed: $e'));
    }
  }

  /// Sign out
  /// Clears session and removes keys from memory (not from storage)
  Future<Result<void, AppError>> signOut() async {
    try {
      await _supabase.auth.signOut();
      // Note: We don't clear keys from secure storage on sign out
      // They remain encrypted and can be retrieved on next login
      // To delete keys permanently, user must delete their account
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppError.unknown(message: 'Sign out failed: $e'));
    }
  }

  /// Delete account and all associated keys
  /// This is a destructive operation that cannot be undone
  Future<Result<void, AppError>> deleteAccount() async {
    try {
      // Clear keys from secure storage
      await _secureKeyStorage.clearKeys();

      // Sign out from Supabase
      await _supabase.auth.signOut();

      // Note: Actual account deletion should be done via Supabase admin API
      // or database trigger to clean up user data

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Account deletion failed: $e'),
      );
    }
  }

  /// Update password
  /// Updates password in Supabase Auth and re-encrypts local keys
  Future<Result<void, AppError>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // 1. Verify old password by trying to decrypt keys
      // This ensures we have the keys to re-encrypt them later
      // and that the user knows their current password
      final keysResult = await _secureKeyStorage.retrieveKeyPairs(
        password: oldPassword,
      );

      if (keysResult.isFailure) {
        return Result.failure(
          AppError.authentication(
            message: 'Incorrect current password. Cannot decrypt keys.',
          ),
        );
      }

      // 2. Update password in Supabase
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        return Result.failure(
          AppError.authentication(
            message: 'Failed to update password on server',
          ),
        );
      }

      // 3. Re-encrypt keys with new password
      final reEncryptResult = await _secureKeyStorage.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (reEncryptResult.isFailure) {
        // This is a bad state: Server password changed, but local keys are still encrypted with old password.
        // In a real app, we might want to prompt the user to re-enter old password or handle this gracefully.
        // For now, we return the error.
        return Result.failure(
          AppError.encryption(
            message:
                'Password updated on server, but failed to re-encrypt keys: ${reEncryptResult.errorOrNull?.message}',
          ),
        );
      }

      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AppError.authentication(message: e.message));
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Password update failed: $e'),
      );
    }
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
