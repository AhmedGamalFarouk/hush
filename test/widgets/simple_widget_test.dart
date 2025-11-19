/// Simple Widget Tests - Core Components
/// Basic tests for key UI widgets
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hush/chat/models/message_reaction.dart';
import 'package:hush/chat/presentation/widgets/message_reactions.dart';

void main() {
  group('MessageReactions Widget Tests', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MessageReactions(
                reactions: const [],
                onReactionTap: (emoji) {},
                onAddReaction: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MessageReactions), findsOneWidget);
    });

    testWidgets('displays add reaction button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MessageReactions(
                reactions: const [],
                onReactionTap: (emoji) {},
                onAddReaction: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add_reaction_outlined), findsOneWidget);
    });

    testWidgets('displays single reaction', (tester) async {
      final reactions = [
        const ReactionSummary(
          emoji: '👍',
          count: 1,
          userIds: ['user1'],
          reactedByMe: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MessageReactions(
                reactions: reactions,
                onReactionTap: (emoji) {},
                onAddReaction: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('👍 1'), findsOneWidget);
    });

    testWidgets('handles add button tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MessageReactions(
                reactions: const [],
                onReactionTap: (emoji) {},
                onAddReaction: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_reaction_outlined));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('Basic UI Components', () {
    testWidgets('Scaffold renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Test'))),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Loading indicator displays', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Empty state renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64),
                  SizedBox(height: 16),
                  Text('No items'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No items'), findsOneWidget);
    });
  });

  group('Interactive Elements', () {
    testWidgets('Button tap works', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('TextField accepts input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TextField(controller: controller)),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test input');
      await tester.pump();

      expect(controller.text, equals('test input'));
    });

    testWidgets('Shows SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test message')),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Test message'), findsOneWidget);
    });
  });

  group('Modal Sheets', () {
    testWidgets('Shows bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => const SizedBox(
                        height: 200,
                        child: Center(child: Text('Sheet Content')),
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Content'), findsOneWidget);
    });

    testWidgets('Closes bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        height: 200,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsNothing);
    });
  });
}
