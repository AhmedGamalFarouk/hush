// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anonymous_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnonymousSession _$AnonymousSessionFromJson(Map<String, dynamic> json) {
  return _AnonymousSession.fromJson(json);
}

/// @nodoc
mixin _$AnonymousSession {
  String get sessionId => throw _privateConstructorUsedError;
  String get sessionSecret =>
      throw _privateConstructorUsedError; // Base64URL-encoded 256-bit key
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get humanCode =>
      throw _privateConstructorUsedError; // Human-readable session code
  List<SessionParticipant> get participants =>
      throw _privateConstructorUsedError;

  /// Serializes this AnonymousSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnonymousSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnonymousSessionCopyWith<AnonymousSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnonymousSessionCopyWith<$Res> {
  factory $AnonymousSessionCopyWith(
    AnonymousSession value,
    $Res Function(AnonymousSession) then,
  ) = _$AnonymousSessionCopyWithImpl<$Res, AnonymousSession>;
  @useResult
  $Res call({
    String sessionId,
    String sessionSecret,
    DateTime createdAt,
    DateTime expiresAt,
    int maxParticipants,
    bool isActive,
    String? humanCode,
    List<SessionParticipant> participants,
  });
}

/// @nodoc
class _$AnonymousSessionCopyWithImpl<$Res, $Val extends AnonymousSession>
    implements $AnonymousSessionCopyWith<$Res> {
  _$AnonymousSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnonymousSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? sessionSecret = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? maxParticipants = null,
    Object? isActive = null,
    Object? humanCode = freezed,
    Object? participants = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionSecret: null == sessionSecret
                ? _value.sessionSecret
                : sessionSecret // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            maxParticipants: null == maxParticipants
                ? _value.maxParticipants
                : maxParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            humanCode: freezed == humanCode
                ? _value.humanCode
                : humanCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            participants: null == participants
                ? _value.participants
                : participants // ignore: cast_nullable_to_non_nullable
                      as List<SessionParticipant>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnonymousSessionImplCopyWith<$Res>
    implements $AnonymousSessionCopyWith<$Res> {
  factory _$$AnonymousSessionImplCopyWith(
    _$AnonymousSessionImpl value,
    $Res Function(_$AnonymousSessionImpl) then,
  ) = __$$AnonymousSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    String sessionSecret,
    DateTime createdAt,
    DateTime expiresAt,
    int maxParticipants,
    bool isActive,
    String? humanCode,
    List<SessionParticipant> participants,
  });
}

/// @nodoc
class __$$AnonymousSessionImplCopyWithImpl<$Res>
    extends _$AnonymousSessionCopyWithImpl<$Res, _$AnonymousSessionImpl>
    implements _$$AnonymousSessionImplCopyWith<$Res> {
  __$$AnonymousSessionImplCopyWithImpl(
    _$AnonymousSessionImpl _value,
    $Res Function(_$AnonymousSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnonymousSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? sessionSecret = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? maxParticipants = null,
    Object? isActive = null,
    Object? humanCode = freezed,
    Object? participants = null,
  }) {
    return _then(
      _$AnonymousSessionImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionSecret: null == sessionSecret
            ? _value.sessionSecret
            : sessionSecret // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        maxParticipants: null == maxParticipants
            ? _value.maxParticipants
            : maxParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        humanCode: freezed == humanCode
            ? _value.humanCode
            : humanCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        participants: null == participants
            ? _value._participants
            : participants // ignore: cast_nullable_to_non_nullable
                  as List<SessionParticipant>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnonymousSessionImpl implements _AnonymousSession {
  const _$AnonymousSessionImpl({
    required this.sessionId,
    required this.sessionSecret,
    required this.createdAt,
    required this.expiresAt,
    this.maxParticipants = 10,
    this.isActive = true,
    this.humanCode,
    final List<SessionParticipant> participants = const [],
  }) : _participants = participants;

  factory _$AnonymousSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnonymousSessionImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String sessionSecret;
  // Base64URL-encoded 256-bit key
  @override
  final DateTime createdAt;
  @override
  final DateTime expiresAt;
  @override
  @JsonKey()
  final int maxParticipants;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? humanCode;
  // Human-readable session code
  final List<SessionParticipant> _participants;
  // Human-readable session code
  @override
  @JsonKey()
  List<SessionParticipant> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  String toString() {
    return 'AnonymousSession(sessionId: $sessionId, sessionSecret: $sessionSecret, createdAt: $createdAt, expiresAt: $expiresAt, maxParticipants: $maxParticipants, isActive: $isActive, humanCode: $humanCode, participants: $participants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnonymousSessionImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.sessionSecret, sessionSecret) ||
                other.sessionSecret == sessionSecret) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.humanCode, humanCode) ||
                other.humanCode == humanCode) &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    sessionSecret,
    createdAt,
    expiresAt,
    maxParticipants,
    isActive,
    humanCode,
    const DeepCollectionEquality().hash(_participants),
  );

  /// Create a copy of AnonymousSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnonymousSessionImplCopyWith<_$AnonymousSessionImpl> get copyWith =>
      __$$AnonymousSessionImplCopyWithImpl<_$AnonymousSessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AnonymousSessionImplToJson(this);
  }
}

