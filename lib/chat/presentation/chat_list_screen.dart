/// Chat List Screen
/// Displays all conversations with real-time updates
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/widgets/empty_state.dart';
import '../../realtime/services/presence_service.dart';
import '../models/conversation.dart';
import '../services/conversation_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;

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
          _conversations = result.valueOrNull ?? [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _conversations.isEmpty
        ? const EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'No conversations yet',
            subtitle: 'Start a new chat or join an anonymous session',
          )
        : RefreshIndicator(
            onRefresh: _loadConversations,
            child: ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return Consumer(
                  builder: (context, ref, _) {
                    return _ConversationTile(
                      conversation: conversation,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              conversationId: conversation.id,
                              conversationName: conversation.name ?? 'Chat',
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
  }
}

/// Conversation tile widget
class _ConversationTile extends ConsumerStatefulWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  ConsumerState<_ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends ConsumerState<_ConversationTile> {
  UserPresence? _presence;

  @override
  void initState() {
    super.initState();
    _loadPresence();
  }

  Future<void> _loadPresence() async {
    // Only show presence for direct chats
    if (widget.conversation.type != ConversationType.direct) return;

    // Get other user ID from conversation members
    // For now, we'll implement this when we have members info
    // TODO: Get other user ID and fetch presence
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final showPresence =
        widget.conversation.type == ConversationType.direct &&
        _presence != null;

    final name = widget.conversation.name ?? 'Chat';
    final isAnonymous = widget.conversation.type == ConversationType.anonymous;
    final isGroup = widget.conversation.type == ConversationType.group;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isAnonymous
                ? Colors.grey.shade800
                : _getAvatarColor(name),
            child: isAnonymous
                ? const Icon(
                    Icons.theater_comedy,
                    color: Colors.white,
                    size: 20,
                  )
                : isGroup
                ? const Icon(Icons.group, color: Colors.white, size: 20)
                : Text(
                    _getInitials(name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          // Presence indicator dot
          if (showPresence && _presence!.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          if (isAnonymous)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ANON',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(
              isAnonymous ? Icons.vpn_key : Icons.lock,
              size: 12,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.lastMessagePreview ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (showPresence && !_presence!.isOnline) ...[
                    const SizedBox(height: 2),
                    Text(
                      _presence!.lastSeenText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.conversation.lastMessageAt != null)
            Text(
              _formatTime(widget.conversation.lastMessageAt!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          if (widget.conversation.unreadCount > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.conversation.unreadCount > 99
                    ? '99+'
                    : widget.conversation.unreadCount.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: widget.onTap,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else if (messageDate.isAfter(today.subtract(Duration(days: 7)))) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[messageDate.weekday - 1];
    } else {
      return '${messageDate.day}/${messageDate.month}/${messageDate.year}';
    }
  }
}
