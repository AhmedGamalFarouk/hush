/// Reaction Picker Widget
/// Show emoji picker for message reactions
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String emoji) onReactionSelected;

  const ReactionPicker({super.key, required this.onReactionSelected});

  // Common emoji reactions
  static const List<String> _quickReactions = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
    '🔥',
    '🎉',
    '👏',
    '💯',
    '✅',
    '❌',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'React to message',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Wrap(
            spacing: AppTheme.spacing12,
            runSpacing: AppTheme.spacing12,
            children: _quickReactions.map((emoji) {
              return InkWell(
                onTap: () {
                  onReactionSelected(emoji);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacing8),
        ],
      ),
    );
  }

  static void show({
    required BuildContext context,
    required Function(String emoji) onReactionSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          ReactionPicker(onReactionSelected: onReactionSelected),
    );
  }
}
