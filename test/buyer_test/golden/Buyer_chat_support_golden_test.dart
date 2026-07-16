import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_ui.dart';

void main() {
  group('BuyerChatSupportPage Golden Tests', () {
    // Note: Golden tests require a 'flutter_test_config.dart' file in the root of the test directory
    // to load fonts and assets correctly.

    testWidgets('Initial loading state matches golden file', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: BuyerChatSupportPage()));

      await expectLater(
        find.byType(BuyerChatSupportPage),
        matchesGoldenFile('goldens/buyer_chat_support_loading.png'),
      );
    });

    testWidgets('Loaded state with messages matches golden file', (
      WidgetTester tester,
    ) async {
      // We pump the widget and then wait for the simulated load to complete.
      await tester.pumpWidget(const MaterialApp(home: BuyerChatSupportPage()));
      await tester.pumpAndSettle(
        const Duration(seconds: 2),
      ); // Wait for BLoC to load

      // Enter a message to test the UI with user and support messages
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Wait for reply

      await expectLater(
        find.byType(BuyerChatSupportPage),
        matchesGoldenFile('goldens/buyer_chat_support_loaded.png'),
      );
    });
  });
}
