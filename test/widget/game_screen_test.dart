import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:senseai/core/providers/language_provider.dart';
import 'package:senseai/data/models/child.dart';
import 'package:senseai/features/assessment/game_screen.dart';

void main() {
  group('GameScreen Widget Tests', () {
    final testChild = Child(
      id: 'test-child-id',
      childCode: 'TEST001',
      name: 'Test Child',
      dateOfBirth: DateTime(2020, 1, 1),
      ageInMonths: 48,
      gender: 'male',
      language: 'en',
      age: 4.0,
      createdAt: DateTime.now(),
      group: ChildGroup.typicallyDeveloping,
      diagnosisSource: 'Test Hospital',
    );

    testWidgets('should display game screen for color-shape game',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => LanguageProvider(),
            child: GameScreen(
              child: testChild,
              gameType: 'color-shape',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify game screen is displayed
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('should display game screen for frog-jump game',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => LanguageProvider(),
            child: GameScreen(
              child: testChild,
              gameType: 'frog-jump',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(GameScreen), findsOneWidget);
    });
  });
}


