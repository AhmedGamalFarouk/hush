import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacing16),
            const Text(
              'Last updated: November 22, 2025\n\n'
              '1. Acceptance of Terms\n'
              'By accessing or using Hush, you agree to be bound by these Terms of Service.\n\n'
              '2. Use of Service\n'
              'You agree to use Hush only for lawful purposes and in accordance with these Terms.\n\n'
              '3. User Accounts\n'
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.\n\n'
              '4. Prohibited Conduct\n'
              'You agree not to use Hush to transmit any content that is illegal, harmful, or violates the rights of others.\n\n'
              '5. Disclaimer of Warranties\n'
              'Hush is provided "as is" without warranty of any kind.\n\n'
              '6. Limitation of Liability\n'
              'We shall not be liable for any indirect, incidental, special, consequential, or punitive damages.\n\n'
              '7. Changes to Terms\n'
              'We reserve the right to modify these Terms at any time.',
            ),
          ],
        ),
      ),
    );
  }
}
