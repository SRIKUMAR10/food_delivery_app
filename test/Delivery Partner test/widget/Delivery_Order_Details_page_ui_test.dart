import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

class _FakeDeliveryOrderDetailsBloc extends Fake
    implements DeliveryOrderDetailsPageBloc {
  @override
  DeliveryOrderDetailsPageState get state => successState;

  @override
  Stream<DeliveryOrderDetailsPageState> get stream =>
      Stream.fromIterable([successState]);
}

const testOrder = OrderModel(
  id: '#ORD12345',
  customerPhone: '+1234567890',
  merchantPhone: '+0987654321',
  pickupAddress: '123 Pickup St',
  dropoffAddress: '456 Dropoff Ave',
  distance: 5.2,
  orderValue: 620.00,
  earnings: 150.00,
  status: 'Pending',
);

const successState = DeliveryOrderDetailsPageState(
  status: OrderDetailsStatus.success,
  order: testOrder,
);

void setDesktopSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  group('DeliveryOrderDetailsPageUi Widget Tests', () {
    testWidgets(
      'Renders DeliveryOrderDetailsPageUi correctly with order detail card',
      (WidgetTester tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(
          MaterialApp(
            home: DeliveryOrderDetailsPageUi(
              orderId: '#ORD12345',
              bloc: _FakeDeliveryOrderDetailsBloc(),
            ),
          ),
        );

        await tester.pump();

        // Verify header / title presence
        expect(find.text('LOGISTICS ORDER PANEL'), findsOneWidget);

        // Verify elements loaded - check for actual UI content
        expect(find.text('Customer Details'), findsOneWidget);
        expect(find.text('PENDING'), findsOneWidget);
        expect(find.text('Pickup Details (Merchant)'), findsOneWidget);
        expect(find.text('Drop Details (Customer)'), findsOneWidget);
      },
    );
  });
}
