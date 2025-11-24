import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../chat/services/conversation_service.dart';

class ContactInfoScreen extends ConsumerWidget {
  final String userId;
  final String displayName;
  final String? conversationId;

  const ContactInfoScreen({
    required this.userId,
    required this.displayName,
    this.conversationId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Info')),
      body: Column(
        children: [
          const SizedBox(height: AppTheme.spacing32),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(displayName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppTheme.spacing32),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Block User'),
            onTap: () {
              // TODO: Implement block
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Blocking not implemented yet')),
              );
            },
          ),
          if (conversationId != null)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete Conversation'),
              onTap: () => _deleteConversation(context, ref),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteConversation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'Are you sure you want to delete this conversation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.warning),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!context.mounted) return;

    final conversationService = ref.read(conversationServiceProvider);
    final result = await conversationService.deleteConversation(
      conversationId!,
    );

    if (!context.mounted) return;

    if (result.isSuccess) {
      // Pop back to chat list (pop ContactInfo, then pop ChatScreen)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete conversation: ${result.errorOrNull?.message}',
          ),
        ),
      );
    }
  }
}
