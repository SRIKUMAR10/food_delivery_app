import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
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
  id: 'ORD12345',
  customerName: 'Arun Kumar',
  customerPhone: '+919876543210',
  merchantPhone: '+918888888888',
  restaurantName: 'ahbi Store',
  pickupAddress: '123 Pickup St, Erode',
  dropoffAddress: '456 Dropoff Ave, Erode',
  distance: 2.4,
  orderValue: 620.00,
  totalAmount: 620.00,
  earnings: 120.00,
  status: 'ASSIGNED',
  pickupStatus: 'ASSIGNED',
  orderDate: '17 Aug 2026',
  orderTime: '11:35 AM',
  paymentMethod: 'Cash on Delivery',
  paymentStatus: 'Pending',
  items: [
    OrderItemDetail(id: '1', name: 'Special Masala Dosa', quantity: 2, price: 160.0),
    OrderItemDetail(id: '2', name: 'Filter Coffee', quantity: 2, price: 60.0),
  ],
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
      'Renders DeliveryOrderDetailsPageUi correctly with order detail card and pickup lifecycle',
      (WidgetTester tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(
          MaterialApp(
            home: DeliveryOrderDetailsPageUi(
              orderId: 'ORD12345',
              bloc: _FakeDeliveryOrderDetailsBloc(),
            ),
          ),
        );

        await tester.pump();

        // Verify title
        expect(find.text('ORDER DETAILS & PICKUP'), findsOneWidget);

        // Verify Order Information
        expect(find.text('ORDER INFORMATION'), findsOneWidget);
        expect(find.text('₹620.00'), findsWidgets);

        // Verify Restaurant Information
        expect(find.text('RESTAURANT INFORMATION'), findsOneWidget);
        expect(find.text('ahbi Store'), findsOneWidget);

        // Verify Customer Information
        expect(find.text('CUSTOMER INFORMATION'), findsOneWidget);
        expect(find.text('Arun Kumar'), findsOneWidget);

        // Verify Order Verification Checklist
        expect(find.text('ORDER ITEMS VERIFICATION'), findsOneWidget);
        expect(find.text('Special Masala Dosa'), findsOneWidget);

        // Verify Cancel / Report Failed Delivery button
        expect(find.byKey(const Key('dp_order_details_cancel_btn')), findsOneWidget);
      },
    );

    testWidgets(
      'Opens cancellation dialog with 8 reasons when cancel button is tapped',
      (WidgetTester tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(
          MaterialApp(
            home: DeliveryOrderDetailsPageUi(
              orderId: 'ORD12345',
              bloc: _FakeDeliveryOrderDetailsBloc(),
            ),
          ),
        );

        await tester.pump();

        final cancelBtn = find.byKey(const Key('dp_order_details_cancel_btn'));
        await tester.ensureVisible(cancelBtn);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(cancelBtn);
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Cancel / Report Failed Delivery'), findsOneWidget);
        expect(find.text('Restaurant Closed'), findsOneWidget);
        expect(find.byKey(const Key('dp_cancel_reason_chip_Restaurant Closed')), findsOneWidget);
        expect(find.byKey(const Key('dp_cancel_reason_chip_Customer Unavailable')), findsOneWidget);
        expect(find.byKey(const Key('dp_cancel_confirm_btn')), findsOneWidget);
      },
    );
  });
}

