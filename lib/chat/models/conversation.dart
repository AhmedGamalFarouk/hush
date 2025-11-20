/// Conversation Model
/// Represents a chat conversation (direct, group, or anonymous)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

enum ConversationType {
  @JsonValue('direct')
  direct,
  @JsonValue('group')
  group,
  @JsonValue('anonymous')
  anonymous,
}

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required ConversationType type,
    String? name, // For groups
    String? description, // For groups
    @JsonKey(name: 'avatar_url') String? avatarUrl, // For groups
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'last_message_id') String? lastMessageId,
    @JsonKey(name: 'last_message_preview')
    String? lastMessagePreview, // Encrypted preview
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    Map<String, dynamic>? metadata, // Additional data for anonymous sessions
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

/// Conversation Member
/// Links users to conversations with encrypted keys
@freezed
class ConversationMember with _$ConversationMember {
  const factory ConversationMember({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'encrypted_conversation_key')
    required String
    encryptedKey, // Conversation key encrypted with user's public key
    String? role, // 'owner', 'admin', 'member'
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'last_read_message_id') String? lastReadMessageId,
    @JsonKey(name: 'last_read_at') DateTime? lastReadAt,
  }) = _ConversationMember;

  factory ConversationMember.fromJson(Map<String, dynamic> json) =>
      _$ConversationMemberFromJson(json);
}
