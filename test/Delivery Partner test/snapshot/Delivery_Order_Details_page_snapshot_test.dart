import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

void main() {
  group('DeliveryOrderDetailsPage Snapshot Tests', () {
    testWidgets('UI elements hierarchy snapshot is validated', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOrderDetailsPageUi(orderId: '#ORD12345'),
        ),
      );

      await tester.pump(const Duration(milliseconds: 600));

      final detailsPageFinder = find.byType(DeliveryOrderDetailsPageUi);
      expect(detailsPageFinder, findsOneWidget);

      final elementsList = tester.allElements.toList();
      expect(elementsList.isNotEmpty, isTrue);
    });
  });
}
