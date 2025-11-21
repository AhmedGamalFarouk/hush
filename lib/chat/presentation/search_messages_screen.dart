/// Search Messages Screen
/// Search through encrypted messages in a conversation
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../models/message.dart';
import '../../core/utils/text_direction_helper.dart';

class SearchMessagesScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final List<DecryptedMessage> messages;

  const SearchMessagesScreen({
    super.key,
    required this.conversationId,
    required this.messages,
  });

  @override
  ConsumerState<SearchMessagesScreen> createState() =>
      _SearchMessagesScreenState();
}

class _SearchMessagesScreenState extends ConsumerState<SearchMessagesScreen> {
  final _searchController = TextEditingController();
  List<DecryptedMessage> _filteredMessages = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMessages = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      final lowerQuery = query.toLowerCase();

      _filteredMessages = widget.messages.where((message) {
        // Search in message content
        final contentMatch = message.content.toLowerCase().contains(lowerQuery);

        // Search in sender name
        final senderMatch =
            message.senderName?.toLowerCase().contains(lowerQuery) ?? false;

        return contentMatch || senderMatch;
      }).toList();

      // Sort by newest first
      _filteredMessages.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search messages...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Search messages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Type to search through your conversation',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'No messages found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredMessages.length,
      itemBuilder: (context, index) {
        final message = _filteredMessages[index];
        return _SearchResultTile(
          message: message,
          searchQuery: _searchController.text,
          onTap: () {
            // Return the message ID to navigate to it
            Navigator.pop(context, message.id);
          },
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final DecryptedMessage message;
  final String searchQuery;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.message,
    required this.searchQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          (message.senderName ?? 'U')[0].toUpperCase(),
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              message.senderName ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (message.createdAt != null)
            Text(
              _formatTime(message.createdAt!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      subtitle: _buildHighlightedText(context),
      onTap: onTap,
    );
  }

  Widget _buildHighlightedText(BuildContext context) {
    final content = message.content;
    final lowerContent = content.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();

    final index = lowerContent.indexOf(lowerQuery);

    if (index == -1) {
      return Directionality(
        textDirection: startsWithArabic(content)
            ? ui.TextDirection.rtl
            : ui.TextDirection.ltr,
        child: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
      );
    }

    // Show context around the match
    final start = (index - 20).clamp(0, content.length);
    final end = (index + searchQuery.length + 20).clamp(0, content.length);

    final before = content.substring(start, index);
    final match = content.substring(index, index + searchQuery.length);
    final after = content.substring(index + searchQuery.length, end);

    return Directionality(
      textDirection: startsWithArabic(content)
          ? ui.TextDirection.rtl
          : ui.TextDirection.ltr,
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            if (start > 0) const TextSpan(text: '...'),
            TextSpan(text: before),
            TextSpan(
              text: match,
              style: TextStyle(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            TextSpan(text: after),
            if (end < content.length) const TextSpan(text: '...'),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
