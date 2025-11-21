/// Message Reactions Display Widget
/// Shows emoji reactions under messages
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../models/message_reaction.dart';

class MessageReactions extends StatelessWidget {
  final List<ReactionSummary> reactions;
  final Function(String emoji) onReactionTap;
  final VoidCallback onAddReaction;

  const MessageReactions({
    super.key,
    required this.reactions,
    required this.onReactionTap,
    required this.onAddReaction,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacing4),
      child: Wrap(
        spacing: AppTheme.spacing4,
        runSpacing: AppTheme.spacing4,
        children: [
          ...reactions.map((reaction) {
            return _ReactionChip(
              reaction: reaction,
              onTap: () => onReactionTap(reaction.emoji),
            );
          }),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final ReactionSummary reaction;
  final VoidCallback onTap;

  const _ReactionChip({required this.reaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isReactedByMe = reaction.reactedByMe;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isReactedByMe
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isReactedByMe
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reaction.emoji, style: const TextStyle(fontSize: 12)),
            if (reaction.count > 1) ...[
              const SizedBox(width: 4),
              Text(
                reaction.count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isReactedByMe
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
