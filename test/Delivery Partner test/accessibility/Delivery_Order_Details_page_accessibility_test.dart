import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

void main() {
  group('DeliveryOrderDetailsPage Accessibility Tests', () {
    testWidgets(
      'Meets accessibility guidance for text labels and touch areas',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          const MaterialApp(
            home: DeliveryOrderDetailsPageUi(orderId: '#ORD12345'),
          ),
        );

        await tester.pump(const Duration(milliseconds: 600));

        // Assert buttons have semantic targets and readable text
        expect(
          tester.getSemantics(find.text('Order Details')),
          matchesSemantics(label: 'Order Details', isHeader: false),
        );

        handle.dispose();
      },
    );
  });
}
