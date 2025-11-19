/// Home Screen
/// Main navigation hub with conversations list and quick actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../anonymous/presentation/create_session_screen.dart';
import '../../anonymous/presentation/join_session_screen.dart';
import '../../groups/presentation/create_group_screen.dart';
import '../../contacts/presentation/search_contacts_screen.dart';
import '../../qr/presentation/my_qr_screen.dart';
import '../../qr/presentation/scan_qr_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [ChatListScreen(), ContactsTabScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hush'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _showQROptions,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    if (_currentIndex == 0) {
      // Chats tab - show new chat options
      return FloatingActionButton(
        onPressed: _showNewChatOptions,
        child: const Icon(Icons.add),
      );
    } else {
      // Contacts tab - show add contact
      return FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SearchContactsScreen(),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      );
    }
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('New Group'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Anonymous Session'),
              subtitle: const Text('Create encrypted session without account'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateSessionScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Join Anonymous Session'),
              subtitle: const Text('Enter session code or scan QR'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const JoinSessionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQROptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_2),
              title: const Text('My QR Code'),
              subtitle: const Text('Show your QR code to add contacts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyQRScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan QR Code'),
              subtitle: const Text('Add contact or join session'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ScanQRScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Contacts tab placeholder
class ContactsTabScreen extends StatelessWidget {
  const ContactsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contacts, size: 64, color: AppTheme.gray400),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'Contacts',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppTheme.gray600),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Your contacts will appear here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray500),
          ),
          const SizedBox(height: AppTheme.spacing24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchContactsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Add Contact'),
          ),
        ],
      ),
    );
  }
}
