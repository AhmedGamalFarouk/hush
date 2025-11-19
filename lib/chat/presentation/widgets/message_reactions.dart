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
          ...reactions.map(
            (reaction) => _ReactionChip(
              reaction: reaction,
              onTap: () => onReactionTap(reaction.emoji),
            ),
          ),
          // Add reaction button
          InkWell(
            onTap: onAddReaction,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
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
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isReactedByMe
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isReactedByMe
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isReactedByMe ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reaction.emoji, style: const TextStyle(fontSize: 14)),
            if (reaction.count > 1) ...[
              const SizedBox(width: 4),
              Text(
                reaction.count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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
