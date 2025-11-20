// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return _Conversation.fromJson(json);
}

/// @nodoc
mixin _$Conversation {
  String get id => throw _privateConstructorUsedError;
  ConversationType get type => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError; // For groups
  String? get description => throw _privateConstructorUsedError; // For groups
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError; // For groups
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_id')
  String? get lastMessageId => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_preview')
  String? get lastMessagePreview => throw _privateConstructorUsedError; // Encrypted preview
  @JsonKey(name: 'last_message_at')
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_count')
  int get unreadCount => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
    Conversation value,
    $Res Function(Conversation) then,
  ) = _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call({
    String id,
    ConversationType type,
    String? name,
    String? description,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'last_message_id') String? lastMessageId,
    @JsonKey(name: 'last_message_preview') String? lastMessagePreview,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count') int unreadCount,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? avatarUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastMessageId = freezed,
    Object? lastMessagePreview = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCount = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ConversationType,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastMessageId: freezed == lastMessageId
                ? _value.lastMessageId
                : lastMessageId // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMessagePreview: freezed == lastMessagePreview
                ? _value.lastMessagePreview
                : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMessageAt: freezed == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            unreadCount: null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                      as int,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
    _$ConversationImpl value,
    $Res Function(_$ConversationImpl) then,
  ) = __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    ConversationType type,
    String? name,
    String? description,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'last_message_id') String? lastMessageId,
    @JsonKey(name: 'last_message_preview') String? lastMessagePreview,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count') int unreadCount,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
    _$ConversationImpl _value,
    $Res Function(_$ConversationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? avatarUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastMessageId = freezed,
    Object? lastMessagePreview = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCount = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ConversationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ConversationType,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastMessageId: freezed == lastMessageId
            ? _value.lastMessageId
            : lastMessageId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMessagePreview: freezed == lastMessagePreview
            ? _value.lastMessagePreview
            : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMessageAt: freezed == lastMessageAt
            ? _value.lastMessageAt
            : lastMessageAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        unreadCount: null == unreadCount
            ? _value.unreadCount
            : unreadCount // ignore: cast_nullable_to_non_nullable
                  as int,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationImpl implements _Conversation {
  const _$ConversationImpl({
    required this.id,
    required this.type,
    this.name,
    this.description,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'last_message_id') this.lastMessageId,
    @JsonKey(name: 'last_message_preview') this.lastMessagePreview,
    @JsonKey(name: 'last_message_at') this.lastMessageAt,
    @JsonKey(name: 'unread_count') this.unreadCount = 0,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$ConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationImplFromJson(json);

  @override
  final String id;
  @override
  final ConversationType type;
  @override
  final String? name;
  // For groups
  @override
  final String? description;
  // For groups
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  // For groups
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'last_message_id')
  final String? lastMessageId;
  @override
  @JsonKey(name: 'last_message_preview')
  final String? lastMessagePreview;
  // Encrypted preview
  @override
  @JsonKey(name: 'last_message_at')
  final DateTime? lastMessageAt;
  @override
  @JsonKey(name: 'unread_count')
  final int unreadCount;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Conversation(id: $id, type: $type, name: $name, description: $description, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt, lastMessageId: $lastMessageId, lastMessagePreview: $lastMessagePreview, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastMessageId, lastMessageId) ||
                other.lastMessageId == lastMessageId) &&
            (identical(other.lastMessagePreview, lastMessagePreview) ||
                other.lastMessagePreview == lastMessagePreview) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    name,
    description,
    avatarUrl,
    createdAt,
    updatedAt,
    lastMessageId,
    lastMessagePreview,
    lastMessageAt,
    unreadCount,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationImplToJson(this);
  }
}

