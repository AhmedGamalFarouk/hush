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
    String? avatarUrl, // For groups
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageId,
    String? lastMessagePreview, // Encrypted preview
    DateTime? lastMessageAt,
    @Default(0) int unreadCount,
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
    required String conversationId,
    required String userId,
    required String
    encryptedKey, // Conversation key encrypted with user's public key
    String? role, // 'owner', 'admin', 'member'
    DateTime? joinedAt,
    String? lastReadMessageId,
    DateTime? lastReadAt,
  }) = _ConversationMember;

  factory ConversationMember.fromJson(Map<String, dynamic> json) =>
      _$ConversationMemberFromJson(json);
}
