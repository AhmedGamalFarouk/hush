/// Anonymous Home Screen
/// Entry point for guest users to create or join anonymous sessions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../auth/presentation/login_screen.dart';
import 'create_session_screen.dart';
import 'join_session_screen.dart';

class AnonymousHomeScreen extends ConsumerStatefulWidget {
  const AnonymousHomeScreen({super.key});

  @override
  ConsumerState<AnonymousHomeScreen> createState() => _AnonymousHomeScreenState();
}

class _AnonymousHomeScreenState extends ConsumerState<AnonymousHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Mode'),
        actions: [
          TextButton.icon(
            onPressed: _navigateToLogin,
            icon: const Icon(Icons.login, size: 20),
            label: const Text('Sign In'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome section
              Icon(
                Icons.shield,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppTheme.spacing24),
              Text(
                'Anonymous Sessions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Create or join temporary encrypted chat sessions without an account',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing48),

              // Info cards
              _buildInfoCard(
                context,
                icon: Icons.lock_clock,
                title: 'Temporary Sessions',
                description: 'Sessions automatically expire after 24 hours by default',
              ),
              const SizedBox(height: AppTheme.spacing16),
              _buildInfoCard(
                context,
                icon: Icons.group,
                title: 'Group Support',
                description: 'Create sessions with up to 50 participants',
              ),
              const SizedBox(height: AppTheme.spacing16),
              _buildInfoCard(
                context,
                icon: Icons.security,
                title: 'End-to-End Encrypted',
                description: 'All messages are encrypted with no server access',
              ),
              const SizedBox(height: AppTheme.spacing48),

              // Action buttons
              ElevatedButton.icon(
                onPressed: _navigateToCreateSession,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create New Session'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              OutlinedButton.icon(
                onPressed: _navigateToJoinSession,
                icon: const Icon(Icons.login),
                label: const Text('Join Existing Session'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                ),
              ),
              const SizedBox(height: AppTheme.spacing48),

              // Warning card
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Important',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            Text(
                              'Anonymous sessions are deleted after expiry. Create an account to save your conversations permanently.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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

  void _navigateToCreateSession() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateSessionScreen()),
    );
  }

  void _navigateToJoinSession() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const JoinSessionScreen()),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
