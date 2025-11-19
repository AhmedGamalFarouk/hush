/// Presence Service
/// Track user online/offline status and last seen
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_provider.dart';

/// Provider for presence service
final presenceServiceProvider = Provider<PresenceService>((ref) {
  return PresenceService(supabase: ref.watch(supabaseProvider));
});

/// Presence status
enum PresenceStatus { online, offline, away }

class UserPresence {
  final String userId;
  final PresenceStatus status;
  final DateTime lastSeen;

  const UserPresence({
    required this.userId,
    required this.status,
    required this.lastSeen,
  });

  bool get isOnline => status == PresenceStatus.online;

  String get lastSeenText {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (isOnline) return 'Online';

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return 'Last seen ${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }
}

class PresenceService {
  final SupabaseClient _supabase;
  Timer? _heartbeatTimer;
  final Map<String, RealtimeChannel> _channels = {};

  PresenceService({required SupabaseClient supabase}) : _supabase = supabase;

  // ============================================================================
  // PRESENCE MANAGEMENT
  // ============================================================================

  /// Start presence tracking (call on app launch)
  Future<void> startPresence() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Set initial presence
      await _updatePresence(PresenceStatus.online);

      // Start heartbeat to maintain online status
      _heartbeatTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _updatePresence(PresenceStatus.online),
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Stop presence tracking (call on app close)
  Future<void> stopPresence() async {
    try {
      _heartbeatTimer?.cancel();
      await _updatePresence(PresenceStatus.offline);
    } catch (e) {
      // Silently fail
    }
  }

  /// Update presence when app goes to background
  Future<void> setAway() async {
    try {
      await _updatePresence(PresenceStatus.away);
    } catch (e) {
      // Silently fail
    }
  }

  /// Update presence when app comes to foreground
  Future<void> setOnline() async {
    try {
      await _updatePresence(PresenceStatus.online);

      // Restart heartbeat
      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _updatePresence(PresenceStatus.online),
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Internal: Update presence in database
  Future<void> _updatePresence(PresenceStatus status) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('presence').upsert({
        'user_id': userId,
        'status': status.name,
        'last_seen': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail
    }
  }

  // ============================================================================
  // PRESENCE QUERIES
  // ============================================================================

  /// Get presence for a specific user
  Future<UserPresence?> getUserPresence(String userId) async {
    try {
      final response = await _supabase
          .from('presence')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return UserPresence(
          userId: userId,
          status: PresenceStatus.offline,
          lastSeen: DateTime.now(),
        );
      }

      return UserPresence(
        userId: userId,
        status: _parseStatus(response['status'] as String?),
        lastSeen: DateTime.parse(response['last_seen'] as String),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get presence for multiple users
  Future<Map<String, UserPresence>> getUsersPresence(
    List<String> userIds,
  ) async {
    try {
      final response = await _supabase
          .from('presence')
          .select()
          .inFilter('user_id', userIds);

      final presences = <String, UserPresence>{};
      for (final row in response as List) {
        final userId = row['user_id'] as String;
        presences[userId] = UserPresence(
          userId: userId,
          status: _parseStatus(row['status'] as String?),
          lastSeen: DateTime.parse(row['last_seen'] as String),
        );
      }

      // Fill in missing users as offline
      for (final userId in userIds) {
        if (!presences.containsKey(userId)) {
          presences[userId] = UserPresence(
            userId: userId,
            status: PresenceStatus.offline,
            lastSeen: DateTime.now(),
          );
        }
      }

      return presences;
    } catch (e) {
      return {};
    }
  }

  /// Subscribe to presence updates for specific users
  Stream<Map<String, UserPresence>> subscribeToPresence(List<String> userIds) {
    final controller = StreamController<Map<String, UserPresence>>();

    if (userIds.isEmpty) {
      controller.close();
      return controller.stream;
    }

    // Create channel for presence updates
    final channel = _supabase.channel('presence:${userIds.join(',')}');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'presence',
          callback: (payload) async {
            // Fetch current presence for all users
            final presences = await getUsersPresence(userIds);
            controller.add(presences);
          },
        )
        .subscribe();

    _channels['presence:${userIds.join(',')}'] = channel;

    // Send initial state
    getUsersPresence(userIds).then((presences) {
      if (!controller.isClosed) {
        controller.add(presences);
      }
    });

    controller.onCancel = () {
      channel.unsubscribe();
      _channels.remove('presence:${userIds.join(',')}');
    };

    return controller.stream;
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  PresenceStatus _parseStatus(String? status) {
    switch (status) {
      case 'online':
        return PresenceStatus.online;
      case 'away':
        return PresenceStatus.away;
      default:
        return PresenceStatus.offline;
    }
  }

  /// Clean up resources
  void dispose() {
    _heartbeatTimer?.cancel();
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
  }
}
