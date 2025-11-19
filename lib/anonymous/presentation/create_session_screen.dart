/// Create Anonymous Session Screen
/// Allows users to create a new anonymous shared-key chat session
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../models/anonymous_session.dart';
import '../services/anonymous_session_service.dart';
import 'session_lobby_screen.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() =>
      _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  Duration _expiry = const Duration(hours: 24);
  int _maxParticipants = 10;
  String? _nickname;
  bool _isCreating = false;

  AnonymousSession? _createdSession;
  LocalSessionState? _localState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Anonymous Session')),
      body: _createdSession == null
          ? _buildSettingsForm()
          : _buildSessionCreated(),
    );
  }

  Widget _buildSettingsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                        'Anonymous Session',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Create a temporary encrypted chat without account registration.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Your Nickname (Optional)',
              hintText: 'How others will see you',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (value) => _nickname = value.isEmpty ? null : value,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Expiry',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  Wrap(
                    spacing: AppTheme.spacing8,
                    children: [
                      _buildExpiryChip('1 hour', const Duration(hours: 1)),
                      _buildExpiryChip('6 hours', const Duration(hours: 6)),
                      _buildExpiryChip('24 hours', const Duration(hours: 24)),
                      _buildExpiryChip('7 days', const Duration(days: 7)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maximum Participants: $_maxParticipants',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Slider(
                    value: _maxParticipants.toDouble(),
                    min: 2,
                    max: 50,
                    divisions: 48,
                    label: _maxParticipants.toString(),
                    onChanged: (value) {
                      setState(() {
                        _maxParticipants = value.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing32),
          ElevatedButton(
            onPressed: _isCreating ? null : _createSession,
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryChip(String label, Duration duration) {
    final isSelected = _expiry == duration;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _expiry = duration;
          });
        }
      },
    );
  }

  Widget _buildSessionCreated() {
    if (_createdSession == null || _localState == null) {
      return const SizedBox.shrink();
    }

    final session = _createdSession!;
    final serviceAsync = ref.watch(anonymousSessionServiceProvider);

    return serviceAsync.when(
      data: (service) {
        final qrData = service.generateQRData(session);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppTheme.success.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.success),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Session Created!',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppTheme.success),
                            ),
                            Text(
                              'Share the key or QR code',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing24),
                  child: Column(
                    children: [
                      Text(
                        'Session Code',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.gray600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        session.humanCode ?? 'N/A',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _copyToClipboard(session.humanCode ?? ''),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Code'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing24),
                  child: Column(
                    children: [
                      Text(
                        'Scan to Join',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.gray600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareSession,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _enterSession,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Enter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Future<void> _createSession() async {
    setState(() {
      _isCreating = true;
    });

    try {
      final serviceValue = ref.read(anonymousSessionServiceProvider);
      if (!serviceValue.hasValue) {
        throw Exception('Service not available');
      }
      final service = serviceValue.value!;

      final params = CreateSessionParams(
        expiry: _expiry,
        maxParticipants: _maxParticipants,
        nickname: _nickname,
      );

      final result = await service.createSession(params: params);

      if (!mounted) return;

      if (result.isSuccess) {
        final (session, localState) = result.valueOrNull!;
        setState(() {
          _createdSession = session;
          _localState = localState;
        });
      } else {
        _showError(result.errorOrNull!.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  Future<void> _shareSession() async {
    if (_createdSession == null) return;
    final session = _createdSession!;
    await Share.share('Join my Hush session!\nCode: ${session.humanCode}');
  }

  void _enterSession() {
    if (_createdSession == null || _localState == null) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SessionLobbyScreen(
          session: _createdSession!,
          localState: _localState!,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.gray800),
    );
  }
}
