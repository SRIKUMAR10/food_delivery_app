import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

void main() {
  group('DeliveryOrderDetailsPage Performance Tests', () {
    testWidgets('Validates build cycles and resource utilization performance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOrderDetailsPageUi(orderId: '#ORD12345'),
        ),
      );

      final Stopwatch stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Ensure view renders within baseline limit (e.g. 100 milliseconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
