/// Authentication Service
/// Handles user signup, login, logout with key pair generation
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_error.dart';
import '../../core/supabase/supabase_provider.dart';
import '../../core/utils/result.dart';
import '../../encryption/services/encryption_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(supabase: ref.watch(supabaseProvider));
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

  AuthService({required SupabaseClient supabase}) : _supabase = supabase;

  /// Sign up with email and password
  /// Generates X25519 and Ed25519 keypairs and stores public keys
  Future<Result<User, AppError>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    try {
      // Initialize sodium for key generation
      final sodium = await SodiumInit.init();
      final encryptionService = EncryptionService(sodium: sodium);

      // Generate key pairs
      final kxKeyPairResult = await encryptionService.generateKeyPair();
      if (kxKeyPairResult.isFailure) {
        return Result.failure(kxKeyPairResult.errorOrNull!);
      }
      final kxKeyPair = kxKeyPairResult.valueOrNull!;

      final signKeyPairResult = await encryptionService
          .generateSigningKeyPair();
      if (signKeyPairResult.isFailure) {
        return Result.failure(signKeyPairResult.errorOrNull!);
      }
      final signKeyPair = signKeyPairResult.valueOrNull!;

      // Sign up with Supabase
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return Result.failure(
          AppError.authentication(message: 'Signup failed'),
        );
      }

      final user = authResponse.user!;

      // Create profile with public keys
      await _supabase.from('profiles').insert({
        'id': user.id,
        'email': email,
        'username': username,
        'display_name': displayName ?? username,
        'public_key': base64Url.encode(kxKeyPair.publicKey),
        'signing_public_key': base64Url.encode(signKeyPair.publicKey),
      });

      // TODO: Securely store secret keys (encrypted with user password/PIN)
      // For now, this is a placeholder - production needs secure key storage

      return Result.success(user);
    } on AuthException catch (e) {
      return Result.failure(AppError.authentication(message: e.message));
    } catch (e) {
      return Result.failure(AppError.unknown(message: 'Signup failed: $e'));
    }
  }

  /// Sign in with email and password
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

      return Result.success(authResponse.user!);
    } on AuthException catch (e) {
      return Result.failure(AppError.authentication(message: e.message));
    } catch (e) {
      return Result.failure(AppError.unknown(message: 'Login failed: $e'));
    }
  }

  /// Sign out
  Future<Result<void, AppError>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppError.unknown(message: 'Sign out failed: $e'));
    }
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
