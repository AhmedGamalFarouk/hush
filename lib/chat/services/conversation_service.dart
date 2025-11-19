/// Conversation Service
/// Handles creating and managing conversations with encryption
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
import '../models/conversation.dart';
import '../models/profile.dart';

final conversationServiceProvider = Provider<ConversationService>((ref) {
  return ConversationService(supabase: ref.watch(supabaseProvider));
});

class ConversationService {
  final SupabaseClient _supabase;
  static const _uuid = Uuid();
  late final EncryptionService _encryptionService;

  ConversationService({required SupabaseClient supabase})
    : _supabase = supabase {
    // Initialize encryption service
    SodiumInit.init().then((sodium) {
      _encryptionService = EncryptionService(sodium: sodium);
    });
  }

  // ===========================================================================
  // CREATE DIRECT CONVERSATION
  // ===========================================================================

  /// Create a direct conversation with another user
  ///
  /// Flow:
  /// 1. Generate conversation key
  /// 2. Perform DH key exchange with other user
  /// 3. Encrypt conversation key for both users
  /// 4. Create conversation and member records
  Future<Result<ConversationWithKey, AppError>> createDirectConversation({
    required String otherUserId,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      // Check if conversation already exists
      // TODO: Implement better check for existing conversations
      // For now, skip this check and create new conversation

      // TODO: Fetch other user's public key and implement proper encryption
      // For now, using simplified key management

      // Generate conversation key
      final keyResult = await _encryptionService.generateRandomKey(
        keyBytes: 32,
      );
      if (keyResult.isFailure) {
        return Result.failure(keyResult.errorOrNull!);
      }
      final conversationKey = keyResult.valueOrNull!;

      // TODO: Encrypt conversation key with each user's public key
      // For now, using a simplified approach - store base64 encoded
      // In production: use box_seal to encrypt with public key
      final encryptedKeyForMe = base64Url.encode(conversationKey);
      final encryptedKeyForOther = base64Url.encode(conversationKey);

      // Create conversation
      final conversationId = _uuid.v4();
      final now = DateTime.now().toUtc();

      await _supabase.from('conversations').insert({
        'id': conversationId,
        'type': 'direct',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Add members
      await _supabase.from('conversation_members').insert([
        {
          'id': _uuid.v4(),
          'conversation_id': conversationId,
          'user_id': currentUser.id,
          'encrypted_key': encryptedKeyForMe,
          'role': 'member',
          'joined_at': now.toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'conversation_id': conversationId,
          'user_id': otherUserId,
          'encrypted_key': encryptedKeyForOther,
          'role': 'member',
          'joined_at': now.toIso8601String(),
        },
      ]);

      final conversation = Conversation(
        id: conversationId,
        type: ConversationType.direct,
        createdAt: now,
        updatedAt: now,
      );

      return Result.success(
        ConversationWithKey(conversation: conversation, key: conversationKey),
      );
    } on PostgrestException catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Database error: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Create conversation failed: $e'),
      );
    }
  }

  // ===========================================================================
  // FETCH CONVERSATIONS
  // ===========================================================================

  /// Get all conversations for current user
  Future<Result<List<Conversation>, AppError>> getConversations() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      // Get conversation IDs user is part of
      final memberRecords = await _supabase
          .from('conversation_members')
          .select('conversation_id')
          .eq('user_id', currentUser.id);

      final conversationIds = (memberRecords as List)
          .map((r) => r['conversation_id'] as String)
          .toList();

      if (conversationIds.isEmpty) {
        return const Result.success([]);
      }

      // Fetch conversations
      final response = await _supabase
          .from('conversations')
          .select()
          .inFilter('id', conversationIds)
          .order('updated_at', ascending: false);

      final conversations = (response as List)
          .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(conversations);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Fetch conversations failed: $e'),
      );
    }
  }

  /// Get a specific conversation with its encryption key
  Future<Result<ConversationWithKey, AppError>> getConversation(
    String conversationId,
  ) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      // Fetch conversation
      final convData = await _supabase
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .single();

      final conversation = Conversation.fromJson(convData);

      // Fetch encrypted key for this user
      final memberData = await _supabase
          .from('conversation_members')
          .select('encrypted_key')
          .eq('conversation_id', conversationId)
          .eq('user_id', currentUser.id)
          .single();

      // TODO: Decrypt the key with user's secret key
      // For now, using simplified approach
      final encryptedKey = memberData['encrypted_key'] as String;
      final conversationKey = base64Url.decode(encryptedKey);

      return Result.success(
        ConversationWithKey(
          conversation: conversation,
          key: Uint8List.fromList(conversationKey),
        ),
      );
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Get conversation failed: $e'),
      );
    }
  }

  // ===========================================================================
  // CONVERSATION MEMBERS
  // ===========================================================================

  /// Get members of a conversation with their profiles
  Future<Result<List<Profile>, AppError>> getConversationMembers(
    String conversationId,
  ) async {
    try {
      final memberRecords = await _supabase
          .from('conversation_members')
          .select('user_id')
          .eq('conversation_id', conversationId);

      final userIds = (memberRecords as List)
          .map((r) => r['user_id'] as String)
          .toList();

      if (userIds.isEmpty) {
        return const Result.success([]);
      }

      final response = await _supabase
          .from('profiles')
          .select()
          .inFilter('id', userIds);

      final profiles = (response as List)
          .map((json) => Profile.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(profiles);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Get members failed: $e'),
      );
    }
  }

  // ===========================================================================
  // DELETE CONVERSATION
  // ===========================================================================

  /// Leave/delete a conversation
  Future<Result<void, AppError>> deleteConversation(
    String conversationId,
  ) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      // Remove user from conversation_members
      await _supabase
          .from('conversation_members')
          .delete()
          .eq('conversation_id', conversationId)
          .eq('user_id', currentUser.id);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Delete conversation failed: $e'),
      );
    }
  }
}

/// Conversation with its encryption key
class ConversationWithKey {
  final Conversation conversation;
  final Uint8List key;

  const ConversationWithKey({required this.conversation, required this.key});
}
