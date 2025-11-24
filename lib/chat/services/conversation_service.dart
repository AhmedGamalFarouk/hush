/// Conversation Service
/// Handles creating and managing conversations with encryption
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_error.dart';
import '../../core/supabase/supabase_provider.dart';
import '../../core/utils/result.dart';
import '../../encryption/providers/encryption_provider.dart';
import '../../encryption/providers/secure_key_storage_provider.dart';
import '../../encryption/services/encryption_service.dart';
import '../../encryption/services/secure_key_storage.dart';
import '../models/conversation.dart';
import '../models/profile.dart';

final conversationServiceProvider = Provider<ConversationService>((ref) {
  return ConversationService(
    supabase: ref.watch(supabaseProvider),
    encryptionService: ref.watch(encryptionServiceProvider),
    secureKeyStorage: ref.watch(secureKeyStorageProvider),
  );
});

class ConversationService {
  final SupabaseClient _supabase;
  static const _uuid = Uuid();
  final EncryptionService _encryptionService;
  final SecureKeyStorage _secureKeyStorage;

  ConversationService({
    required SupabaseClient supabase,
    required EncryptionService encryptionService,
    required SecureKeyStorage secureKeyStorage,
  }) : _supabase = supabase,
       _encryptionService = encryptionService,
       _secureKeyStorage = secureKeyStorage;

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
      // Find conversations where both users are members
      final myConversations = await _supabase
          .from('conversation_members')
          .select('conversation_id')
          .eq('user_id', currentUser.id);

      final myConvIds = (myConversations as List)
          .map((e) => e['conversation_id'] as String)
          .toList();

      if (myConvIds.isNotEmpty) {
        final commonMembers = await _supabase
            .from('conversation_members')
            .select('conversation_id')
            .eq('user_id', otherUserId)
            .inFilter('conversation_id', myConvIds);

        final commonConvIds = (commonMembers as List)
            .map((e) => e['conversation_id'] as String)
            .toList();

        if (commonConvIds.isNotEmpty) {
          final existingDirectConv = await _supabase
              .from('conversations')
              .select()
              .inFilter('id', commonConvIds)
              .eq('type', 'direct')
              .maybeSingle();

          if (existingDirectConv != null) {
            return getConversation(existingDirectConv['id'] as String);
          }
        }
      }

      // Generate conversation key
      final keyResult = await _encryptionService.generateRandomKey(
        keyBytes: 32,
      );
      if (keyResult.isFailure) {
        return Result.failure(keyResult.errorOrNull!);
      }
      final conversationKey = keyResult.valueOrNull!;

      // CRITICAL SECURITY FIX: Properly encrypt conversation key with each user's public key
      // Get my keys to encrypt for myself
      final myKeysResult = await _secureKeyStorage.getPublicKeys();
      if (myKeysResult.isFailure) {
        return Result.failure(myKeysResult.errorOrNull!);
      }
      final myPublicKey = myKeysResult.valueOrNull!.kxPublicKey;

      // Get other user's public key
      final otherUserProfile = await _supabase
          .from('profiles')
          .select('public_key')
          .eq('id', otherUserId)
          .single();

      if (otherUserProfile['public_key'] == null) {
        return Result.failure(
          AppError.encryption(message: 'Other user has no public key'),
        );
      }

      final otherUserPublicKey = base64Url.decode(
        otherUserProfile['public_key'] as String,
      );

      // Encrypt conversation key for me using sealed box
      final encryptForMeResult = await _encryptionService.sealBox(
        plaintext: conversationKey,
        recipientPublicKey: myPublicKey,
      );
      if (encryptForMeResult.isFailure) {
        return Result.failure(encryptForMeResult.errorOrNull!);
      }

      // Encrypt conversation key for other user using sealed box
      final encryptForOtherResult = await _encryptionService.sealBox(
        plaintext: conversationKey,
        recipientPublicKey: otherUserPublicKey,
      );
      if (encryptForOtherResult.isFailure) {
        return Result.failure(encryptForOtherResult.errorOrNull!);
      }

      final encryptedKeyForMe = base64Url.encode(
        encryptForMeResult.valueOrNull!,
      );
      final encryptedKeyForOther = base64Url.encode(
        encryptForOtherResult.valueOrNull!,
      );

      // Create conversation
      final conversationId = _uuid.v4();
      final now = DateTime.now().toUtc();

