/// Profile Model
/// User profile with public keys for encryption
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String email,
    required String username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    required String publicKey, // X25519 public key (base64url)
    required String signingPublicKey, // Ed25519 public key (base64url)
    DateTime? lastSeen,
    @Default(false) bool isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
