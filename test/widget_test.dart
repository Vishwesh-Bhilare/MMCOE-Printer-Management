import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:student_printing_system/main.dart';
import 'firebase_test_config.dart';

void main() {
  setUpAll(() async {
    // Initialize Firebase mock setup
    await setupFirebaseMocks();
  });

  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // Build the main app
    await tester.pumpWidget(const PrintManagerApp());

    await tester.pumpAndSettle();

    // Verify that MaterialApp is present
    expect(find.byType(MaterialApp), findsOneWidget);

    // Check if the login screen title and button appear
    expect(find.text('Student Printing System'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    // Build the main app
    await tester.pumpWidget(const PrintManagerApp());

    await tester.pumpAndSettle();

    // Try to tap on the LOGIN button (without filling form)
    final loginButton = find.text('LOGIN');
    expect(loginButton, findsOneWidget);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Expect the app to stay on the login screen since no input was entered
    expect(find.text('Student Printing System'), findsOneWidget);
  });
}
