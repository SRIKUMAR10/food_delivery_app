import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:food_delivery_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Chat Support Flow Integration Test', () {
    testWidgets('User can navigate to support chat and send a message', (
      WidgetTester tester,
    ) async {
      // This test assumes the user is already logged in and on the main navigation screen.
      // A setup file would typically handle login.
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find and tap the support navigation item
      final supportNavItem = find.byIcon(Icons.support_agent_outlined);
      expect(supportNavItem, findsOneWidget);
      await tester.tap(supportNavItem);
      await tester.pumpAndSettle();

      // Verify we are on the support page
      expect(find.text('Support Chat'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Send a message
      await tester.enterText(
        find.byType(TextField),
        'I have an issue with my order.',
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify the sent message and the reply appear
      expect(find.text('I have an issue with my order.'), findsOneWidget);
      expect(
        find.text('Thank you for your message. We are looking into it.'),
        findsOneWidget,
      );
    });
  });
}
