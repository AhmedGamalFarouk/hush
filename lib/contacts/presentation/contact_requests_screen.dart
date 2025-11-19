/// Contact Requests Screen
/// View and manage incoming contact requests
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/models/profile.dart';
import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_provider.dart';
import '../../chat/presentation/chat_screen.dart';
import '../models/contact_request.dart';
import '../services/contact_service.dart';

class ContactRequestsScreen extends ConsumerStatefulWidget {
  const ContactRequestsScreen({super.key});

  @override
  ConsumerState<ContactRequestsScreen> createState() =>
      _ContactRequestsScreenState();
}

class _ContactRequestsScreenState extends ConsumerState<ContactRequestsScreen> {
  List<ContactRequest> _requests = [];
  Map<String, Profile> _senderProfiles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    final contactService = ref.read(contactServiceProvider);
    final result = await contactService.getPendingRequests();

    if (result.isSuccess) {
      final requests = result.valueOrNull ?? [];

      // Fetch sender profiles
      final profiles = <String, Profile>{};
      for (final request in requests) {
        // Fetch sender profile
        try {
          final supabase = ref.read(supabaseProvider);
          final profileData = await supabase
              .from('profiles')
              .select()
              .eq('id', request.senderId)
              .single();

          profiles[request.senderId] = Profile.fromJson(profileData);
        } catch (e) {
          // Failed to load profile, continue
        }
      }
      if (mounted) {
        setState(() {
          _requests = requests;
          _senderProfiles = profiles;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load requests')));
      }
    }
  }

  Future<void> _acceptRequest(ContactRequest request) async {
    final contactService = ref.read(contactServiceProvider);
    final result = await contactService.acceptContactRequest(request.id);

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact request accepted')),
        );

        // Navigate to chat
        final conversationId = result.valueOrNull!;
        final sender = _senderProfiles[request.senderId];

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversationId,
              conversationName:
                  sender?.displayName ?? sender?.username ?? 'Chat',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${result.errorOrNull?.message}')),
        );
      }
    }
  }

  Future<void> _rejectRequest(ContactRequest request) async {
    final contactService = ref.read(contactServiceProvider);
    final result = await contactService.rejectContactRequest(request.id);

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact request rejected')),
        );
        _loadRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${result.errorOrNull?.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Requests')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    'No pending requests',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                final sender = _senderProfiles[request.senderId];

                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: Text(
                                (sender?.username ?? 'U')[0].toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sender?.displayName ??
                                        sender?.username ??
                                        'Unknown',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  if (sender?.username != null)
                                    Text(
                                      '@${sender!.username}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (request.message != null) ...[
                          const SizedBox(height: AppTheme.spacing12),
                          Text(
                            request.message!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacing16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _rejectRequest(request),
                              child: const Text('Reject'),
                            ),
                            const SizedBox(width: AppTheme.spacing8),
                            FilledButton(
                              onPressed: () => _acceptRequest(request),
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
