/// Message Reaction Model
/// Emoji reactions on messages
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_reaction.freezed.dart';
part 'message_reaction.g.dart';

@freezed
class MessageReaction with _$MessageReaction {
  const factory MessageReaction({
    required String id,
    @JsonKey(name: 'message_id') required String messageId,
    @JsonKey(name: 'user_id') required String userId,
    required String emoji,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MessageReaction;

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionFromJson(json);
}

/// Aggregated reactions for a message
class ReactionSummary {
  final String emoji;
  final int count;
  final List<String> userIds;
  final bool reactedByMe;

  const ReactionSummary({
    required this.emoji,
    required this.count,
    required this.userIds,
    required this.reactedByMe,
  });
}
