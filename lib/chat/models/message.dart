/// Message Model
/// Encrypted message with metadata
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('file')
  file,
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
  @JsonValue('system')
  system,
}

enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String ciphertext, // Encrypted message content (base64url)
    required String nonce, // Encryption nonce (base64url)
    @JsonKey(name: 'sender_blob')
    String? senderBlob, // Encrypted sender info for anonymous chats
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.sending) MessageStatus status,
    Map<String, dynamic>?
    metadata, // For media: encrypted URLs, thumbnails, etc.
    @JsonKey(name: 'reply_to_id')
    String? replyToId, // Message ID being replied to
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

/// Local decrypted message for display
class DecryptedMessage {
  final Message encrypted;
  final String content;
  final String? senderName;
  final String? senderAvatar;

  const DecryptedMessage({
    required this.encrypted,
    required this.content,
    this.senderName,
    this.senderAvatar,
  });

  String get id => encrypted.id;
  String get conversationId => encrypted.conversationId;
  String get senderId => encrypted.senderId;
  MessageType get type => encrypted.type;
  MessageStatus get status => encrypted.status;
  Map<String, dynamic>? get metadata => encrypted.metadata;
  String? get replyToId => encrypted.replyToId;
  DateTime? get createdAt => encrypted.createdAt;
  DateTime? get updatedAt => encrypted.updatedAt;
}
