import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

void main() {
  group('DeliveryOrderDetailsPageUi Widget Tests', () {
    testWidgets(
      'Renders DeliveryOrderDetailsPageUi correctly with order detail card',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DeliveryOrderDetailsPageUi(orderId: '#ORD12345'),
          ),
        );

        // Verify header / title presence
        expect(find.text('Order Details'), findsOneWidget);

        // Trigger standard rendering lifecycle to resolve initial delayed mock load
        await tester.pump(const Duration(milliseconds: 600));

        // Verify elements loaded
        expect(find.text('Order ID: #ORD12345'), findsOneWidget);
        expect(find.text('Pick Up'), findsOneWidget);
        expect(find.text('Drop Off'), findsOneWidget);
      },
    );
  });
}
