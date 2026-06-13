import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Since we cannot easily mock Firebase globally for the UI without passing it in
// to BlocProvider directly, integration test for Firebase flows usually requires
// actual Firebase initialization or a dedicated Mock wrapper in main.dart.
// Here we will do a simple render test in integration mode.
import '../../lib/Seller Bloc Architecture/Seller_ForgotPasswordPage/Seller_ForgotPasswordPage_UI.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest() {
    return const MaterialApp(home: SellerForgotPasswordScreenUI());
  }

  group('SellerForgotPasswordScreen Integration Tests', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      final submitButton = find.text('Submit');

      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // We do NOT tap submit here in the integration test because we haven't mocked FirebaseAuth globally
      // which would throw a 'No Firebase App [DEFAULT]' error in a pure test environment without initialization.
      // The Bloc test fully covers the logic flow.
      expect(submitButton, findsOneWidget);
      expect(emailField, findsOneWidget);
    });
  });
}
