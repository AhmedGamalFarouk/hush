/// Forward Message Screen
/// Select conversation to forward a message to
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/conversation_service.dart';
import '../services/message_service.dart';
import '../../presentation/widgets/empty_state.dart';
import '../../core/utils/text_direction_helper.dart';

class ForwardMessageScreen extends ConsumerStatefulWidget {
  final DecryptedMessage message;

  const ForwardMessageScreen({super.key, required this.message});

  @override
  ConsumerState<ForwardMessageScreen> createState() =>
      _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends ConsumerState<ForwardMessageScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  final Set<String> _selectedConversations = {};
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final conversationService = ref.read(conversationServiceProvider);
    final result = await conversationService.getConversations();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          // Exclude the current conversation
          _conversations = (result.valueOrNull ?? [])
              .where((c) => c.id != widget.message.conversationId)
              .toList();
        }
      });
    }
  }

  Future<void> _forwardMessage() async {
    if (_selectedConversations.isEmpty) return;

    setState(() => _isSending = true);

    final messageService = ref.read(messageServiceProvider);
    final conversationService = ref.read(conversationServiceProvider);

    int successCount = 0;
    int failCount = 0;

    for (final conversationId in _selectedConversations) {
      // Get conversation key
      final convResult = await conversationService.getConversation(
        conversationId,
      );

      if (convResult.isFailure) {
        failCount++;
        continue;
      }

      final convWithKey = convResult.valueOrNull!;

      // Forward the message content
      final result = await messageService.sendMessage(
        conversationId: conversationId,
        content: widget.message.content,
        conversationKey: convWithKey.key,
        type: widget.message.type,
        metadata: widget.message.metadata,
      );

      if (result.isSuccess) {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (mounted) {
      setState(() => _isSending = false);

      Navigator.pop(context);

      final message = failCount == 0
          ? 'Message forwarded to $successCount conversation${successCount > 1 ? 's' : ''}'
          : 'Forwarded to $successCount, failed: $failCount';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forward Message'),
        actions: [
          if (_selectedConversations.isNotEmpty)
            TextButton(
              onPressed: _isSending ? null : _forwardMessage,
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Send (${_selectedConversations.length})',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Message preview
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.forward,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Forwarding message',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Directionality(
                        textDirection: startsWithArabic(widget.message.content)
                            ? ui.TextDirection.rtl
                            : ui.TextDirection.ltr,
                        child: Text(
                          widget.message.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Conversation list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _conversations.isEmpty
                ? const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No conversations',
                    subtitle: 'Start a chat to forward messages',
                  )
                : ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      final isSelected = _selectedConversations.contains(
                        conversation.id,
                      );

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedConversations.add(conversation.id);
                            } else {
                              _selectedConversations.remove(conversation.id);
                            }
                          });
                        },
                        secondary: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Icon(
                            conversation.type == ConversationType.group
                                ? Icons.group
                                : conversation.type ==
                                      ConversationType.anonymous
                                ? Icons.lock_clock
                                : Icons.person,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        title: Text(
                          conversation.name ?? 'Chat',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: conversation.lastMessagePreview != null
                            ? Text(
                                conversation.lastMessagePreview!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
