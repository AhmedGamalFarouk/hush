/// Typing Indicator Service
/// Real-time typing status using Supabase Realtime
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_provider.dart';

/// Provider for typing service
final typingServiceProvider = Provider<TypingService>((ref) {
  return TypingService(supabase: ref.watch(supabaseProvider));
});

class TypingService {
  final SupabaseClient _supabase;
  Timer? _typingTimer;
  final Map<String, RealtimeChannel> _channels = {};

  TypingService({required SupabaseClient supabase}) : _supabase = supabase;

  // ============================================================================
  // TYPING INDICATORS
  // ============================================================================

  /// Start typing in a conversation
  /// Updates typing_status table and auto-clears after 3 seconds
  Future<void> startTyping(String conversationId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Cancel previous timer
      _typingTimer?.cancel();

      // Update typing status
      await _supabase.from('typing_status').upsert({
        'conversation_id': conversationId,
        'user_id': userId,
        'is_typing': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Auto-clear after 3 seconds
      _typingTimer = Timer(const Duration(seconds: 3), () {
        stopTyping(conversationId);
      });
    } catch (e) {
      // Silently fail - typing indicators are non-critical
    }
  }

  /// Stop typing in a conversation
  Future<void> stopTyping(String conversationId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      _typingTimer?.cancel();

      await _supabase
          .from('typing_status')
          .delete()
          .eq('conversation_id', conversationId)
          .eq('user_id', userId);
    } catch (e) {
      // Silently fail
    }
  }

  /// Subscribe to typing indicators for a conversation
  Stream<List<String>> subscribeToTyping(String conversationId) {
    final controller = StreamController<List<String>>();
    final currentUserId = _supabase.auth.currentUser?.id;

    if (currentUserId == null) {
      controller.close();
      return controller.stream;
    }

    // Create channel for this conversation
    final channel = _supabase.channel('typing:$conversationId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'typing_status',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) async {
            // Fetch current typing users
            final response = await _supabase
                .from('typing_status')
                .select('user_id')
                .eq('conversation_id', conversationId)
                .eq('is_typing', true)
                .neq('user_id', currentUserId);

            final typingUsers = (response as List)
                .map((r) => r['user_id'] as String)
                .toList();

            controller.add(typingUsers);
          },
        )
        .subscribe();

    _channels['typing:$conversationId'] = channel;

    controller.onCancel = () {
      channel.unsubscribe();
      _channels.remove('typing:$conversationId');
    };

    return controller.stream;
  }

  /// Clean up resources
  void dispose() {
    _typingTimer?.cancel();
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
  }
}
