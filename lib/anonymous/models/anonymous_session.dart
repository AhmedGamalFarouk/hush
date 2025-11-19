/// Anonymous Session Models
/// Data structures for anonymous shared-key chat sessions
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'anonymous_session.freezed.dart';
part 'anonymous_session.g.dart';

/// Anonymous session descriptor
/// Contains all information needed to join a session
@freezed
class AnonymousSession with _$AnonymousSession {
  const factory AnonymousSession({
    required String sessionId,
    required String sessionSecret, // Base64URL-encoded 256-bit key
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default(10) int maxParticipants,
    @Default(true) bool isActive,
    String? humanCode, // Human-readable session code
    @Default([]) List<SessionParticipant> participants,
  }) = _AnonymousSession;

  factory AnonymousSession.fromJson(Map<String, dynamic> json) =>
      _$AnonymousSessionFromJson(json);
}

/// Session participant (ephemeral identity)
@freezed
class SessionParticipant with _$SessionParticipant {
  const factory SessionParticipant({
    required String ephemeralId,
    required String ephemeralPublicKey, // Base64URL X25519 public key
    required DateTime joinedAt,
    String? nickname, // Optional display name
    @Default(true) bool isOnline,
  }) = _SessionParticipant;

  factory SessionParticipant.fromJson(Map<String, dynamic> json) =>
      _$SessionParticipantFromJson(json);
}

/// Local session state (not stored on server)
@freezed
class LocalSessionState with _$LocalSessionState {
  const factory LocalSessionState({
    required String sessionId,
    required String masterSymKey, // Derived from session_secret
    required String bootstrapSeed, // Derived from session_secret
    required String ephemeralSecretKey, // X25519 secret key (base64)
    required String ephemeralPublicKey, // X25519 public key (base64)
    required String ephemeralId,
    String? nickname,
    @Default({}) Map<String, String> peerKeys, // ephemeralId -> publicKey
  }) = _LocalSessionState;

  factory LocalSessionState.fromJson(Map<String, dynamic> json) =>
      _$LocalSessionStateFromJson(json);
}

/// Session creation parameters
class CreateSessionParams {
  final Duration expiry;
  final int maxParticipants;
  final String? nickname;

  const CreateSessionParams({
    this.expiry = const Duration(hours: 24),
    this.maxParticipants = 10,
    this.nickname,
  });
}

/// Session join parameters
class JoinSessionParams {
  final String sessionKey; // Can be sessionSecret or QR data
  final String? nickname;

  const JoinSessionParams({required this.sessionKey, this.nickname});
}
