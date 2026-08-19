import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_ui.dart';

class MockDeliveryOrderHistoryPageBloc
    extends MockBloc<DeliveryOrderHistoryPageEvent, DeliveryOrderHistoryPageState>
    implements DeliveryOrderHistoryPageBloc {}

const order1 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1001',
  customerName: 'Priya Sharma',
  phoneNumber: '9840112233',
  pickupAddress: '42 Anna Salai, Chennai',
  dropAddress: '21 MG Road, Velachery',
  dateLabel: 'May 22, 2025 • 10:30',
  epochSeconds: 1747909800,
  distanceKm: 2.4,
  amount: 486.50,
  status: DeliveryOrderHistoryStatus.completed,
  paymentType: 'COD',
);

const order2 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1002',
  customerName: 'Arun Prakash',
  phoneNumber: '9884499001',
  pickupAddress: '108 Greams Road, Nungambakkam',
  dropAddress: '7 Lake View Road, Adyar',
  dateLabel: 'May 21, 2025 • 11:42',
  epochSeconds: 1747827720,
  distanceKm: 4.1,
  amount: 732.00,
  status: DeliveryOrderHistoryStatus.pending,
  paymentType: 'Online',
);

const allOrders = [order1, order2];

const loadedState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.loaded,
  orders: allOrders,
  filteredOrders: allOrders,
  pageOrders: allOrders,
  stats: DeliveryOrderHistoryStats(
    totalOrders: 2,
    completedCount: 1,
    cancelledCount: 0,
    pendingCount: 1,
    totalEarnings: 1218.50,
    totalOrdersDelta: 12.5,
    earningsDelta: 18.6,
  ),
  page: 1,
  pageSize: 10,
);

void main() {
  late MockDeliveryOrderHistoryPageBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const DeliveryOrderHistoryInitEvent());
    registerFallbackValue(const DeliveryOrderHistoryRefreshEvent());
    registerFallbackValue(const DeliveryOrderHistorySearchChangedEvent(''));
    registerFallbackValue(
      const DeliveryOrderHistoryStatusFilterChangedEvent(
        DeliveryOrderHistoryStatusFilter.all,
      ),
    );
    registerFallbackValue(
      const DeliveryOrderHistoryPaymentFilterChangedEvent(
        DeliveryOrderHistoryPaymentFilter.all,
      ),
    );
    registerFallbackValue(const DeliveryOrderHistoryPageChangedEvent(1));
    registerFallbackValue(const DeliveryOrderHistoryPageSizeChangedEvent(10));
    registerFallbackValue(const DeliveryOrderHistoryToggleSidebarEvent());
    registerFallbackValue(const DeliveryOrderHistoryDateRangeChangedEvent());
  });

  setUp(() {
    mockBloc = MockDeliveryOrderHistoryPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C1017),
      ),
      home: Scaffold(
        body: DeliveryOrderHistoryPage(bloc: mockBloc),
      ),
    );
  }

  group('DeliveryOrderHistoryPage State Restoration Tests', () {
    testWidgets('preserves search query when rebuilding the widget tree',
        (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('dp_oh_search_field')),
        'Priya',
      );
      await tester.pump();

      verify(
        () => mockBloc.add(
          const DeliveryOrderHistorySearchChangedEvent('Priya'),
        ),
      ).called(1);

      when(() => mockBloc.state).thenReturn(
        loadedState.copyWith(searchQuery: 'Priya'),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.byKey(const Key('dp_oh_page')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_oh_search_field')), findsWidgets);
    });

    testWidgets('preserves KPI metric cards across widget rebuilds',
        (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_stat_total')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_earnings')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_completed')), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pump();

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_stat_total')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_earnings')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_completed')), findsOneWidget);
    });

    testWidgets('preserves KPI stats and filter bar across rebuilds',
        (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_stat_total')), findsOneWidget);
      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_status_filter')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_payment_filter')), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pump();

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_stat_total')), findsOneWidget);
      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_status_filter')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_payment_filter')), findsOneWidget);
    });

    testWidgets('preserves pagination footer across widget rebuilds',
        (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_pagination')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_page_1')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_summary')), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pump();

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_pagination')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_page_1')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_summary')), findsOneWidget);
    });

    testWidgets('preserves top bar across widget rebuilds', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_topbar')), findsOneWidget);
      expect(find.text('Order History'), findsWidgets);
      expect(
        find.text('Track and manage all your delivery orders'),
        findsOneWidget,
      );

      await tester.pumpWidget(Container());
      await tester.pump();

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_topbar')), findsOneWidget);
      expect(find.text('Order History'), findsWidgets);
      expect(
        find.text('Track and manage all your delivery orders'),
        findsOneWidget,
      );
    });

    testWidgets('preserves the orders table across widget rebuilds',
        (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_table')), findsOneWidget);
      expect(find.text('ORD-1001'), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pump();

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_table')), findsOneWidget);
      expect(find.text('ORD-1001'), findsOneWidget);
    });
  });
}
