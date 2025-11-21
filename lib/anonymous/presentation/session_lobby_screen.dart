/// Session Lobby Screen
/// Display session info, participants, and start chat
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../chat/presentation/chat_screen.dart';
import '../models/anonymous_session.dart';

class SessionLobbyScreen extends ConsumerStatefulWidget {
  final AnonymousSession session;
  final LocalSessionState localState;

  const SessionLobbyScreen({
    required this.session,
    required this.localState,
    super.key,
  });

  @override
  ConsumerState<SessionLobbyScreen> createState() => _SessionLobbyScreenState();
}

class _SessionLobbyScreenState extends ConsumerState<SessionLobbyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Lobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showSessionInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Session banner
          _buildSessionBanner(),

          // Participants list
          Expanded(child: _buildParticipantsList()),

          // Start chat button
          _buildStartChatButton(),
        ],
      ),
    );
  }

  Widget _buildSessionBanner() {
    final expiresIn = widget.session.expiresAt.difference(DateTime.now());
    final hoursLeft = expiresIn.inHours;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                'Anonymous Session',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: hoursLeft < 1
                    ? AppTheme.warning
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: AppTheme.spacing4),
              Text(
                'Expires in ${_formatExpiry(expiresIn)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: hoursLeft < 1
                      ? AppTheme.warning
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Icon(
                Icons.people,
                size: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: AppTheme.spacing4),
              Text(
                '${widget.session.participants.length}/${widget.session.maxParticipants} participants',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    final participants = widget.session.participants;

    if (participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Waiting for participants...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        final isMe = participant.ephemeralId == widget.localState.ephemeralId;

        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                isMe ? Icons.person : Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              participant.nickname ??
                  'Anonymous ${participant.ephemeralId.substring(0, 6)}',
              style: isMe ? const TextStyle(fontWeight: FontWeight.bold) : null,
            ),
            subtitle: Text(
              isMe ? 'You' : 'Joined ${_formatJoinTime(participant.joinedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            trailing: participant.isOnline
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildStartChatButton() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: _startChat,
          icon: const Icon(Icons.chat),
          label: const Text('Start Chat'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ),
    );
  }

  String _formatExpiry(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  String _formatJoinTime(DateTime joinedAt) {
    final now = DateTime.now();
    final diff = now.difference(joinedAt);

    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showSessionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Session Code', widget.session.humanCode ?? 'N/A'),
            _buildInfoRow(
              'Session ID',
              '${widget.session.sessionId.substring(0, 8)}...',
            ),
            _buildInfoRow(
              'Created',
              widget.session.createdAt.toString().substring(0, 16),
            ),
            _buildInfoRow(
              'Expires',
              widget.session.expiresAt.toString().substring(0, 16),
            ),
            _buildInfoRow(
              'Max Participants',
              '${widget.session.maxParticipants}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  void _startChat() {
    // Navigate to chat screen with anonymous session
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: widget.session.sessionId,
          conversationName: 'Anonymous Session',
          isAnonymous: true,
          sessionExpiresAt: widget.session.expiresAt,
        ),
      ),
    );
  }
}
