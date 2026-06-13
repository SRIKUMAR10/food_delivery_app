import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/Seller Bloc Architecture/Seller_SignUpPage/Seller_SignUpPage_UI.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: SellerSignUpScreenUI(),
    );
  }

  group('SellerSignUpScreen Integration Tests', () {
    testWidgets('renders correctly and takes input', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final signUpButton = find.text('Sign Up');

      await tester.enterText(nameField, 'John Doe');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      expect(signUpButton, findsOneWidget);
      expect(nameField, findsOneWidget);
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      // Not tapping submit to avoid initializing real firebase app in pure tests
    });
  });
}
