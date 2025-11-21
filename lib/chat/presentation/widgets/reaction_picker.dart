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

  /// Show quick reactions overlay above message (like iMessage/WhatsApp)
  static void showQuick({
    required BuildContext context,
    required Function(String emoji) onReactionSelected,
    Offset? position,
    Size? size,
    bool isMe = false,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => _QuickReactionOverlay(
        onReactionSelected: (emoji) {
          Navigator.pop(context);
          onReactionSelected(emoji);
        },
        position: position,
        size: size,
        isMe: isMe,
      ),
    );
  }
}

/// Quick reaction overlay with animation
class _QuickReactionOverlay extends StatefulWidget {
  final Function(String emoji) onReactionSelected;
  final Offset? position;
  final Size? size;
  final bool isMe;

  const _QuickReactionOverlay({
    required this.onReactionSelected,
    this.position,
    this.size,
    this.isMe = false,
  });

  @override
  State<_QuickReactionOverlay> createState() => _QuickReactionOverlayState();
}

class _QuickReactionOverlayState extends State<_QuickReactionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  static const List<String> _quickReactions = [
    '❤️',
    '👍',
    '😂',
    '😮',
    '😢',
    '🙏',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Calculate position based on message bubble
    double? top;
    double? bottom;
    double? left;
    double? right;

    if (widget.position != null && widget.size != null) {
      final messageTop = widget.position!.dy;
      final messageBottom = messageTop + widget.size!.height;
      final messageLeft = widget.position!.dx;
      final messageRight = messageLeft + widget.size!.width;

      // Position above the message with some padding
      const verticalPadding = 8.0;
      const reactionBarHeight = 60.0; // Approximate height

      // Check if there's space above
      if (messageTop >
          reactionBarHeight + verticalPadding + mediaQuery.padding.top) {
        // Position above message
        bottom = screenHeight - messageTop + verticalPadding;
      } else {
        // Position below message
        top = messageBottom + verticalPadding;
      }

      // Horizontal positioning based on message alignment
      if (widget.isMe) {
        // For "my" messages (right-aligned), align reaction bar to the right
        right = screenWidth - messageRight;
      } else {
        // For "their" messages (left-aligned), align reaction bar to the left
        left = messageLeft;
      }
    }

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          Positioned(
            top: top,
            bottom: bottom,
            left: left,
            right: right,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _quickReactions.map((emoji) {
                      return _QuickReactionButton(
                        emoji: emoji,
                        onTap: () => widget.onReactionSelected(emoji),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickReactionButton extends StatefulWidget {
  final String emoji;
  final VoidCallback onTap;

  const _QuickReactionButton({required this.emoji, required this.onTap});

  @override
  State<_QuickReactionButton> createState() => _QuickReactionButtonState();
}

class _QuickReactionButtonState extends State<_QuickReactionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedScale(
        scale: _isPressed ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutBack,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}
