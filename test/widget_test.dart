import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lib_management/main.dart';
import 'package:lib_management/widgets/login.dart';

void main() {
  testWidgets('MyHomePage displays Alpha Version button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyHomePage(title: 'Test Title'),
      ),
    );

    // Verify that the Alpha Version button is displayed
    expect(find.text('This is Alpha Version '), findsOneWidget);

    // Tap the Alpha Version button
    await tester.tap(find.text('This is Alpha Version '));
    await tester.pumpAndSettle();

    // Verify that the LoginBodyScreen is pushed to the navigator
    expect(find.byType(LoginBodyScreen), findsOneWidget);
  });




  testWidgets('LoginBodyScreen displays login form', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginBodyScreen(),
      ),
    );

    // Verify that the email field is displayed
    expect(find.byKey(const Key('email')), findsOneWidget);

    // Verify that the password field is displayed
    expect(find.byKey(const Key('password')), findsOneWidget);

    // Verify that the submit button is displayed
    expect(find.text('Submit'), findsOneWidget);
  });
}
