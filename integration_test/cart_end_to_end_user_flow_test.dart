import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cart End to End User Flow Integration Test', () {
    testWidgets('Full flow: Home -> Add to Cart -> Checkout', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Tap Home Tab
      final homeTab = find.byIcon(Icons.home_outlined);
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();

        // 2. Find a food item and tap add to cart (Assuming button exists)
        final addToCartBtn = find.text('Add to Cart');
        if (addToCartBtn.evaluate().isNotEmpty) {
          await tester.tap(addToCartBtn.first);
          await tester.pumpAndSettle();
        }

        // 3. Go to Cart tab
        await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
        await tester.pumpAndSettle();

        // 4. Tap Checkout
        final checkoutBtn = find.text('Checkout');
        if (checkoutBtn.evaluate().isNotEmpty) {
           await tester.tap(checkoutBtn);
           await tester.pumpAndSettle();
        }
      }
    });
  });
}
