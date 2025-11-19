/// Join Anonymous Session Screen
/// Allows users to join an existing anonymous session
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_theme.dart';
import '../models/anonymous_session.dart';
import '../services/anonymous_session_service.dart';
import 'session_lobby_screen.dart';

class JoinSessionScreen extends ConsumerStatefulWidget {
  const JoinSessionScreen({super.key});

  @override
  ConsumerState<JoinSessionScreen> createState() => _JoinSessionScreenState();
}

class _JoinSessionScreenState extends ConsumerState<JoinSessionScreen> {
  final _sessionKeyController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isJoining = false;
  bool _showScanner = false;

  @override
  void dispose() {
    _sessionKeyController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Session')),
      body: _showScanner ? _buildQRScanner() : _buildJoinForm(),
    );
  }

  Widget _buildJoinForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Join Anonymous Session',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Enter the session code shared by the session creator, or scan the QR code.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),

          // Session key input
          TextField(
            controller: _sessionKeyController,
            decoration: const InputDecoration(
              labelText: 'Session Code or Key',
              hintText: 'HUSH-XXXXX or paste full key',
              prefixIcon: Icon(Icons.vpn_key),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppTheme.spacing16),

          // QR scan button
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _showScanner = true;
              });
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code'),
          ),
          const SizedBox(height: AppTheme.spacing24),

          // Nickname input
          TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              labelText: 'Your Nickname (Optional)',
              hintText: 'How others will see you',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: AppTheme.spacing32),

          // Join button
          ElevatedButton(
            onPressed: _isJoining ? null : _joinSession,
            child: _isJoining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Join Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanner() {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null) {
                  setState(() {
                    _sessionKeyController.text = code;
                    _showScanner = false;
                  });
                }
              }
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showScanner = false;
                });
              },
              child: const Text('Cancel'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _joinSession() async {
    final sessionKey = _sessionKeyController.text.trim();
    if (sessionKey.isEmpty) {
      _showError('Please enter a session code or key');
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      final serviceValue = ref.read(anonymousSessionServiceProvider);
      if (!serviceValue.hasValue) {
        throw Exception('Service not available');
      }
      final service = serviceValue.value!;

      final params = JoinSessionParams(
        sessionKey: sessionKey,
        nickname: _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
      );

      final result = await service.joinSession(params: params);

      if (!mounted) return;

      if (result.isSuccess) {
        final (session, localState) = result.valueOrNull!;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                SessionLobbyScreen(session: session, localState: localState),
          ),
        );
      } else {
        _showError(result.errorOrNull!.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.gray800),
    );
  }
}