      try {
        await _supabase.from('conversations').insert({
          'id': conversationId,
          'type': 'direct',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
        debugPrint('Created conversation: $conversationId');
      } catch (e) {
        debugPrint('Error creating conversation: $e');
        rethrow;
      }

      // Add self first (to satisfy RLS for adding others)
      try {
        await _supabase.from('conversation_members').insert({
          'id': _uuid.v4(),
          'conversation_id': conversationId,
          'user_id': currentUser.id,
          'encrypted_conversation_key': encryptedKeyForMe,
          'role': 'member',
          'joined_at': now.toIso8601String(),
        });
        debugPrint('Added current user to conversation: ${currentUser.id}');
      } catch (e) {
        debugPrint('Error adding current user to conversation: $e');
        rethrow;
      }

      // Add other user
      try {
        await _supabase.from('conversation_members').insert({
          'id': _uuid.v4(),
          'conversation_id': conversationId,
          'user_id': otherUserId,
          'encrypted_conversation_key': encryptedKeyForOther,
          'role': 'member',
          'joined_at': now.toIso8601String(),
        });
        debugPrint('Added other user to conversation: $otherUserId');
      } catch (e) {
        debugPrint('Error adding other user to conversation: $e');
        rethrow;
      }

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
          .select('conversation_id, encrypted_conversation_key')
          .eq('user_id', currentUser.id);

      final conversationIds = (memberRecords as List)
          .map((r) => r['conversation_id'] as String)
          .toList();

      if (conversationIds.isEmpty) {
        return const Result.success([]);
      }

      final keyMap = {
        for (var r in memberRecords)
          r['conversation_id'] as String:
              r['encrypted_conversation_key'] as String,
      };

      // Fetch conversations
      final response = await _supabase
          .from('conversations')
          .select()
          .inFilter('id', conversationIds)
          .order('updated_at', ascending: false);

      var conversations = await Future.wait(
        (response as List).map((json) async {
          var conversation = Conversation.fromJson(
            json as Map<String, dynamic>,
          );

          // Decrypt preview if exists
          if (conversation.lastMessagePreview != null) {
            try {
              final encryptedKey = keyMap[conversation.id];
              if (encryptedKey != null) {
                // CRITICAL SECURITY FIX: Decrypt conversation key with user's private key
                final myKeysResult = await _secureKeyStorage.retrieveKeyPairs(
                  password:
                      '', // Password should be cached in memory from login
                );

                if (myKeysResult.isSuccess) {
                  final myKeys = myKeysResult.valueOrNull!;

                  // Decrypt the conversation key using sealed box
                  final decryptKeyResult = await _encryptionService
                      .openSealedBox(
                        ciphertext: base64Url.decode(encryptedKey),
                        myPublicKey: myKeys.kxKeyPair.publicKey,
                        mySecretKey: myKeys.kxKeyPair.secretKey,
                      );

                  if (decryptKeyResult.isSuccess) {
                    final conversationKey = decryptKeyResult.valueOrNull!;

                    final encryptedPreviewJson = jsonDecode(
                      conversation.lastMessagePreview!,
                    );
                    final encryptedPreview = EncryptedMessage.fromJson(
                      encryptedPreviewJson,
                    );

                    final decryptResult = await _encryptionService
                        .decryptMessage(
                          encrypted: encryptedPreview,
                          key: Uint8List.fromList(conversationKey),
                        );

                    if (decryptResult.isSuccess) {
                      conversation = conversation.copyWith(
                        lastMessagePreview: decryptResult.valueOrNull,
                      );
                    }
                  }
                }
              }
            } catch (e) {
              debugPrint(
                'Failed to decrypt preview for ${conversation.id}: $e',
              );
              // Keep encrypted or set to "Encrypted message"
              conversation = conversation.copyWith(
                lastMessagePreview: 'Encrypted message',
              );
            }
          }
          return conversation;
        }),
      );

      // Populate names for direct conversations
      final directConvIds = conversations
          .where((c) => c.type == ConversationType.direct)
          .map((c) => c.id)
          .toList();

      if (directConvIds.isNotEmpty) {
        // Fetch other members for these conversations
        final otherMembers = await _supabase
            .from('conversation_members')
            .select('conversation_id, user_id')
            .inFilter('conversation_id', directConvIds)
            .neq('user_id', currentUser.id);

        final userIds = (otherMembers as List)
            .map((m) => m['user_id'] as String)
            .toSet() // Unique user IDs
            .toList();

        if (userIds.isNotEmpty) {
          final profilesResponse = await _supabase
              .from('profiles')
              .select()
              .inFilter('id', userIds);

          final profiles = (profilesResponse as List).map(
            (json) => Profile.fromJson(json as Map<String, dynamic>),
          );

          final profileMap = {for (var p in profiles) p.id: p};
          final convToUserMap = {
            for (var m in otherMembers)
              m['conversation_id'] as String: m['user_id'] as String,
          };

          conversations = conversations.map((c) {
            if (c.type == ConversationType.direct) {
              final otherUserId = convToUserMap[c.id];
              if (otherUserId != null) {
                final profile = profileMap[otherUserId];
                if (profile != null) {
                  return c.copyWith(
                    name: profile.displayName ?? profile.username,
                  );
                }
              }
            }
            return c;
          }).toList();
        }
      }

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
          .select('encrypted_conversation_key')
          .eq('conversation_id', conversationId)
          .eq('user_id', currentUser.id)
          .single();

      // CRITICAL SECURITY FIX: Decrypt the key with user's secret key
      final encryptedKey = memberData['encrypted_conversation_key'] as String;

      // Get user's keys
      final myKeysResult = await _secureKeyStorage.retrieveKeyPairs(
        password: '', // Should be cached from login
      );

      if (myKeysResult.isFailure) {
        return Result.failure(
          AppError.encryption(message: 'Failed to retrieve user keys'),
        );
      }

      final myKeys = myKeysResult.valueOrNull!;

      // Decrypt conversation key using sealed box
      final decryptKeyResult = await _encryptionService.openSealedBox(
        ciphertext: base64Url.decode(encryptedKey),
        myPublicKey: myKeys.kxKeyPair.publicKey,
        mySecretKey: myKeys.kxKeyPair.secretKey,
      );

      if (decryptKeyResult.isFailure) {
        return Result.failure(decryptKeyResult.errorOrNull!);
      }

      final conversationKey = decryptKeyResult.valueOrNull!;

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
