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
    @JsonKey(name: 'display_name') String? displayName,
    String? bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'public_key')
    required String publicKey, // X25519 public key (base64url)
    @JsonKey(name: 'signing_public_key')
    required String signingPublicKey, // Ed25519 public key (base64url)
    @JsonKey(name: 'last_seen') DateTime? lastSeen,
    @JsonKey(name: 'is_online') @Default(false) bool isOnline,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
