/// Message Service
/// Handles message encryption, sending, receiving, and real-time subscriptions
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_error.dart';
import '../../core/supabase/supabase_provider.dart';
import '../../core/utils/result.dart';
import '../../encryption/services/encryption_service.dart';
import '../models/message.dart';

final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService(supabase: ref.watch(supabaseProvider));
});

class MessageService {
  final SupabaseClient _supabase;
  static const _uuid = Uuid();
  late final EncryptionService _encryptionService;

  MessageService({required SupabaseClient supabase}) : _supabase = supabase {
    // Initialize encryption service
    SodiumInit.init().then((sodium) {
      _encryptionService = EncryptionService(sodium: sodium);
    });
  }

  // ===========================================================================
  // SEND MESSAGE
  // ===========================================================================

  /// Send an encrypted message to a conversation
  ///
  /// Flow:
  /// 1. Encrypt message content with conversation key
  /// 2. Insert encrypted message to Supabase
  /// 3. Return message ID
  Future<Result<Message, AppError>> sendMessage({
    required String conversationId,
    required String content,
    required Uint8List conversationKey,
    MessageType type = MessageType.text,
    String? replyToId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      // Encrypt message content
      final encryptResult = await _encryptionService.encryptMessage(
        plaintext: content,
        key: conversationKey,
      );

      if (encryptResult.isFailure) {
        return Result.failure(encryptResult.errorOrNull!);
      }

      final encrypted = encryptResult.valueOrNull!;
      final messageId = _uuid.v4();
      final now = DateTime.now().toUtc();

      // Create message object
      final message = Message(
        id: messageId,
        conversationId: conversationId,
        senderId: currentUser.id,
        ciphertext: base64Url.encode(encrypted.ciphertext),
        nonce: base64Url.encode(encrypted.nonce),
        type: type,
        status: MessageStatus.sending,
        metadata: metadata,
        replyToId: replyToId,
        createdAt: now,
        updatedAt: now,
      );

      // Insert to Supabase
      await _supabase.from('messages').insert(message.toJson());

      // Update conversation's last message
      await _supabase
          .from('conversations')
          .update({
            'last_message_id': messageId,
            'last_message_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .eq('id', conversationId);

      return Result.success(message.copyWith(status: MessageStatus.sent));
    } on PostgrestException catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Database error: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Send message failed: $e'),
      );
    }
  }

  // ===========================================================================
  // FETCH MESSAGES
  // ===========================================================================

  /// Fetch and decrypt messages for a conversation
  Future<Result<List<DecryptedMessage>, AppError>> fetchMessages({
    required String conversationId,
    required Uint8List conversationKey,
    int limit = 50,
    DateTime? before, // timestamp for pagination
  }) async {
    try {
      PostgrestFilterBuilder query = _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId);

      if (before != null) {
        // Fetch messages before this timestamp (pagination)
        query = query.lt('created_at', before.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final messages = (response as List)
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList();

      // Decrypt messages
      final decryptedMessages = <DecryptedMessage>[];
      for (final message in messages) {
        final decryptResult = await _decryptMessage(
          message: message,
          conversationKey: conversationKey,
        );

        if (decryptResult.isSuccess) {
          decryptedMessages.add(decryptResult.valueOrNull!);
        }
        // Decryption failures are silently skipped to allow partial message display
      }

      return Result.success(decryptedMessages.reversed.toList());
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Fetch messages failed: $e'),
      );
    }
  }

  // ===========================================================================
  // REAL-TIME SUBSCRIPTIONS
  // ===========================================================================

  /// Subscribe to new messages in a conversation
  /// Returns a stream of decrypted messages
  Stream<DecryptedMessage> subscribeToMessages({
    required String conversationId,
    required Uint8List conversationKey,
  }) {
    return _supabase
        .from('messages:conversation_id=eq.$conversationId')
        .stream(primaryKey: ['id'])
        .asyncMap((records) async {
          if (records.isEmpty) return null;

          final messageJson = records.last;
          final message = Message.fromJson(messageJson);

          final decryptResult = await _decryptMessage(
            message: message,
            conversationKey: conversationKey,
          );

          return decryptResult.isSuccess ? decryptResult.valueOrNull : null;
        })
        .where((message) => message != null)
        .cast<DecryptedMessage>();
  }

  // ===========================================================================
  // MESSAGE OPERATIONS
  // ===========================================================================

  /// Delete a message (soft delete)
  Future<Result<void, AppError>> deleteMessage(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', messageId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Delete message failed: $e'),
      );
    }
  }

  /// Mark message as read
  Future<Result<void, AppError>> markAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      await _supabase
          .from('conversation_members')
          .update({
            'last_read_message_id': messageId,
            'last_read_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('conversation_id', conversationId)
          .eq('user_id', currentUser.id);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Mark as read failed: $e'),
      );
    }
  }

  /// Get read status for messages in a conversation
  /// Returns map of messageId -> list of user IDs who have read it
  Future<Result<Map<String, List<String>>, AppError>> getReadStatus({
    required String conversationId,
  }) async {
    try {
      final members = await _supabase
          .from('conversation_members')
          .select('user_id, last_read_message_id')
          .eq('conversation_id', conversationId);

      final readStatus = <String, List<String>>{};

      // Get all messages in conversation
      final messages = await _supabase
          .from('messages')
          .select('id, created_at')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      // For each message, find who has read it
      for (final message in messages) {
        final messageId = message['id'] as String;
        final messageTime = DateTime.parse(message['created_at'] as String);
        readStatus[messageId] = [];

        for (final member in members) {
          final lastReadId = member['last_read_message_id'] as String?;
          if (lastReadId != null) {
            // Find the last read message time
            final lastReadMsg = messages.firstWhere(
              (m) => m['id'] == lastReadId,
              orElse: () => <String, dynamic>{},
            );

            if (lastReadMsg.isNotEmpty) {
              final lastReadTime = DateTime.parse(
                lastReadMsg['created_at'] as String,
              );
              // If last read message is after this message, user has read it
              if (!lastReadTime.isBefore(messageTime)) {
                readStatus[messageId]!.add(member['user_id'] as String);
              }
            }
          }
        }
      }

      return Result.success(readStatus);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Get read status failed: $e'),
      );
    }
  }

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

  /// Decrypt a message
  Future<Result<DecryptedMessage, AppError>> _decryptMessage({
    required Message message,
    required Uint8List conversationKey,
  }) async {
    try {
      final encrypted = EncryptedMessage(
        ciphertext: base64Url.decode(message.ciphertext),
        nonce: base64Url.decode(message.nonce),
        senderBlob: message.senderBlob,
      );

      final decryptResult = await _encryptionService.decryptMessage(
        encrypted: encrypted,
        key: conversationKey,
      );

      if (decryptResult.isFailure) {
        return Result.failure(decryptResult.errorOrNull!);
      }

      final content = decryptResult.valueOrNull!;

      // Fetch sender info (for display)
      String? senderName;
      String? senderAvatar;

      try {
        final profile = await _supabase
            .from('profiles')
            .select('display_name, username, avatar_url')
            .eq('id', message.senderId)
            .single();

        senderName = profile['display_name'] ?? profile['username'];
        senderAvatar = profile['avatar_url'];
      } catch (e) {
        // If profile fetch fails, continue with null values
        senderName = 'Unknown';
      }

      return Result.success(
        DecryptedMessage(
          encrypted: message,
          content: content,
          senderName: senderName,
          senderAvatar: senderAvatar,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.decryption(message: 'Message decryption failed: $e'),
      );
    }
  }
}