abstract class _Conversation implements Conversation {
  const factory _Conversation({
    required final String id,
    required final ConversationType type,
    final String? name,
    final String? description,
    @JsonKey(name: 'avatar_url') final String? avatarUrl,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    @JsonKey(name: 'last_message_id') final String? lastMessageId,
    @JsonKey(name: 'last_message_preview') final String? lastMessagePreview,
    @JsonKey(name: 'last_message_at') final DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count') final int unreadCount,
    final Map<String, dynamic>? metadata,
  }) = _$ConversationImpl;

  factory _Conversation.fromJson(Map<String, dynamic> json) =
      _$ConversationImpl.fromJson;

  @override
  String get id;
  @override
  ConversationType get type;
  @override
  String? get name; // For groups
  @override
  String? get description; // For groups
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl; // For groups
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'last_message_id')
  String? get lastMessageId;
  @override
  @JsonKey(name: 'last_message_preview')
  String? get lastMessagePreview; // Encrypted preview
  @override
  @JsonKey(name: 'last_message_at')
  DateTime? get lastMessageAt;
  @override
  @JsonKey(name: 'unread_count')
  int get unreadCount;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConversationMember _$ConversationMemberFromJson(Map<String, dynamic> json) {
  return _ConversationMember.fromJson(json);
}

/// @nodoc
mixin _$ConversationMember {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'conversation_id')
  String get conversationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'encrypted_conversation_key')
  String get encryptedKey => throw _privateConstructorUsedError; // Conversation key encrypted with user's public key
  String? get role =>
      throw _privateConstructorUsedError; // 'owner', 'admin', 'member'
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_read_message_id')
  String? get lastReadMessageId => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_read_at')
  DateTime? get lastReadAt => throw _privateConstructorUsedError;

  /// Serializes this ConversationMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConversationMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationMemberCopyWith<ConversationMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationMemberCopyWith<$Res> {
  factory $ConversationMemberCopyWith(
    ConversationMember value,
    $Res Function(ConversationMember) then,
  ) = _$ConversationMemberCopyWithImpl<$Res, ConversationMember>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'conversation_id') String conversationId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'encrypted_conversation_key') String encryptedKey,
    String? role,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'last_read_message_id') String? lastReadMessageId,
    @JsonKey(name: 'last_read_at') DateTime? lastReadAt,
  });
}

/// @nodoc
class _$ConversationMemberCopyWithImpl<$Res, $Val extends ConversationMember>
    implements $ConversationMemberCopyWith<$Res> {
  _$ConversationMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? userId = null,
    Object? encryptedKey = null,
    Object? role = freezed,
    Object? joinedAt = freezed,
    Object? lastReadMessageId = freezed,
    Object? lastReadAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            conversationId: null == conversationId
                ? _value.conversationId
                : conversationId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            encryptedKey: null == encryptedKey
                ? _value.encryptedKey
                : encryptedKey // ignore: cast_nullable_to_non_nullable
                      as String,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
            joinedAt: freezed == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastReadMessageId: freezed == lastReadMessageId
                ? _value.lastReadMessageId
                : lastReadMessageId // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastReadAt: freezed == lastReadAt
                ? _value.lastReadAt
                : lastReadAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversationMemberImplCopyWith<$Res>
    implements $ConversationMemberCopyWith<$Res> {
  factory _$$ConversationMemberImplCopyWith(
    _$ConversationMemberImpl value,
    $Res Function(_$ConversationMemberImpl) then,
  ) = __$$ConversationMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'conversation_id') String conversationId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'encrypted_conversation_key') String encryptedKey,
    String? role,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'last_read_message_id') String? lastReadMessageId,
    @JsonKey(name: 'last_read_at') DateTime? lastReadAt,
  });
}

