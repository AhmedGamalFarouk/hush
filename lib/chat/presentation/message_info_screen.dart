/// Message Info Screen
/// Shows detailed information about a message
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import '../../core/utils/text_direction_helper.dart';

class MessageInfoScreen extends ConsumerStatefulWidget {
  final DecryptedMessage message;
  final bool isGroupChat;

  const MessageInfoScreen({
    super.key,
    required this.message,
    this.isGroupChat = false,
  });

  @override
  ConsumerState<MessageInfoScreen> createState() => _MessageInfoScreenState();
}

class _MessageInfoScreenState extends ConsumerState<MessageInfoScreen> {
  Map<String, List<String>> _readStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadStatus();
  }

  Future<void> _loadReadStatus() async {
    if (!widget.isGroupChat) {
      setState(() => _isLoading = false);
      return;
    }

    final messageService = ref.read(messageServiceProvider);
    final result = await messageService.getReadStatus(
      conversationId: widget.message.conversationId,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _readStatus = result.valueOrNull ?? {};
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final readByUserIds = _readStatus[widget.message.id] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Message Info')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: Text(
                                (widget.message.senderName ?? 'U')[0]
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.message.senderName ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _formatDateTime(widget.message.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                          child: Directionality(
                            textDirection:
                                startsWithArabic(widget.message.content)
                                ? ui.TextDirection.rtl
                                : ui.TextDirection.ltr,
                            child: Text(widget.message.content),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Message details
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Details'),
                        const SizedBox(height: AppTheme.spacing8),
                        _buildInfoRow(
                          context,
                          icon: Icons.schedule,
                          label: 'Sent',
                          value: _formatDateTime(widget.message.createdAt),
                        ),
                        _buildInfoRow(
                          context,
                          icon: Icons.insert_drive_file_outlined,
                          label: 'Type',
                          value: widget.message.type.name.toUpperCase(),
                        ),
                        _buildInfoRow(
                          context,
                          icon: Icons.check_circle_outline,
                          label: 'Status',
                          value: _getStatusText(widget.message.status),
                          valueColor: _getStatusColor(
                            context,
                            widget.message.status,
                          ),
                        ),
                        if (widget.message.metadata != null &&
                            widget.message.metadata!.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacing8),
                          _buildInfoRow(
                            context,
                            icon: Icons.info_outline,
                            label: 'Has metadata',
                            value: '${widget.message.metadata!.length} items',
                          ),
                        ],
                        if (widget.message.replyToId != null) ...[
                          const SizedBox(height: AppTheme.spacing8),
                          _buildInfoRow(
                            context,
                            icon: Icons.reply,
                            label: 'Reply to message',
                            value: widget.message.replyToId!.substring(0, 8),
                          ),
                        ],

                        // Read receipts for group chats
                        if (widget.isGroupChat) ...[
                          const SizedBox(height: AppTheme.spacing24),
                          _buildSectionTitle(context, 'Read By'),
                          const SizedBox(height: AppTheme.spacing8),
                          if (readByUserIds.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacing8,
                              ),
                              child: Text(
                                'Not yet read by anyone',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            )
                          else
                            ...readByUserIds.map((userId) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.done_all,
                                  color: Colors.blue,
                                ),
                                title: Text('User ${userId.substring(0, 8)}'),
                                contentPadding: EdgeInsets.zero,
                              );
                            }),
                        ],

                        // Encryption info
                        const SizedBox(height: AppTheme.spacing24),
                        _buildSectionTitle(context, 'Security'),
                        const SizedBox(height: AppTheme.spacing8),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                            border: Border.all(
                              color: AppTheme.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock,
                                color: AppTheme.success,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End-to-end encrypted',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.success,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'XChaCha20-Poly1305 AEAD cipher',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return DateFormat('MMM d, yyyy • HH:mm').format(dateTime);
  }

  String _getStatusText(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'Sending...';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.failed:
        return 'Failed';
    }
  }

  Color _getStatusColor(BuildContext context, MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case MessageStatus.sent:
        return Theme.of(context).colorScheme.primary;
      case MessageStatus.delivered:
        return Theme.of(context).colorScheme.primary;
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.failed:
        return Theme.of(context).colorScheme.error;
    }
  }
}
