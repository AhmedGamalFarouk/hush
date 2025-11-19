/// Chat List Screen
/// Displays all conversations with real-time updates
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../../contacts/presentation/search_contacts_screen.dart';
import '../../qr/presentation/my_qr_screen.dart';
import '../../qr/presentation/scan_qr_screen.dart';
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

  Future<void> _handleSignOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hush'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ScanQRScreen()));
            },
            tooltip: 'Scan QR Code',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Show settings bottom sheet
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildSettingsSheet(context, user),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
          ? EmptyState(
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatOptions(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSettingsSheet(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacing24),

          // User info
          if (user != null) ...[
            ListTile(
              leading: CircleAvatar(
                child: Text(user.email?[0].toUpperCase() ?? '?'),
              ),
              title: Text(user.email ?? 'Unknown'),
              subtitle: const Text('Signed in'),
            ),
            const Divider(),
          ],

          // Options
          ListTile(
            leading: const Icon(Icons.person_outlined),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile - Coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications - Coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Privacy & Security'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy - Coming soon')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _handleSignOut();
            },
          ),
        ],
      ),
    );
  }

  void _showNewChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Chat', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.spacing24),

            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text('Add Contact'),
              subtitle: const Text('Find users by username'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SearchContactsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Share My QR Code'),
              subtitle: const Text('Let others add you'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const MyQRScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('Create Group'),
              subtitle: const Text('Start a group chat'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create Group - Coming soon')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock_clock_outlined),
              title: const Text('Anonymous Session'),
              subtitle: const Text('No-account encrypted chat'),
              onTap: () {
                Navigator.pop(context);
                _showAnonymousOptions(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAnonymousOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anonymous Session',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Temporary encrypted chat without accounts',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Create Session'),
              subtitle: const Text('Generate a new session key'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create Anonymous Session - Coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Join Session'),
              subtitle: const Text('Enter session key or scan QR'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Join Anonymous Session - Coming soon'),
                  ),
                );
              },
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    final showPresence =
        widget.conversation.type == ConversationType.direct &&
        _presence != null;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              widget.conversation.type == ConversationType.group
                  ? Icons.group
                  : widget.conversation.type == ConversationType.anonymous
                  ? Icons.lock_clock
                  : Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
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
      title: Text(
        widget.conversation.name ?? 'Chat',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.conversation.lastMessagePreview ?? 'No messages yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (showPresence && !_presence!.isOnline) ...[
            SizedBox(height: 2),
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
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.conversation.lastMessageAt != null)
            Text(
              _formatTime(widget.conversation.lastMessageAt!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (widget.conversation.unreadCount > 0) ...[
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.conversation.unreadCount > 99
                    ? '99+'
                    : widget.conversation.unreadCount.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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
