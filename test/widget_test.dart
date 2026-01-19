// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emergency_police_call_app/main.dart';

void main() {
  testWidgets('App shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EmergencyApp());

    // Verify that the Login app bar and default login info are present.
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    expect(find.textContaining('Default Login'), findsOneWidget);

    // The login button should be present and labeled 'Login'.
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}
