/// Conversation Providers
/// Riverpod state management for conversations
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/profile.dart';
import '../services/conversation_service.dart';
import '../services/message_service.dart';

part 'conversation_providers.g.dart';

// ===========================================================================
// CONVERSATION LIST
// ===========================================================================

/// Provider for list of all conversations
@riverpod
class ConversationList extends _$ConversationList {
  @override
  Future<List<Conversation>> build() async {
    final service = ref.watch(conversationServiceProvider);
    final result = await service.getConversations();

    if (result.isFailure) {
      throw Exception(
        result.errorOrNull?.message ?? 'Failed to load conversations',
      );
    }

    return result.valueOrNull ?? [];
  }

  /// Refresh conversation list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(conversationServiceProvider);
      final result = await service.getConversations();

      if (result.isFailure) {
        throw Exception(
          result.errorOrNull?.message ?? 'Failed to load conversations',
        );
      }

      return result.valueOrNull ?? [];
    });
  }

  /// Create a new direct conversation
  Future<String?> createDirectConversation(String otherUserId) async {
    final service = ref.read(conversationServiceProvider);
    final result = await service.createDirectConversation(
      otherUserId: otherUserId,
    );

    if (result.isSuccess) {
      // Refresh list
      await refresh();
      return result.valueOrNull?.conversation.id;
    }

    return null;
  }
}

// ===========================================================================
// CONVERSATION DETAILS
// ===========================================================================

/// Provider for a specific conversation with its key
@riverpod
class ConversationDetails extends _$ConversationDetails {
  @override
  Future<ConversationWithKey> build(String conversationId) async {
    final service = ref.watch(conversationServiceProvider);
    final result = await service.getConversation(conversationId);

    if (result.isFailure) {
      throw Exception(
        result.errorOrNull?.message ?? 'Failed to load conversation',
      );
    }

    return result.valueOrNull!;
  }
}

// ===========================================================================
// CONVERSATION MEMBERS
// ===========================================================================

/// Provider for conversation members
@riverpod
class ConversationMembers extends _$ConversationMembers {
  @override
  Future<List<Profile>> build(String conversationId) async {
    final service = ref.watch(conversationServiceProvider);
    final result = await service.getConversationMembers(conversationId);

    if (result.isFailure) {
      throw Exception(result.errorOrNull?.message ?? 'Failed to load members');
    }

    return result.valueOrNull ?? [];
  }
}

// ===========================================================================
// MESSAGES
// ===========================================================================

/// Provider for messages in a conversation
@riverpod
class ConversationMessages extends _$ConversationMessages {
  @override
  Future<List<DecryptedMessage>> build(String conversationId) async {
    final messageService = ref.watch(messageServiceProvider);

    // Get conversation key first
    final conversationDetails = await ref.watch(
      conversationDetailsProvider(conversationId).future,
    );

    final result = await messageService.fetchMessages(
      conversationId: conversationId,
      conversationKey: conversationDetails.key,
    );

    if (result.isFailure) {
      throw Exception(result.errorOrNull?.message ?? 'Failed to load messages');
    }

    return result.valueOrNull ?? [];
  }

  /// Send a new message
  Future<bool> sendMessage(String content, {String? replyToId}) async {
    final messageService = ref.read(messageServiceProvider);

    // Get conversation key
    final conversationDetails = await ref.read(
      conversationDetailsProvider(conversationId).future,
    );

    final result = await messageService.sendMessage(
      conversationId: conversationId,
      content: content,
      conversationKey: conversationDetails.key,
      replyToId: replyToId,
    );

    if (result.isSuccess) {
      // Refresh messages
      ref.invalidateSelf();
      return true;
    }

    return false;
  }

  /// Load more messages (pagination)
  Future<void> loadMore() async {
    final currentMessages = state.valueOrNull ?? [];
    if (currentMessages.isEmpty) return;

    final oldestMessage = currentMessages.first;
    final messageService = ref.read(messageServiceProvider);

    final conversationDetails = await ref.read(
      conversationDetailsProvider(conversationId).future,
    );

    final result = await messageService.fetchMessages(
      conversationId: conversationId,
      conversationKey: conversationDetails.key,
      before: oldestMessage.createdAt,
      limit: 30,
    );

    if (result.isSuccess) {
      final olderMessages = result.valueOrNull ?? [];
      state = AsyncValue.data([...olderMessages, ...currentMessages]);
    }
  }

  /// Mark message as read
  Future<void> markAsRead(String messageId) async {
    final messageService = ref.read(messageServiceProvider);
    await messageService.markAsRead(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    final messageService = ref.read(messageServiceProvider);
    final result = await messageService.deleteMessage(messageId);

    if (result.isSuccess) {
      ref.invalidateSelf();
    }
  }
}

// ===========================================================================
// REAL-TIME MESSAGE STREAM
// ===========================================================================

/// Provider for real-time message stream
@riverpod
Stream<DecryptedMessage> messageStream(Ref ref, String conversationId) async* {
  final messageService = ref.watch(messageServiceProvider);

  // Get conversation key
  final conversationDetails = await ref.watch(
    conversationDetailsProvider(conversationId).future,
  );

  yield* messageService.subscribeToMessages(
    conversationId: conversationId,
    conversationKey: conversationDetails.key,
  );
}