/// @nodoc
class __$$ConversationMemberImplCopyWithImpl<$Res>
    extends _$ConversationMemberCopyWithImpl<$Res, _$ConversationMemberImpl>
    implements _$$ConversationMemberImplCopyWith<$Res> {
  __$$ConversationMemberImplCopyWithImpl(
    _$ConversationMemberImpl _value,
    $Res Function(_$ConversationMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? userId = null,
    Object? encryptedKey = null,
    Object? role = freezed,
    Object? joinedAt = freezed,
    Object? lastReadMessageId = freezed,
    Object? lastReadAt = freezed,
  }) {
    return _then(
      _$ConversationMemberImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        conversationId: null == conversationId
            ? _value.conversationId
            : conversationId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        encryptedKey: null == encryptedKey
            ? _value.encryptedKey
            : encryptedKey // ignore: cast_nullable_to_non_nullable
                  as String,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
        joinedAt: freezed == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastReadMessageId: freezed == lastReadMessageId
            ? _value.lastReadMessageId
            : lastReadMessageId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastReadAt: freezed == lastReadAt
            ? _value.lastReadAt
            : lastReadAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationMemberImpl implements _ConversationMember {
  const _$ConversationMemberImpl({
    required this.id,
    @JsonKey(name: 'conversation_id') required this.conversationId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'encrypted_conversation_key') required this.encryptedKey,
    this.role,
    @JsonKey(name: 'joined_at') this.joinedAt,
    @JsonKey(name: 'last_read_message_id') this.lastReadMessageId,
    @JsonKey(name: 'last_read_at') this.lastReadAt,
  });

  factory _$ConversationMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationMemberImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'conversation_id')
  final String conversationId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'encrypted_conversation_key')
  final String encryptedKey;
  // Conversation key encrypted with user's public key
  @override
  final String? role;
  // 'owner', 'admin', 'member'
  @override
  @JsonKey(name: 'joined_at')
  final DateTime? joinedAt;
  @override
  @JsonKey(name: 'last_read_message_id')
  final String? lastReadMessageId;
  @override
  @JsonKey(name: 'last_read_at')
  final DateTime? lastReadAt;

  @override
  String toString() {
    return 'ConversationMember(id: $id, conversationId: $conversationId, userId: $userId, encryptedKey: $encryptedKey, role: $role, joinedAt: $joinedAt, lastReadMessageId: $lastReadMessageId, lastReadAt: $lastReadAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.encryptedKey, encryptedKey) ||
                other.encryptedKey == encryptedKey) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.lastReadMessageId, lastReadMessageId) ||
                other.lastReadMessageId == lastReadMessageId) &&
            (identical(other.lastReadAt, lastReadAt) ||
                other.lastReadAt == lastReadAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    conversationId,
    userId,
    encryptedKey,
    role,
    joinedAt,
    lastReadMessageId,
    lastReadAt,
  );

  /// Create a copy of ConversationMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationMemberImplCopyWith<_$ConversationMemberImpl> get copyWith =>
      __$$ConversationMemberImplCopyWithImpl<_$ConversationMemberImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationMemberImplToJson(this);
  }
}

abstract class _ConversationMember implements ConversationMember {
  const factory _ConversationMember({
    required final String id,
    @JsonKey(name: 'conversation_id') required final String conversationId,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'encrypted_conversation_key')
    required final String encryptedKey,
    final String? role,
    @JsonKey(name: 'joined_at') final DateTime? joinedAt,
    @JsonKey(name: 'last_read_message_id') final String? lastReadMessageId,
    @JsonKey(name: 'last_read_at') final DateTime? lastReadAt,
  }) = _$ConversationMemberImpl;

  factory _ConversationMember.fromJson(Map<String, dynamic> json) =
      _$ConversationMemberImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'conversation_id')
  String get conversationId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'encrypted_conversation_key')
  String get encryptedKey; // Conversation key encrypted with user's public key
  @override
  String? get role; // 'owner', 'admin', 'member'
  @override
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt;
  @override
  @JsonKey(name: 'last_read_message_id')
  String? get lastReadMessageId;
  @override
  @JsonKey(name: 'last_read_at')
  DateTime? get lastReadAt;

  /// Create a copy of ConversationMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationMemberImplCopyWith<_$ConversationMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
