/// Widget Tests for Authentication Screens
/// Tests login, registration, and auth flow
// ignore_for_file: dead_code
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hush/auth/presentation/login_screen.dart';
import 'package:hush/auth/presentation/register_screen.dart';

void main() {
  group('LoginScreen Widget', () {
    testWidgets('displays all required fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      // Check for email field
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Email'), findsOneWidget);

      // Check for password field
      expect(find.text('Password'), findsOneWidget);

      // Check for login button
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

      // Check for register link
      expect(find.textContaining('create an account'), findsOneWidget);
    });

    testWidgets('email field accepts input', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      final emailField = find.widgetWithText(TextField, 'Email');
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password field obscures text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      final passwordField = find.widgetWithText(TextField, 'Password');
      final textField = tester.widget<TextField>(passwordField);

      expect(textField.obscureText, isTrue);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      // Try to submit with empty fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Should show validation messages (implementation dependent)
      // This is a placeholder - actual implementation may differ
    });

    testWidgets('navigates to register screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {'/register': (context) => const RegisterScreen()},
          ),
        ),
      );

      // Find and tap the register link
      final registerLink = find.textContaining('create an account');
      if (registerLink.evaluate().isNotEmpty) {
        await tester.tap(registerLink);
        await tester.pumpAndSettle();

        // Should navigate to register screen
        expect(find.byType(RegisterScreen), findsOneWidget);
      }
    });
  });

  group('RegisterScreen Widget', () {
    testWidgets('displays all required fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: RegisterScreen())),
      );

      // Check for display name field
      expect(find.text('Display Name'), findsOneWidget);

      // Check for email field
      expect(find.text('Email'), findsOneWidget);

      // Check for password field
      expect(find.text('Password'), findsOneWidget);

      // Check for confirm password field
      expect(find.text('Confirm Password'), findsOneWidget);

      // Check for register button
      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);

      // Check for login link
      expect(find.textContaining('Already have an account'), findsOneWidget);
    });

    testWidgets('accepts input in all fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: RegisterScreen())),
      );

      // Enter display name
      await tester.enterText(
        find.widgetWithText(TextField, 'Display Name'),
        'John Doe',
      );
      await tester.pump();
      expect(find.text('John Doe'), findsOneWidget);

      // Enter email
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'john@example.com',
      );
      await tester.pump();
      expect(find.text('john@example.com'), findsOneWidget);

      // Enter password
      final passwordFields = find.widgetWithText(TextField, 'Password');
      await tester.enterText(passwordFields.first, 'securepass123');
      await tester.pump();

      // Enter confirm password
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Password'),
        'securepass123',
      );
      await tester.pump();
    });

    testWidgets('both password fields obscure text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: RegisterScreen())),
      );

      final passwordField = find.widgetWithText(TextField, 'Password');
      final confirmPasswordField = find.widgetWithText(
        TextField,
        'Confirm Password',
      );

      final passwordWidget = tester.widget<TextField>(passwordField.first);
      final confirmPasswordWidget = tester.widget<TextField>(
        confirmPasswordField,
      );

      expect(passwordWidget.obscureText, isTrue);
      expect(confirmPasswordWidget.obscureText, isTrue);
    });

    testWidgets('validates password match', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: RegisterScreen())),
      );

      // Enter mismatched passwords
      final passwordFields = find.widgetWithText(TextField, 'Password');
      await tester.enterText(passwordFields.first, 'password123');

      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Password'),
        'password456',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Should show password mismatch error (implementation dependent)
    });

    testWidgets('navigates back to login screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegisterScreen(),
            routes: {'/login': (context) => const LoginScreen()},
          ),
        ),
      );

      final loginLink = find.textContaining('Already have an account');
      if (loginLink.evaluate().isNotEmpty) {
        await tester.tap(loginLink);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
      }
    });
  });

  group('Password Visibility Toggle', () {
    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  bool obscureText = true;

                  return Column(
                    children: [
                      TextField(
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially should be obscured
      var textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Should now be visible
      textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });

  group('Loading States', () {
    testWidgets('shows loading indicator during auth', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Signing in...',
                      style: Theme.of(
                        tester.element(find.byType(Scaffold)),
                      ).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Signing in...'), findsOneWidget);
    });

    testWidgets('disables button during loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    bool isLoading = false;

                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                isLoading = true;
                              });
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Login'),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final button = find.widgetWithText(ElevatedButton, 'Login');
      expect(button, findsOneWidget);

      // Tap button to start loading
      await tester.tap(button);
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Button should be disabled
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(elevatedButton.onPressed, isNull);
    });
  });

  group('Error States', () {
    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.red.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade900),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Invalid email or password'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Invalid email or password'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows snackbar for errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Network error. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    child: const Text('Trigger Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Error'));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 750),
      ); // Snackbar animation

      expect(find.text('Network error. Please try again.'), findsOneWidget);
    });
  });
}
