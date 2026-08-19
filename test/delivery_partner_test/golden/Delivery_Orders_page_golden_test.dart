import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_ui.dart';

class MockDeliveryOrdersPageBloc
    extends MockBloc<DeliveryOrdersPageEvent, DeliveryOrdersPageState>
    implements DeliveryOrdersPageBloc {}

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

const activeOrder = DeliveryOrderCardModel(
  orderId: 'ORD12346',
  customerName: 'Arun Prakash',
  restaurantName: 'Spice Route',
  pickupAddress: '108 Greams Road, Nungambakkam',
  deliveryAddress: '7 Lake View Road, Adyar',
  amount: 732.00,
  itemsCount: 4,
  status: DeliveryOrderStatus.active,
  distance: 4.1,
  time: '10:42 AM',
  paymentType: 'Card',
);

const completedOrder = DeliveryOrderCardModel(
  orderId: 'ORD12347',
  customerName: 'Meena Krishnan',
  restaurantName: 'The Pasta Lab',
  pickupAddress: '15 Cathedral Road',
  deliveryAddress: '33 Besant Nagar Main Road',
  amount: 1204.75,
  itemsCount: 6,
  status: DeliveryOrderStatus.completed,
  distance: 5.8,
  time: '11:05 AM',
  paymentType: 'Online',
);

const loadedState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.loaded,
  orders: [pendingOrder, activeOrder, completedOrder],
  filteredOrders: [pendingOrder, activeOrder, completedOrder],
);

void main() {
  late MockDeliveryOrdersPageBloc mockBloc;

  setUp(() {
    mockBloc = MockDeliveryOrdersPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1219),
      ),
      home: Scaffold(body: DeliveryOrdersPage(bloc: mockBloc)),
    );
  }

  group('DeliveryOrdersPage Golden Tests', () {
    testWidgets('renders pixel-perfect dark orders layout on desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byType(DeliveryOrdersPage), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_header')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_search_field')), findsWidgets);
      expect(find.byKey(const Key('dp_orders_tab_all')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
    });

    testWidgets('renders dark theme orders layout on tablet viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_stat_total')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_stat_active')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
    });

    testWidgets('renders dark theme orders layout on mobile viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_header')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_tab_all')), findsOneWidget);
    });

    testWidgets('matches dark theme color palette', (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      final header = tester.widget<Container>(
        find.byKey(const Key('dp_orders_header')),
      );
      final headerDecoration = header.decoration as BoxDecoration;
      expect(headerDecoration.color, const Color(0xFF0D141C));

      final card = tester.widget<AnimatedContainer>(
        find.byKey(const Key('dp_orders_card_ORD12345')),
      );
      final cardDecoration = card.decoration as BoxDecoration;
      expect(cardDecoration.color, const Color(0xFF161B22));

      final root = tester.widget<Container>(
        find.byKey(const Key('dp_orders_page')),
      );
      expect(root.color, const Color(0xFF0D131E));
    });

    testWidgets('renders loading skeleton with dark palette', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(
        const DeliveryOrdersPageState(status: DeliveryOrdersPageStatus.loading),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_loading')), findsOneWidget);
    });
  });
}