abstract class _AnonymousSession implements AnonymousSession {
  const factory _AnonymousSession({
    required final String sessionId,
    required final String sessionSecret,
    required final DateTime createdAt,
    required final DateTime expiresAt,
    final int maxParticipants,
    final bool isActive,
    final String? humanCode,
    final List<SessionParticipant> participants,
  }) = _$AnonymousSessionImpl;

  factory _AnonymousSession.fromJson(Map<String, dynamic> json) =
      _$AnonymousSessionImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get sessionSecret; // Base64URL-encoded 256-bit key
  @override
  DateTime get createdAt;
  @override
  DateTime get expiresAt;
  @override
  int get maxParticipants;
  @override
  bool get isActive;
  @override
  String? get humanCode; // Human-readable session code
  @override
  List<SessionParticipant> get participants;

  /// Create a copy of AnonymousSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnonymousSessionImplCopyWith<_$AnonymousSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionParticipant _$SessionParticipantFromJson(Map<String, dynamic> json) {
  return _SessionParticipant.fromJson(json);
}

/// @nodoc
mixin _$SessionParticipant {
  String get ephemeralId => throw _privateConstructorUsedError;
  String get ephemeralPublicKey =>
      throw _privateConstructorUsedError; // Base64URL X25519 public key
  DateTime get joinedAt => throw _privateConstructorUsedError;
  String? get nickname =>
      throw _privateConstructorUsedError; // Optional display name
  bool get isOnline => throw _privateConstructorUsedError;

  /// Serializes this SessionParticipant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionParticipantCopyWith<SessionParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionParticipantCopyWith<$Res> {
  factory $SessionParticipantCopyWith(
    SessionParticipant value,
    $Res Function(SessionParticipant) then,
  ) = _$SessionParticipantCopyWithImpl<$Res, SessionParticipant>;
  @useResult
  $Res call({
    String ephemeralId,
    String ephemeralPublicKey,
    DateTime joinedAt,
    String? nickname,
    bool isOnline,
  });
}

