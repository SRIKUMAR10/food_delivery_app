import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_ui.dart';

class MockDeliveryOrdersRepository extends Mock
    implements DeliveryOrdersRepositoryBase {}

const pendingOrder = DeliveryOrderCardModel(
  orderId: 'ORD12345',
  customerName: 'Priya Sharma',
  restaurantName: 'Green Bowl Kitchen',
  pickupAddress: '42 Anna Salai, Chennai',
  deliveryAddress: '21 MG Road, Velachery',
  amount: 486.50,
  itemsCount: 3,
  status: DeliveryOrderStatus.pending,
  distance: 2.4,
  time: '10:30 AM',
  paymentType: 'Cash',
);

const sampleOrders = [pendingOrder];

void main() {
  late MockDeliveryOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockDeliveryOrdersRepository();
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(
        body: DeliveryOrdersPage(
          repository: mockRepository,
          service: DeliveryOrdersService(),
        ),
      ),
    );
  }

  group('DeliveryOrdersPage Error Handling Tests', () {
    testWidgets('shows fallback error UI when initialization fails', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.fetchOrders(),
      ).thenThrow(Exception('Server unreachable'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_orders_error')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_error')),
          matching: find.text('Server unreachable'),
        ),
        findsOneWidget,
      );
      expect(
        find.text('Something went wrong while loading your orders.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_orders_retry')), findsOneWidget);
    });

    testWidgets('retry recovers and loads the orders', (tester) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.fetchOrders()).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          throw Exception('Temporary failure');
        }
        return sampleOrders;
      });

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_orders_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_orders_retry')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_orders_error')), findsNothing);
      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
    });

    testWidgets('shows empty state and refresh recovers orders', (
      tester,
    ) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.fetchOrders()).thenAnswer((_) async {
        calls++;
        if (calls == 1) return const <DeliveryOrderCardModel>[];
        return sampleOrders;
      });

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_orders_empty')), findsOneWidget);
      expect(find.text('No orders available'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_orders_refresh')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_orders_empty')), findsNothing);
      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
    });

    testWidgets('shows a generic message when a status update fails', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.fetchOrders(),
      ).thenAnswer((_) async => sampleOrders);
      when(
        () => mockRepository.updateOrderStatus(
          'ORD12345',
          DeliveryOrderStatus.active,
        ),
      ).thenThrow(Exception('Internal backend token failure'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('dp_orders_update_ORD12345')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Failed to update order status. Please try again.'),
        findsOneWidget,
      );
      expect(find.textContaining('token failure'), findsNothing);
    });
  });
}
