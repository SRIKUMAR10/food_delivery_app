import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

void main() {
  group('Delivery Order Details Integration Flow', () {
    testWidgets('Updates state step-by-step through order lifecycle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOrderDetailsPageUi(orderId: '#ORD12345'),
        ),
      );

      await tester.pump(const Duration(milliseconds: 600));

      // Reached Pickup button trigger
      final reachedBtn = find.text('Reached Pickup');
      expect(reachedBtn, findsOneWidget);
      await tester.tap(reachedBtn);
      await tester.pump(const Duration(milliseconds: 400));

      // Verify state changed to start delivery action
      expect(find.text('Start Delivery'), findsOneWidget);
    });
  });
}
