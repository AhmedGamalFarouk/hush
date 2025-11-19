// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anonymous_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnonymousSessionImpl _$$AnonymousSessionImplFromJson(
  Map<String, dynamic> json,
) => _$AnonymousSessionImpl(
  sessionId: json['sessionId'] as String,
  sessionSecret: json['sessionSecret'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 10,
  isActive: json['isActive'] as bool? ?? true,
  humanCode: json['humanCode'] as String?,
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map((e) => SessionParticipant.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$AnonymousSessionImplToJson(
  _$AnonymousSessionImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'sessionSecret': instance.sessionSecret,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'maxParticipants': instance.maxParticipants,
  'isActive': instance.isActive,
  'humanCode': instance.humanCode,
  'participants': instance.participants,
};

_$SessionParticipantImpl _$$SessionParticipantImplFromJson(
  Map<String, dynamic> json,
) => _$SessionParticipantImpl(
  ephemeralId: json['ephemeralId'] as String,
  ephemeralPublicKey: json['ephemeralPublicKey'] as String,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  nickname: json['nickname'] as String?,
  isOnline: json['isOnline'] as bool? ?? true,
);

Map<String, dynamic> _$$SessionParticipantImplToJson(
  _$SessionParticipantImpl instance,
) => <String, dynamic>{
  'ephemeralId': instance.ephemeralId,
  'ephemeralPublicKey': instance.ephemeralPublicKey,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'nickname': instance.nickname,
  'isOnline': instance.isOnline,
};

_$LocalSessionStateImpl _$$LocalSessionStateImplFromJson(
  Map<String, dynamic> json,
) => _$LocalSessionStateImpl(
  sessionId: json['sessionId'] as String,
  masterSymKey: json['masterSymKey'] as String,
  bootstrapSeed: json['bootstrapSeed'] as String,
  ephemeralSecretKey: json['ephemeralSecretKey'] as String,
  ephemeralPublicKey: json['ephemeralPublicKey'] as String,
  ephemeralId: json['ephemeralId'] as String,
  nickname: json['nickname'] as String?,
  peerKeys:
      (json['peerKeys'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$$LocalSessionStateImplToJson(
  _$LocalSessionStateImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'masterSymKey': instance.masterSymKey,
  'bootstrapSeed': instance.bootstrapSeed,
  'ephemeralSecretKey': instance.ephemeralSecretKey,
  'ephemeralPublicKey': instance.ephemeralPublicKey,
  'ephemeralId': instance.ephemeralId,
  'nickname': instance.nickname,
  'peerKeys': instance.peerKeys,
};
