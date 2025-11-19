/// Contact Service
/// Handles contact requests and contact management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_error.dart';
import '../../core/supabase/supabase_provider.dart';
import '../../core/utils/result.dart';
import '../../chat/models/profile.dart';
import '../../chat/services/conversation_service.dart';
import '../models/contact_request.dart';

final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService(
    supabase: ref.watch(supabaseProvider),
    conversationService: ref.watch(conversationServiceProvider),
  );
});

class ContactService {
  final SupabaseClient _supabase;
  final ConversationService _conversationService;
  static const _uuid = Uuid();

  ContactService({
    required SupabaseClient supabase,
    required ConversationService conversationService,
  }) : _supabase = supabase,
       _conversationService = conversationService;

  // ===========================================================================
  // SEARCH USERS
  // ===========================================================================

  /// Search users by username or display name
  Future<Result<List<Profile>, AppError>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Result.success([]);
      }

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      // Search by username or display name (case-insensitive)
      final response = await _supabase
          .from('profiles')
          .select()
          .or('username.ilike.%$query%,display_name.ilike.%$query%')
          .neq('id', currentUser.id) // Exclude current user
          .limit(20);

      final profiles = (response as List)
          .map((json) => Profile.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(profiles);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Search users failed: $e'),
      );
    }
  }

  // ===========================================================================
  // CONTACT REQUESTS
  // ===========================================================================

  /// Send a contact request
  Future<Result<ContactRequest, AppError>> sendContactRequest({
    required String receiverId,
    String? message,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      // Check if request already exists
      final existing = await _supabase
          .from('pending_contacts')
          .select()
          .eq('sender_id', currentUser.id)
          .eq('receiver_id', receiverId)
          .eq('status', 'pending')
          .maybeSingle();

      if (existing != null) {
        return Result.failure(
          AppError.validation(message: 'Contact request already sent'),
        );
      }

      // Create request
      final requestId = _uuid.v4();
      final now = DateTime.now().toUtc();

      final request = ContactRequest(
        id: requestId,
        senderId: currentUser.id,
        receiverId: receiverId,
        status: ContactRequestStatus.pending,
        message: message,
        createdAt: now,
        updatedAt: now,
      );

      await _supabase.from('pending_contacts').insert(request.toJson());

      return Result.success(request);
    } on PostgrestException catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Database error: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Send contact request failed: $e'),
      );
    }
  }

  /// Get pending contact requests (received)
  Future<Result<List<ContactRequest>, AppError>> getPendingRequests() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      final response = await _supabase
          .from('pending_contacts')
          .select()
          .eq('receiver_id', currentUser.id)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final requests = (response as List)
          .map((json) => ContactRequest.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(requests);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Get pending requests failed: $e'),
      );
    }
  }

  /// Accept a contact request
  Future<Result<String, AppError>> acceptContactRequest(
    String requestId,
  ) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      // Get request
      final requestData = await _supabase
          .from('pending_contacts')
          .select()
          .eq('id', requestId)
          .single();

      final request = ContactRequest.fromJson(requestData);

      // Verify user is the receiver
      if (request.receiverId != currentUser.id) {
        return Result.failure(
          AppError.authentication(message: 'Not authorized'),
        );
      }

      // Create conversation
      final conversationResult = await _conversationService
          .createDirectConversation(otherUserId: request.senderId);

      if (conversationResult.isFailure) {
        return Result.failure(conversationResult.errorOrNull!);
      }

      // Update request status
      await _supabase
          .from('pending_contacts')
          .update({
            'status': 'accepted',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', requestId);

      return Result.success(conversationResult.valueOrNull!.conversation.id);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Accept request failed: $e'),
      );
    }
  }

  /// Reject a contact request
  Future<Result<void, AppError>> rejectContactRequest(String requestId) async {
    try {
      await _supabase
          .from('pending_contacts')
          .update({
            'status': 'rejected',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', requestId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Reject request failed: $e'),
      );
    }
  }

  // ===========================================================================
  // CONTACTS
  // ===========================================================================

  /// Get all contacts (users with active conversations)
  Future<Result<List<Profile>, AppError>> getContacts() async {
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

      // Get other members in these conversations
      final otherMembers = await _supabase
          .from('conversation_members')
          .select('user_id')
          .inFilter('conversation_id', conversationIds)
          .neq('user_id', currentUser.id);

      final userIds = (otherMembers as List)
          .map((r) => r['user_id'] as String)
          .toSet() // Remove duplicates
          .toList();

      if (userIds.isEmpty) {
        return const Result.success([]);
      }

      // Fetch profiles
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
        AppError.unknown(message: 'Get contacts failed: $e'),
      );
    }
  }
}