/// @nodoc
class _$SessionParticipantCopyWithImpl<$Res, $Val extends SessionParticipant>
    implements $SessionParticipantCopyWith<$Res> {
  _$SessionParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ephemeralId = null,
    Object? ephemeralPublicKey = null,
    Object? joinedAt = null,
    Object? nickname = freezed,
    Object? isOnline = null,
  }) {
    return _then(
      _value.copyWith(
            ephemeralId: null == ephemeralId
                ? _value.ephemeralId
                : ephemeralId // ignore: cast_nullable_to_non_nullable
                      as String,
            ephemeralPublicKey: null == ephemeralPublicKey
                ? _value.ephemeralPublicKey
                : ephemeralPublicKey // ignore: cast_nullable_to_non_nullable
                      as String,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            nickname: freezed == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            isOnline: null == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionParticipantImplCopyWith<$Res>
    implements $SessionParticipantCopyWith<$Res> {
  factory _$$SessionParticipantImplCopyWith(
    _$SessionParticipantImpl value,
    $Res Function(_$SessionParticipantImpl) then,
  ) = __$$SessionParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String ephemeralId,
    String ephemeralPublicKey,
    DateTime joinedAt,
    String? nickname,
    bool isOnline,
  });
}

/// @nodoc
class __$$SessionParticipantImplCopyWithImpl<$Res>
    extends _$SessionParticipantCopyWithImpl<$Res, _$SessionParticipantImpl>
    implements _$$SessionParticipantImplCopyWith<$Res> {
  __$$SessionParticipantImplCopyWithImpl(
    _$SessionParticipantImpl _value,
    $Res Function(_$SessionParticipantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ephemeralId = null,
    Object? ephemeralPublicKey = null,
    Object? joinedAt = null,
    Object? nickname = freezed,
    Object? isOnline = null,
  }) {
    return _then(
      _$SessionParticipantImpl(
        ephemeralId: null == ephemeralId
            ? _value.ephemeralId
            : ephemeralId // ignore: cast_nullable_to_non_nullable
                  as String,
        ephemeralPublicKey: null == ephemeralPublicKey
            ? _value.ephemeralPublicKey
            : ephemeralPublicKey // ignore: cast_nullable_to_non_nullable
                  as String,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        nickname: freezed == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        isOnline: null == isOnline
            ? _value.isOnline
            : isOnline // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionParticipantImpl implements _SessionParticipant {
  const _$SessionParticipantImpl({
    required this.ephemeralId,
    required this.ephemeralPublicKey,
    required this.joinedAt,
    this.nickname,
    this.isOnline = true,
  });

  factory _$SessionParticipantImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionParticipantImplFromJson(json);

  @override
  final String ephemeralId;
  @override
  final String ephemeralPublicKey;
  // Base64URL X25519 public key
  @override
  final DateTime joinedAt;
  @override
  final String? nickname;
  // Optional display name
  @override
  @JsonKey()
  final bool isOnline;

  @override
  String toString() {
    return 'SessionParticipant(ephemeralId: $ephemeralId, ephemeralPublicKey: $ephemeralPublicKey, joinedAt: $joinedAt, nickname: $nickname, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionParticipantImpl &&
            (identical(other.ephemeralId, ephemeralId) ||
                other.ephemeralId == ephemeralId) &&
            (identical(other.ephemeralPublicKey, ephemeralPublicKey) ||
                other.ephemeralPublicKey == ephemeralPublicKey) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    ephemeralId,
    ephemeralPublicKey,
    joinedAt,
    nickname,
    isOnline,
  );

  /// Create a copy of SessionParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionParticipantImplCopyWith<_$SessionParticipantImpl> get copyWith =>
      __$$SessionParticipantImplCopyWithImpl<_$SessionParticipantImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionParticipantImplToJson(this);
  }
}

abstract class _SessionParticipant implements SessionParticipant {
  const factory _SessionParticipant({
    required final String ephemeralId,
    required final String ephemeralPublicKey,
    required final DateTime joinedAt,
    final String? nickname,
    final bool isOnline,
  }) = _$SessionParticipantImpl;

  factory _SessionParticipant.fromJson(Map<String, dynamic> json) =
      _$SessionParticipantImpl.fromJson;

  @override
  String get ephemeralId;
  @override
  String get ephemeralPublicKey; // Base64URL X25519 public key
  @override
  DateTime get joinedAt;
  @override
  String? get nickname; // Optional display name
  @override
  bool get isOnline;

  /// Create a copy of SessionParticipant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionParticipantImplCopyWith<_$SessionParticipantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocalSessionState _$LocalSessionStateFromJson(Map<String, dynamic> json) {
  return _LocalSessionState.fromJson(json);
}

/// @nodoc
mixin _$LocalSessionState {
  String get sessionId => throw _privateConstructorUsedError;
  String get masterSymKey =>
      throw _privateConstructorUsedError; // Derived from session_secret
  String get bootstrapSeed =>
      throw _privateConstructorUsedError; // Derived from session_secret
  String get ephemeralSecretKey =>
      throw _privateConstructorUsedError; // X25519 secret key (base64)
  String get ephemeralPublicKey =>
      throw _privateConstructorUsedError; // X25519 public key (base64)
  String get ephemeralId => throw _privateConstructorUsedError;
  String? get nickname => throw _privateConstructorUsedError;
  Map<String, String> get peerKeys => throw _privateConstructorUsedError;

  /// Serializes this LocalSessionState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalSessionStateCopyWith<LocalSessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalSessionStateCopyWith<$Res> {
  factory $LocalSessionStateCopyWith(
    LocalSessionState value,
    $Res Function(LocalSessionState) then,
  ) = _$LocalSessionStateCopyWithImpl<$Res, LocalSessionState>;
  @useResult
  $Res call({
    String sessionId,
    String masterSymKey,
    String bootstrapSeed,
    String ephemeralSecretKey,
    String ephemeralPublicKey,
    String ephemeralId,
    String? nickname,
    Map<String, String> peerKeys,
  });
}

/// @nodoc
class _$LocalSessionStateCopyWithImpl<$Res, $Val extends LocalSessionState>
    implements $LocalSessionStateCopyWith<$Res> {
  _$LocalSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? masterSymKey = null,
    Object? bootstrapSeed = null,
    Object? ephemeralSecretKey = null,
    Object? ephemeralPublicKey = null,
    Object? ephemeralId = null,
    Object? nickname = freezed,
    Object? peerKeys = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            masterSymKey: null == masterSymKey
                ? _value.masterSymKey
                : masterSymKey // ignore: cast_nullable_to_non_nullable
                      as String,
            bootstrapSeed: null == bootstrapSeed
                ? _value.bootstrapSeed
                : bootstrapSeed // ignore: cast_nullable_to_non_nullable
                      as String,
            ephemeralSecretKey: null == ephemeralSecretKey
                ? _value.ephemeralSecretKey
                : ephemeralSecretKey // ignore: cast_nullable_to_non_nullable
                      as String,
            ephemeralPublicKey: null == ephemeralPublicKey
                ? _value.ephemeralPublicKey
                : ephemeralPublicKey // ignore: cast_nullable_to_non_nullable
                      as String,
            ephemeralId: null == ephemeralId
                ? _value.ephemeralId
                : ephemeralId // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: freezed == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            peerKeys: null == peerKeys
                ? _value.peerKeys
                : peerKeys // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocalSessionStateImplCopyWith<$Res>
    implements $LocalSessionStateCopyWith<$Res> {
  factory _$$LocalSessionStateImplCopyWith(
    _$LocalSessionStateImpl value,
    $Res Function(_$LocalSessionStateImpl) then,
  ) = __$$LocalSessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    String masterSymKey,
    String bootstrapSeed,
    String ephemeralSecretKey,
    String ephemeralPublicKey,
    String ephemeralId,
    String? nickname,
    Map<String, String> peerKeys,
  });
}

/// @nodoc
class __$$LocalSessionStateImplCopyWithImpl<$Res>
    extends _$LocalSessionStateCopyWithImpl<$Res, _$LocalSessionStateImpl>
    implements _$$LocalSessionStateImplCopyWith<$Res> {
  __$$LocalSessionStateImplCopyWithImpl(
    _$LocalSessionStateImpl _value,
    $Res Function(_$LocalSessionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? masterSymKey = null,
    Object? bootstrapSeed = null,
    Object? ephemeralSecretKey = null,
    Object? ephemeralPublicKey = null,
    Object? ephemeralId = null,
    Object? nickname = freezed,
    Object? peerKeys = null,
  }) {
    return _then(
      _$LocalSessionStateImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        masterSymKey: null == masterSymKey
            ? _value.masterSymKey
            : masterSymKey // ignore: cast_nullable_to_non_nullable
                  as String,
        bootstrapSeed: null == bootstrapSeed
            ? _value.bootstrapSeed
            : bootstrapSeed // ignore: cast_nullable_to_non_nullable
                  as String,
        ephemeralSecretKey: null == ephemeralSecretKey
            ? _value.ephemeralSecretKey
            : ephemeralSecretKey // ignore: cast_nullable_to_non_nullable
                  as String,
        ephemeralPublicKey: null == ephemeralPublicKey
            ? _value.ephemeralPublicKey
            : ephemeralPublicKey // ignore: cast_nullable_to_non_nullable
                  as String,
        ephemeralId: null == ephemeralId
            ? _value.ephemeralId
            : ephemeralId // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: freezed == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        peerKeys: null == peerKeys
            ? _value._peerKeys
            : peerKeys // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalSessionStateImpl implements _LocalSessionState {
  const _$LocalSessionStateImpl({
    required this.sessionId,
    required this.masterSymKey,
    required this.bootstrapSeed,
    required this.ephemeralSecretKey,
    required this.ephemeralPublicKey,
    required this.ephemeralId,
    this.nickname,
    final Map<String, String> peerKeys = const {},
  }) : _peerKeys = peerKeys;

  factory _$LocalSessionStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalSessionStateImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String masterSymKey;
  // Derived from session_secret
  @override
  final String bootstrapSeed;
  // Derived from session_secret
  @override
  final String ephemeralSecretKey;
  // X25519 secret key (base64)
  @override
  final String ephemeralPublicKey;
  // X25519 public key (base64)
  @override
  final String ephemeralId;
  @override
  final String? nickname;
  final Map<String, String> _peerKeys;
  @override
  @JsonKey()
  Map<String, String> get peerKeys {
    if (_peerKeys is EqualUnmodifiableMapView) return _peerKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_peerKeys);
  }

  @override
  String toString() {
    return 'LocalSessionState(sessionId: $sessionId, masterSymKey: $masterSymKey, bootstrapSeed: $bootstrapSeed, ephemeralSecretKey: $ephemeralSecretKey, ephemeralPublicKey: $ephemeralPublicKey, ephemeralId: $ephemeralId, nickname: $nickname, peerKeys: $peerKeys)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalSessionStateImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.masterSymKey, masterSymKey) ||
                other.masterSymKey == masterSymKey) &&
            (identical(other.bootstrapSeed, bootstrapSeed) ||
                other.bootstrapSeed == bootstrapSeed) &&
            (identical(other.ephemeralSecretKey, ephemeralSecretKey) ||
                other.ephemeralSecretKey == ephemeralSecretKey) &&
            (identical(other.ephemeralPublicKey, ephemeralPublicKey) ||
                other.ephemeralPublicKey == ephemeralPublicKey) &&
            (identical(other.ephemeralId, ephemeralId) ||
                other.ephemeralId == ephemeralId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            const DeepCollectionEquality().equals(other._peerKeys, _peerKeys));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    masterSymKey,
    bootstrapSeed,
    ephemeralSecretKey,
    ephemeralPublicKey,
    ephemeralId,
    nickname,
    const DeepCollectionEquality().hash(_peerKeys),
  );

  /// Create a copy of LocalSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalSessionStateImplCopyWith<_$LocalSessionStateImpl> get copyWith =>
      __$$LocalSessionStateImplCopyWithImpl<_$LocalSessionStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalSessionStateImplToJson(this);
  }
}

abstract class _LocalSessionState implements LocalSessionState {
  const factory _LocalSessionState({
    required final String sessionId,
    required final String masterSymKey,
    required final String bootstrapSeed,
    required final String ephemeralSecretKey,
    required final String ephemeralPublicKey,
    required final String ephemeralId,
    final String? nickname,
    final Map<String, String> peerKeys,
  }) = _$LocalSessionStateImpl;

  factory _LocalSessionState.fromJson(Map<String, dynamic> json) =
      _$LocalSessionStateImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get masterSymKey; // Derived from session_secret
  @override
  String get bootstrapSeed; // Derived from session_secret
  @override
  String get ephemeralSecretKey; // X25519 secret key (base64)
  @override
  String get ephemeralPublicKey; // X25519 public key (base64)
  @override
  String get ephemeralId;
  @override
  String? get nickname;
  @override
  Map<String, String> get peerKeys;

  /// Create a copy of LocalSessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalSessionStateImplCopyWith<_$LocalSessionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
