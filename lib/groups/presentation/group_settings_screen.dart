/// Group Settings Screen
/// Manage group members, info, and settings
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../models/group.dart';
import '../services/group_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_member_screen.dart';

class GroupSettingsScreen extends ConsumerStatefulWidget {
  final Group group;

  const GroupSettingsScreen({required this.group, super.key});

  @override
  ConsumerState<GroupSettingsScreen> createState() =>
      _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends ConsumerState<GroupSettingsScreen> {
  late Group _group;
  bool _isCurrentUserAdmin = false;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _checkIfAdmin();
  }

  void _checkIfAdmin() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      _isCurrentUserAdmin = _group.members.any(
        (m) => m.userId == currentUserId && m.isAdmin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Settings'),
        actions: [
          if (_isCurrentUserAdmin)
            IconButton(icon: const Icon(Icons.edit), onPressed: _editGroupInfo),
        ],
      ),
      body: ListView(
        children: [
          // Group info section
          _buildGroupInfoSection(),
          const Divider(),

          // Members section
          _buildMembersSection(),
          const Divider(),

          // Actions section
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildGroupInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.group,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Center(
            child: Text(
              _group.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          if (_group.description != null) ...[
            const SizedBox(height: AppTheme.spacing8),
            Center(
              child: Text(
                _group.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacing16),
          _buildInfoRow(
            Icons.calendar_today,
            'Created',
            _formatDate(_group.createdAt),
          ),
          _buildInfoRow(
            Icons.security,
            'Encryption',
            'Key v${_group.keyVersion}',
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members (${_group.members.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_isCurrentUserAdmin)
                TextButton.icon(
                  onPressed: _addMember,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add'),
                ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _group.members.length,
          itemBuilder: (context, index) {
            final member = _group.members[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: member.avatarUrl != null
                    ? CachedNetworkImageProvider(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null
                    ? Text(member.displayName.substring(0, 1).toUpperCase())
                    : null,
              ),
              title: Text(member.displayName),
              subtitle: Text(
                member.isAdmin ? 'Admin' : 'Member',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: member.isAdmin
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              trailing: _isCurrentUserAdmin && !member.isAdmin
                  ? IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                      onPressed: () => _removeMember(member.userId),
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: _leaveGroup,
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Leave Group'),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.warning),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: AppTheme.spacing8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays < 1) {
      return 'Today';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _editGroupInfo() {
    final nameController = TextEditingController(text: _group.name);
    final descriptionController = TextEditingController(
      text: _group.description ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter group description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              Navigator.pop(dialogContext);

              final groupService = ref.read(groupServiceProvider);
              final result = await groupService.updateGroup(
                groupId: _group.id,
                name: nameController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
              );

              if (mounted) {
                if (result.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group info updated')),
                  );
                  _refreshGroup();
                } else {
                  _showError(result.errorOrNull!.message);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addMember() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddMemberScreen(
          groupId: _group.id,
          existingMemberIds: _group.members.map((m) => m.userId).toList(),
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added successfully')),
      );
      _refreshGroup();
    }
  }

  Future<void> _removeMember(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: const Text('Are you sure you want to remove this member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.warning),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final groupService = ref.read(groupServiceProvider);
    final result = await groupService.removeMember(
      groupId: _group.id,
      userId: userId,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Member removed')));
      // Refresh group
      _refreshGroup();
    } else {
      _showError(result.errorOrNull!.message);
    }
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text(
          'Are you sure you want to leave this group? You will need to be re-added to join again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.warning),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final groupService = ref.read(groupServiceProvider);
    final result = await groupService.leaveGroup(_group.id);

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pop(); // Go back to chat list
    } else {
      _showError(result.errorOrNull!.message);
    }
  }

  Future<void> _refreshGroup() async {
    final groupService = ref.read(groupServiceProvider);
    final result = await groupService.getGroup(_group.id);

    if (result.isSuccess && mounted) {
      setState(() {
        _group = result.valueOrNull!;
      });
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
