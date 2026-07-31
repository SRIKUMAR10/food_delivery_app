import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_ui.dart';

void main() {
  group('Delivery Pickup Confirmation Integration Flow', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryPickupConfirmationPage(orderId: '#ORD12345'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('loads pickup confirmation details end-to-end', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('#ORD12345'), findsWidgets);
      expect(find.text('Green Mart'), findsOneWidget);
      expect(find.text('Mike Johnson'), findsOneWidget);
      expect(find.text('12:05 PM'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
    });

    testWidgets('progresses from confirmed state to delivery started', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      final startButton = find.byKey(const Key('dp_pickup_start_delivery'));
      expect(startButton, findsOneWidget);

      await tester.tap(startButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Delivery Started'), findsWidgets);
      expect(find.text('Start Delivery'), findsNothing);
      expect(find.byKey(const Key('dp_pickup_start_delivery')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispatches customer quick actions without crashing', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('dp_pickup_call_customer')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('dp_pickup_whatsapp')));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
