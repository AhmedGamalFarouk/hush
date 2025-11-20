/// Settings Screen
/// App settings, profile, theme, and preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile section
          _buildProfileSection(context, user),
          const Divider(),

          // App settings
          _buildSettingsSection(context),
          const Divider(),

          // Security & Privacy
          _buildSecuritySection(context),
          const Divider(),

          // About section
          _buildAboutSection(context),
          const Divider(),

          // Sign out
          _buildSignOutSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, dynamic user) {
    if (user == null) return const SizedBox.shrink();

    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.person,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        user.email ?? 'User',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: const Text('Tap to edit profile'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
        );
      },
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacing16,
            AppTheme.spacing16,
            AppTheme.spacing16,
            AppTheme.spacing8,
          ),
          child: Text(
            'App Settings',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppTheme.gray600),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Theme'),
          subtitle: const Text('Light / Dark / System'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showThemeDialog(context);
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Notifications'),
          subtitle: const Text('Receive message notifications'),
          value: true, // TODO: Connect to actual setting
          onChanged: (value) {
            // TODO: Update notification preference
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacing16,
            AppTheme.spacing16,
            AppTheme.spacing16,
            AppTheme.spacing8,
          ),
          child: Text(
            'Security & Privacy',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppTheme.gray600),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outlined),
          title: const Text('Change Password'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to change password
          },
        ),
        ListTile(
          leading: const Icon(Icons.vpn_key_outlined),
          title: const Text('Encryption Keys'),
          subtitle: const Text('View your public key'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showKeysDialog(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('Clear Media Cache'),
          subtitle: const Text('Free up storage space'),
          onTap: () {
            _showClearCacheDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacing16,
            AppTheme.spacing16,
            AppTheme.spacing16,
            AppTheme.spacing8,
          ),
          child: Text(
            'About',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppTheme.gray600),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outlined),
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Show privacy policy
          },
        ),
        ListTile(
          leading: const Icon(Icons.article_outlined),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Show terms
          },
        ),
      ],
    );
  }

  Widget _buildSignOutSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: OutlinedButton.icon(
        onPressed: () => _signOut(context, ref),
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.warning),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: RadioGroup<String>(
          onChanged: (value) {
            // TODO: Update theme with value
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(title: const Text('Light'), value: 'light'),
              RadioListTile<String>(title: const Text('Dark'), value: 'dark'),
              RadioListTile<String>(
                title: const Text('System'),
                value: 'system',
              ),
            ],
          ),
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

  void _showKeysDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encryption Keys'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your public key:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: AppTheme.gray100,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Text(
                'pk_xxxxxxxxxxxxx...', // TODO: Get actual public key
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
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

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Media Cache'),
        content: const Text(
          'This will delete all cached media files. You can re-download them from messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Clear cache
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.warning),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.warning),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
