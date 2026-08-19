import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cart Page Flow Integration Test', () {
    testWidgets('navigate to cart and interact with items', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Cart Tab
      final cartTabIcon = find.byIcon(Icons.shopping_cart_outlined);
      if (cartTabIcon.evaluate().isNotEmpty) {
        await tester.tap(cartTabIcon);
        await tester.pumpAndSettle();

        // Verify Cart Page is visible
        expect(find.text('My Cart'), findsWidgets);

        // Assume there is an item in the cart, test increment quantity
        final addIcon = find.byIcon(Icons.add_circle_outline);
        if (addIcon.evaluate().isNotEmpty) {
          await tester.tap(addIcon.first);
          await tester.pumpAndSettle();
          // Total should change, test would assert that
        }
      }
    });
  });
}
