/// Reaction Service
/// Handle message reactions (emoji reactions)
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_error.dart';
import '../../core/supabase/supabase_provider.dart';
import '../../core/utils/result.dart';
import '../models/message_reaction.dart';

final reactionServiceProvider = Provider<ReactionService>((ref) {
  return ReactionService(supabase: ref.watch(supabaseProvider));
});

class ReactionService {
  final SupabaseClient _supabase;
  static const _uuid = Uuid();

  ReactionService({required SupabaseClient supabase}) : _supabase = supabase;

  /// Add a reaction to a message
  Future<Result<void, AppError>> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      // Check if user already reacted with this emoji
      final existing = await _supabase
          .from('message_reactions')
          .select()
          .eq('message_id', messageId)
          .eq('user_id', currentUser.id)
          .eq('emoji', emoji)
          .maybeSingle();

      if (existing != null) {
        // Already reacted with this emoji, remove it (toggle)
        return removeReaction(messageId: messageId, emoji: emoji);
      }

      // Add new reaction
      await _supabase.from('message_reactions').insert({
        'id': _uuid.v4(),
        'message_id': messageId,
        'user_id': currentUser.id,
        'emoji': emoji,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Add reaction failed: $e'),
      );
    }
  }

  /// Remove a reaction from a message
  Future<Result<void, AppError>> removeReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(
          AppError.authentication(message: 'User not authenticated'),
        );
      }

      await _supabase
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', currentUser.id)
          .eq('emoji', emoji);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Remove reaction failed: $e'),
      );
    }
  }

  /// Get reactions for a message
  Future<Result<List<ReactionSummary>, AppError>> getReactions({
    required String messageId,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;

      final response = await _supabase
          .from('message_reactions')
          .select()
          .eq('message_id', messageId);

      final reactions = (response as List)
          .map((json) => MessageReaction.fromJson(json))
          .toList();

      // Group by emoji
      final grouped = <String, List<MessageReaction>>{};
      for (final reaction in reactions) {
        grouped.putIfAbsent(reaction.emoji, () => []).add(reaction);
      }

      // Create summaries
      final summaries = grouped.entries.map((entry) {
        final userIds = entry.value.map((r) => r.userId).toList();
        return ReactionSummary(
          emoji: entry.key,
          count: entry.value.length,
          userIds: userIds,
          reactedByMe: currentUser != null && userIds.contains(currentUser.id),
        );
      }).toList();

      // Sort by count descending
      summaries.sort((a, b) => b.count.compareTo(a.count));

      return Result.success(summaries);
    } catch (e) {
      return Result.failure(
        AppError.unknown(message: 'Get reactions failed: $e'),
      );
    }
  }

  /// Subscribe to reaction updates for a message
  Stream<List<ReactionSummary>> subscribeToReactions(String messageId) {
    final controller = StreamController<List<ReactionSummary>>.broadcast();

    final channel = _supabase.channel('reactions:$messageId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'message_reactions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'message_id',
            value: messageId,
          ),
          callback: (payload) async {
            final result = await getReactions(messageId: messageId);
            if (result.isSuccess && !controller.isClosed) {
              controller.add(result.valueOrNull ?? []);
            }
          },
        )
        .subscribe();

    // Send initial state
    getReactions(messageId: messageId).then((result) {
      if (result.isSuccess && !controller.isClosed) {
        controller.add(result.valueOrNull ?? []);
      }
    });

    return controller.stream;
  }
}
