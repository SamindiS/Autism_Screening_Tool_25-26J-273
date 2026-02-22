// RRB Detection App - Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rrb_detection_app/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RRBDetectionApp());

    // Verify that the splash screen is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
