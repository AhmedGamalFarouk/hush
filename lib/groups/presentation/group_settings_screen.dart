/// Group Settings Screen
/// Manage group members, info, and settings
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../models/group.dart';
import '../services/group_service.dart';

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
    // TODO: Get current user ID from auth
    // _isCurrentUserAdmin = _group.members
    //     .any((m) => m.userId == currentUserId && m.isAdmin);
    _isCurrentUserAdmin = true; // Temporary
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
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
                child: Text(member.displayName.substring(0, 1).toUpperCase()),
              ),
              title: Text(member.displayName),
              subtitle: Text(
                member.isAdmin ? 'Admin' : 'Member',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: member.isAdmin
                      ? Theme.of(context).colorScheme.primary
                      : AppTheme.gray600,
                ),
              ),
              trailing: _isCurrentUserAdmin && !member.isAdmin
                  ? IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppTheme.gray500,
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
          Icon(icon, size: 16, color: AppTheme.gray500),
          const SizedBox(width: AppTheme.spacing8),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.gray600),
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
    // TODO: Show dialog to edit name/description
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group'),
        content: const Text('Coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addMember() {
    // TODO: Show member picker dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: const Text('Coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
      SnackBar(content: Text(message), backgroundColor: AppTheme.gray800),
    );
  }
}
