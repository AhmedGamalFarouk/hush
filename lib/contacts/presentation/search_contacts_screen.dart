/// Search Contacts Screen
/// Find and add users by username or email
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../chat/models/profile.dart';
import '../../chat/services/conversation_service.dart';
import '../../chat/presentation/chat_screen.dart';
import '../services/contact_service.dart';

class SearchContactsScreen extends ConsumerStatefulWidget {
  const SearchContactsScreen({super.key});

  @override
  ConsumerState<SearchContactsScreen> createState() =>
      _SearchContactsScreenState();
}

class _SearchContactsScreenState extends ConsumerState<SearchContactsScreen> {
  final _searchController = TextEditingController();
  List<Profile> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    final contactService = ref.read(contactServiceProvider);
    final result = await contactService.searchUsers(query);

    if (!mounted) return;

    setState(() {
      _isSearching = false;
      if (result.isSuccess) {
        _searchResults = result.valueOrNull!;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${result.errorOrNull?.message}'),
          ),
        );
      }
    });
  }

  Future<void> _startConversation(Profile profile) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final conversationService = ref.read(conversationServiceProvider);
    final result = await conversationService.createDirectConversation(
      otherUserId: profile.id,
    );

    if (!mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    if (result.isSuccess) {
      final convWithKey = result.valueOrNull!;
      // Navigate to chat screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: convWithKey.conversation.id,
            conversationName: profile.displayName ?? profile.username,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to start conversation: ${result.errorOrNull?.message}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Contact')),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: EdgeInsets.all(AppTheme.spacing16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by username or email',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(Duration(milliseconds: 500), () {
                  if (value == _searchController.text) {
                    _searchUsers(value);
                  }
                });
              },
            ),
          ),

          // Results
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: AppTheme.spacing16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Search for users'
                              : 'No users found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final profile = _searchResults[index];
                      final currentUserId =
                          Supabase.instance.client.auth.currentUser?.id;

                      // Don't show current user
                      if (profile.id == currentUserId) {
                        return SizedBox.shrink();
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            (profile.displayName ?? profile.username)[0]
                                .toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        title: Text(
                          profile.displayName ?? profile.username,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('@${profile.username}'),
                        trailing: IconButton(
                          icon: Icon(Icons.chat_bubble_outline),
                          onPressed: () => _startConversation(profile),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
