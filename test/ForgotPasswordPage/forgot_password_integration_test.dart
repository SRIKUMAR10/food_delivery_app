import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/Buyer Bloc Architecture/ForgotPasswordPage/ForgotPasswordPage_UI.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ForgotPasswordScreenUI(),
    );
  }

  group('ForgotPasswordScreen Integration Tests', () {
    testWidgets('successful reset password flow', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      final submitButton = find.text('Submit');

      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      
      // Pump frames until the mocked 2 second delay finishes and the navigation occurs
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Upon success, it navigates to FoodGoLoginScreenUI, removing this screen
      expect(find.byType(ForgotPasswordScreenUI), findsNothing);
    });
  });
}
