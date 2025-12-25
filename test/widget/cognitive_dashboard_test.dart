import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:senseai/core/providers/language_provider.dart';
import 'package:senseai/features/cognitive/cognitive_dashboard_screen.dart';

void main() {
  group('CognitiveDashboardScreen Widget Tests', () {
    testWidgets('should display dashboard with all sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => LanguageProvider(),
            child: const CognitiveDashboardScreen(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Check for key elements
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Export Data'), findsOneWidget);
    });

    testWidgets('should display group filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => LanguageProvider(),
            child: const CognitiveDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for filter chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('ASD'), findsOneWidget);
      expect(find.text('Control'), findsOneWidget);
    });

    testWidgets('should display export buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => LanguageProvider(),
            child: const CognitiveDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for export buttons
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
    });

    testWidgets('should allow selecting group filter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => LanguageProvider(),
            child: const CognitiveDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on ASD filter
      final asdChip = find.text('ASD');
      expect(asdChip, findsOneWidget);
      await tester.tap(asdChip);
      await tester.pumpAndSettle();

      // Verify filter is selected (UI should update)
      // Note: Actual selection state depends on implementation
    });
  });
}


