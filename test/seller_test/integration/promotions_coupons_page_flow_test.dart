import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PromotionsCouponsPage Integration Flow', () {
    testWidgets('Full flow: Load -> Add Coupon -> View', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PromotionsCouponsPage(sellerId: 'test_seller'),
      ));

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify page loaded (should see "Coupons & Offers" title)
      expect(find.text('Coupons & Offers'), findsWidgets);

      // Tap FAB to add coupon
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter coupon details
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'WINTER20');
      await tester.enterText(textFields.at(1), 'Winter special discount');
      await tester.enterText(textFields.at(2), '20');

      // Save coupon
      await tester.tap(find.text('Save Coupon'));
      await tester.pumpAndSettle(const Duration(seconds: 2)); // wait for mock network delay

      // Verify the new coupon code appears on screen
      expect(find.text('WINTER20'), findsOneWidget);
    });
  });
}
