import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_ui.dart';
import '../helpers/delivery_test_utils.dart';

class MockDeliveryOrdersPageBloc
    extends MockBloc<DeliveryOrdersPageEvent, DeliveryOrdersPageState>
    implements DeliveryOrdersPageBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupDeliveryTestChannels();

  late MockDeliveryOrdersPageBloc mockBloc;

  const testOrderWithFullCustomerDetails = DeliveryOrderCardModel(
    orderId: 'ORD_REAL_001',
    customerName: 'Arun Kumar',
    restaurantName: 'Ahbi food restaurants',
    pickupAddress: 'Bhavani, Erode, Tamil Nadu, 638300, India',
    deliveryAddress: '12, Gandhi Nagar, Bhavani, Erode, Tamil Nadu 638300',
    customerArea: 'Gandhi Nagar, Bhavani',
    phoneNumber: '+91 9876543210',
    amount: 349.00,
    itemsCount: 2,
    status: DeliveryOrderStatus.active,
    distance: 3.5,
    time: '12:30 PM',
    paymentType: 'Cash on Delivery',
    customerId: 'cust_uid_123',
    sellerId: 'seller_uid_456',
  );

  const testAvailableOrder = DeliveryOrderCardModel(
    orderId: 'ORD_AVAIL_002',
    customerName: 'Karthik Raja',
    restaurantName: 'Saravana Bhavan',
    pickupAddress: 'Perundurai Road, Erode',
    deliveryAddress: '45, Anna Nagar, Erode 638001',
    customerArea: 'Anna Nagar, Erode',
    phoneNumber: '+91 9123456780',
    amount: 520.00,
    itemsCount: 3,
    status: DeliveryOrderStatus.pending,
    distance: 4.2,
    time: '01:00 PM',
    paymentType: 'Online',
    customerId: 'cust_uid_789',
    sellerId: 'seller_uid_101',
    isAvailable: true,
    assignmentStatus: 'available',
  );

  setUp(() {
    mockBloc = MockDeliveryOrdersPageBloc();
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildTestApp(DeliveryOrdersPageState state) {
    when(() => mockBloc.state).thenReturn(state);
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(state));

    return MaterialApp(
      home: Scaffold(
        body: DeliveryOrdersPage(bloc: mockBloc),
      ),
    );
  }

  group('Delivery Orders - Customer Details & Real-Time Actions', () {
    testWidgets('Renders real customer name, full delivery address, and phone badge on active order card',
        (tester) async {
      setDesktopSize(tester);
      const state = DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: [testOrderWithFullCustomerDetails],
        filteredOrders: [testOrderWithFullCustomerDetails],
      );

      await tester.pumpWidget(buildTestApp(state));
      await tester.pump();

      // Customer name and Restaurant name
      expect(find.text('Arun Kumar'), findsWidgets);
      expect(find.text('Ahbi food restaurants'), findsWidgets);

      // Pickup and Delivery addresses
      expect(find.text('Bhavani, Erode, Tamil Nadu, 638300, India'), findsWidgets);
      expect(find.text('12, Gandhi Nagar, Bhavani, Erode, Tamil Nadu 638300'), findsWidgets);

      // Customer phone badge
      expect(find.text('+91 9876543210'), findsWidgets);
    });

    testWidgets('Renders customer details and area on available orders card',
        (tester) async {
      setDesktopSize(tester);
      const state = DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: [testAvailableOrder],
        filteredOrders: [testAvailableOrder],
      );

      await tester.pumpWidget(buildTestApp(state));
      await tester.pump();

      expect(find.text('Karthik Raja'), findsWidgets);
      expect(find.text('Saravana Bhavan'), findsWidgets);
      expect(find.text('45, Anna Nagar, Erode 638001'), findsWidgets);
      expect(find.text('+91 9123456780'), findsWidgets);
    });

    testWidgets('Tapping Call button opens bottom sheet with customer name, phone, and Copy Phone Number action',
        (tester) async {
      setDesktopSize(tester);
      const state = DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: [testOrderWithFullCustomerDetails],
        filteredOrders: [testOrderWithFullCustomerDetails],
      );

      await tester.pumpWidget(buildTestApp(state));
      await tester.pump();

      final callBtn = find.byKey(const Key('dp_orders_call_ORD_REAL_001'));
      expect(callBtn, findsOneWidget);

      await tester.tap(callBtn);
      await tester.pumpAndSettle();

      // Modal Bottom Sheet appears
      expect(find.text('Arun Kumar'), findsWidgets);
      expect(find.text('+91 9876543210'), findsWidgets);
      expect(find.text('Call Customer'), findsOneWidget);
      expect(find.text('Copy Phone Number'), findsOneWidget);

      // Tap Copy Phone Number
      await tester.tap(find.text('Copy Phone Number'));
      await tester.pumpAndSettle();

      // Bottom sheet is closed
      expect(find.text('Call Customer'), findsNothing);
    });
  });
}
