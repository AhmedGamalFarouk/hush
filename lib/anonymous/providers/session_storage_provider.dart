/// Anonymous Session Storage Provider
/// Securely stores LocalSessionState on device for session persistence
/// 
/// SECURITY NOTES:
/// - Uses flutter_secure_storage for encrypted local storage
/// - Session keys are never sent to server
/// - Automatic cleanup on session expiry
/// - Support for multiple concurrent sessions
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/anonymous_session.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';

/// Provider for secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

/// Provider for anonymous session storage
final anonymousSessionStorageProvider = Provider<AnonymousSessionStorage>(
  (ref) {
    return AnonymousSessionStorage(
      storage: ref.watch(secureStorageProvider),
    );
  },
);

/// Provider for current active anonymous session (if any)
final currentAnonymousSessionProvider = StateProvider<LocalSessionState?>((
  ref,
) => null);

class AnonymousSessionStorage {
  final FlutterSecureStorage _storage;

  static const String _keyPrefix = 'hush_anonymous_session_';
  static const String _activeSessionKey = 'hush_active_anonymous_session';

  AnonymousSessionStorage({required FlutterSecureStorage storage})
      : _storage = storage;

  // ==========================================================================
  // SAVE SESSION
  // ==========================================================================

  /// Save a session to secure storage
  /// Returns the session ID on success
  Future<Result<String, AppError>> saveSession(
    LocalSessionState session,
  ) async {
    try {
      final key = _keyPrefix + session.sessionId;
      final json = jsonEncode(session.toJson());

      await _storage.write(key: key, value: json);

      // Also set as active session
      await _storage.write(key: _activeSessionKey, value: session.sessionId);

      return Result.success(session.sessionId);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to save session: $e'),
      );
    }
  }

  // ==========================================================================
  // LOAD SESSION
  // ==========================================================================

  /// Load a specific session by ID
  Future<Result<LocalSessionState?, AppError>> loadSession(
    String sessionId,
  ) async {
    try {
      final key = _keyPrefix + sessionId;
      final json = await _storage.read(key: key);

      if (json == null) {
        return const Result.success(null);
      }

      final session = LocalSessionState.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );

      return Result.success(session);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to load session: $e'),
      );
    }
  }

  /// Load the currently active session
  Future<Result<LocalSessionState?, AppError>> loadActiveSession() async {
    try {
      final sessionId = await _storage.read(key: _activeSessionKey);

      if (sessionId == null) {
        return const Result.success(null);
      }

      return loadSession(sessionId);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to load active session: $e'),
      );
    }
  }

  // ==========================================================================
  // DELETE SESSION
  // ==========================================================================

  /// Delete a specific session
  Future<Result<void, AppError>> deleteSession(String sessionId) async {
    try {
      final key = _keyPrefix + sessionId;
      await _storage.delete(key: key);

      // If this was the active session, clear it
      final activeSessionId = await _storage.read(key: _activeSessionKey);
      if (activeSessionId == sessionId) {
        await _storage.delete(key: _activeSessionKey);
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to delete session: $e'),
      );
    }
  }

  /// Delete all anonymous sessions
  Future<Result<void, AppError>> deleteAllSessions() async {
    try {
      final allKeys = await _storage.readAll();

      for (final key in allKeys.keys) {
        if (key.startsWith(_keyPrefix) || key == _activeSessionKey) {
          await _storage.delete(key: key);
        }
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to delete all sessions: $e'),
      );
    }
  }

  // ==========================================================================
  // LIST SESSIONS
  // ==========================================================================

  /// Get all stored session IDs
  Future<Result<List<String>, AppError>> listSessionIds() async {
    try {
      final allKeys = await _storage.readAll();
      final sessionIds = <String>[];

      for (final key in allKeys.keys) {
        if (key.startsWith(_keyPrefix)) {
          final sessionId = key.substring(_keyPrefix.length);
          sessionIds.add(sessionId);
        }
      }

      return Result.success(sessionIds);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to list sessions: $e'),
      );
    }
  }

  /// Load all stored sessions
  Future<Result<List<LocalSessionState>, AppError>> loadAllSessions() async {
    try {
      final sessionIdsResult = await listSessionIds();

      if (sessionIdsResult.isFailure) {
        return Result.failure(sessionIdsResult.errorOrNull!);
      }

      final sessionIds = sessionIdsResult.valueOrNull!;
      final sessions = <LocalSessionState>[];

      for (final sessionId in sessionIds) {
        final sessionResult = await loadSession(sessionId);

        if (sessionResult.isSuccess && sessionResult.valueOrNull != null) {
          sessions.add(sessionResult.valueOrNull!);
        }
      }

      return Result.success(sessions);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to load all sessions: $e'),
      );
    }
  }

  // ==========================================================================
  // UPDATE SESSION
  // ==========================================================================

  /// Update peer keys in a session
  Future<Result<void, AppError>> updateSessionPeerKeys(
    String sessionId,
    Map<String, String> peerKeys,
  ) async {
    try {
      final sessionResult = await loadSession(sessionId);

      if (sessionResult.isFailure || sessionResult.valueOrNull == null) {
        return Result.failure(AppError.notFound(message: 'Session not found'));
      }

      final session = sessionResult.valueOrNull!;
      final updatedSession = LocalSessionState(
        sessionId: session.sessionId,
        masterSymKey: session.masterSymKey,
        bootstrapSeed: session.bootstrapSeed,
        ephemeralSecretKey: session.ephemeralSecretKey,
        ephemeralPublicKey: session.ephemeralPublicKey,
        ephemeralId: session.ephemeralId,
        nickname: session.nickname,
        peerKeys: {...session.peerKeys, ...peerKeys},
      );

      return saveSession(updatedSession).then(
        (_) => const Result.success(null),
      );
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to update session: $e'),
      );
    }
  }

  // ==========================================================================
  // CLEANUP
  // ==========================================================================

  /// Clean up expired sessions based on a list of valid session IDs
  /// Call this after checking with server which sessions are still active
  Future<Result<int, AppError>> cleanupExpiredSessions(
    List<String> validSessionIds,
  ) async {
    try {
      final allSessionsResult = await listSessionIds();

      if (allSessionsResult.isFailure) {
        return Result.failure(allSessionsResult.errorOrNull!);
      }

      final allSessionIds = allSessionsResult.valueOrNull!;
      var deletedCount = 0;

      for (final sessionId in allSessionIds) {
        if (!validSessionIds.contains(sessionId)) {
          final deleteResult = await deleteSession(sessionId);
          if (deleteResult.isSuccess) {
            deletedCount++;
          }
        }
      }

      return Result.success(deletedCount);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Failed to cleanup sessions: $e'),
      );
    }
  }
}

