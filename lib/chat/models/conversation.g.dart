// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      type: $enumDecode(_$ConversationTypeEnumMap, json['type']),
      name: json['name'] as String?,
      description: json['description'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      lastMessageId: json['last_message_id'] as String?,
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ConversationTypeEnumMap[instance.type]!,
      'name': instance.name,
      'description': instance.description,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'last_message_id': instance.lastMessageId,
      'last_message_preview': instance.lastMessagePreview,
      'last_message_at': instance.lastMessageAt?.toIso8601String(),
      'unread_count': instance.unreadCount,
      'metadata': instance.metadata,
    };

const _$ConversationTypeEnumMap = {
  ConversationType.direct: 'direct',
  ConversationType.group: 'group',
  ConversationType.anonymous: 'anonymous',
};

_$ConversationMemberImpl _$$ConversationMemberImplFromJson(
  Map<String, dynamic> json,
) => _$ConversationMemberImpl(
  id: json['id'] as String,
  conversationId: json['conversation_id'] as String,
  userId: json['user_id'] as String,
  encryptedKey: json['encrypted_conversation_key'] as String,
  role: json['role'] as String?,
  joinedAt: json['joined_at'] == null
      ? null
      : DateTime.parse(json['joined_at'] as String),
  lastReadMessageId: json['last_read_message_id'] as String?,
  lastReadAt: json['last_read_at'] == null
      ? null
      : DateTime.parse(json['last_read_at'] as String),
);

Map<String, dynamic> _$$ConversationMemberImplToJson(
  _$ConversationMemberImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'conversation_id': instance.conversationId,
  'user_id': instance.userId,
  'encrypted_conversation_key': instance.encryptedKey,
  'role': instance.role,
  'joined_at': instance.joinedAt?.toIso8601String(),
  'last_read_message_id': instance.lastReadMessageId,
  'last_read_at': instance.lastReadAt?.toIso8601String(),
};
