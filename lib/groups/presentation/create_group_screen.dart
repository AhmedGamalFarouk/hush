/// Create Group Screen
/// Create a new encrypted group chat
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../chat/models/conversation.dart';
import '../../chat/services/conversation_service.dart';
import '../models/group.dart';
import '../services/group_service.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedMembers = [];
  bool _isCreating = false;
  List<Map<String, String>> _contacts = [];
  bool _isLoadingContacts = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoadingContacts = true;
    });

    try {
      final conversationService = ref.read(conversationServiceProvider);
      final result = await conversationService.getConversations();

      if (result.isSuccess) {
        final conversations = result.valueOrNull!;
        // Extract contacts from direct conversations
        final contacts = <Map<String, String>>[];
        for (final conv in conversations) {
          if (conv.type == ConversationType.direct) {
            // TODO: Fetch actual user info from profiles
            contacts.add({
              'id': conv.id,
              'name': conv.name ?? 'User ${conv.id.substring(0, 6)}',
            });
          }
        }
        setState(() {
          _contacts = contacts;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingContacts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          if (_isCreating)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _canCreate() ? _createGroup : null,
              child: const Text('Create'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Group info section
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'Enter group name',
                    prefixIcon: Icon(Icons.group),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'What is this group about?',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const Divider(),

          // Members section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing8,
            ),
            child: Row(
              children: [
                Text('Members', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: AppTheme.spacing8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    '${_selectedMembers.length} selected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contacts list
          Expanded(
            child: _isLoadingContacts
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                ? Center(
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
                          'No contacts yet',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'Add contacts to create groups',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      final contactId = contact['id']!;
                      final isSelected = _selectedMembers.contains(contactId);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedMembers.add(contactId);
                            } else {
                              _selectedMembers.remove(contactId);
                            }
                          });
                        },
                        title: Text(contact['name']!),
                        secondary: CircleAvatar(
                          child: Text(
                            contact['name']!.substring(0, 1).toUpperCase(),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _canCreate() {
    return _nameController.text.trim().isNotEmpty &&
        _selectedMembers.isNotEmpty &&
        !_isCreating;
  }

  Future<void> _createGroup() async {
    setState(() {
      _isCreating = true;
    });

    try {
      final groupService = ref.read(groupServiceProvider);

      final params = CreateGroupParams(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        memberIds: _selectedMembers,
      );

      final result = await groupService.createGroup(params: params);

      if (!mounted) return;

      if (result.isSuccess) {
        Navigator.of(context).pop(result.valueOrNull);
      } else {
        _showError(result.errorOrNull!.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
