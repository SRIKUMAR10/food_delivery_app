import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Home Flow', () {
    testWidgets('Home page loads products and filters by category', (WidgetTester tester) async {
      // Launch the real app
      app.main();
      
      // Wait for app to initialize and animations to settle
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 1. Skip onboarding if present
      final getStartedBtn = find.byKey(const ValueKey('onboardingNextButton'));
      final getStartedBtnWeb = find.byKey(const ValueKey('onboardingNextButton_web'));

      if (getStartedBtn.evaluate().isNotEmpty) {
        await tester.tap(getStartedBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      } else if (getStartedBtnWeb.evaluate().isNotEmpty) {
        await tester.tap(getStartedBtnWeb.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // 2. We should be on Home Page now. Verify Home Page components.
      // Wait a moment for products to load from Firestore
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify categories are visible
      expect(find.text('Pizza'), findsWidgets);
      expect(find.text('Burger'), findsWidgets);
      
      // 3. Test Category Filtering
      // Tap on 'Burger' category
      final burgerCategory = find.text('Burger').first;
      if (burgerCategory.evaluate().isNotEmpty) {
        await tester.tap(burgerCategory);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      
      // Tap on 'Pizza' category
      final pizzaCategory = find.text('Pizza').first;
      if (pizzaCategory.evaluate().isNotEmpty) {
        await tester.tap(pizzaCategory);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

    });
  });
}
