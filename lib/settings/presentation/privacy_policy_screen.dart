import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacing16),
            const Text(
              'Last updated: November 22, 2025\n\n'
              '1. Introduction\n'
              'Hush is an end-to-end encrypted chat application. We prioritize your privacy and security above all else.\n\n'
              '2. Data Collection\n'
              'We collect the minimum amount of data necessary to operate the service:\n'
              '- Account information (email, username)\n'
              '- Encrypted messages (we cannot read them)\n'
              '- Encrypted keys\n\n'
              '3. End-to-End Encryption\n'
              'All messages and media are end-to-end encrypted. This means only you and the recipient can read them. We do not have access to your private keys or message content.\n\n'
              '4. Data Storage\n'
              'Your encrypted data is stored on Supabase servers. Your private keys are stored securely on your device.\n\n'
              '5. Contact Us\n'
              'If you have any questions about this Privacy Policy, please contact us.',
            ),
          ],
        ),
      ),
    );
  }
}
