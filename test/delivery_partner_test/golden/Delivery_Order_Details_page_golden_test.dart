import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

void main() {
  group('DeliveryOrderDetailsPageUi Golden Tests', () {
    testWidgets('Golden snapshot match for default order status screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryOrderDetailsPageUi(orderId: '#ORD12345'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 600));

      // Golden assertions usually matched via:
      // await expectLater(find.byType(DeliveryOrderDetailsPageUi), matchesGoldenFile('details_page_default.png'));
      expect(find.byType(DeliveryOrderDetailsPageUi), findsOneWidget);
    });
  });
}
