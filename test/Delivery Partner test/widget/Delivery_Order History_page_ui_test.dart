import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_ui.dart';

class MockDeliveryOrderHistoryPageBloc
    extends
        MockBloc<DeliveryOrderHistoryPageEvent, DeliveryOrderHistoryPageState>
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

const order3 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1004',
  customerName: 'Karthik Raja',
  phoneNumber: '9003112220',
  pickupAddress: '2 T Nagar 3rd Main Road',
  dropAddress: '19 Ashok Nagar 1st Avenue',
  dateLabel: 'May 23, 2025 • 16:20',
  epochSeconds: 1748017200,
  distanceKm: 1.2,
  amount: 245.00,
  status: DeliveryOrderHistoryStatus.cancelled,
  paymentType: 'COD',
);

const order4 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1005',
  customerName: 'Divya Nair',
  phoneNumber: '9677008812',
  pickupAddress: '77 EC Road, Sholinganallur',
  dropAddress: '5 Old Mahabalipuram Road',
  dateLabel: 'May 19, 2025 • 20:05',
  epochSeconds: 1747685100,
  distanceKm: 6.4,
  amount: 1890.00,
  status: DeliveryOrderHistoryStatus.completed,
  paymentType: 'Online',
);

const order5 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1006',
  customerName: 'Suresh Babu',
  phoneNumber: '9444003322',
  pickupAddress: '11 Ranganathan Street',
  dropAddress: '44 West Mambalam Main Road',
  dateLabel: 'May 22, 2025 • 18:45',
  epochSeconds: 1747939500,
  distanceKm: 3.0,
  amount: 318.00,
  status: DeliveryOrderHistoryStatus.pending,
  paymentType: 'COD',
);

const order6 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1007',
  customerName: 'Lakshmi Menon',
  phoneNumber: '9092765152',
  pickupAddress: '90 Nungambakkam High Road',
  dropAddress: '12 Royapettah 2nd Cross Street',
  dateLabel: 'May 18, 2025 • 13:10',
  epochSeconds: 1747573800,
  distanceKm: 2.7,
  amount: 540.25,
  status: DeliveryOrderHistoryStatus.completed,
  paymentType: 'Online',
);

const allOrders = [order1, order2, order3, order4, order5, order6];

const loadedState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.loaded,
  orders: allOrders,
  filteredOrders: allOrders,
  pageOrders: [order1, order2, order3, order4, order5],
  stats: DeliveryOrderHistoryStats(
    totalOrders: 6,
    completedCount: 3,
    cancelledCount: 1,
    pendingCount: 2,
    totalEarnings: 4211.75,
    totalOrdersDelta: 12.5,
    earningsDelta: 18.6,
  ),
  page: 1,
  pageSize: 5,
);

const errorState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.error,
  errorMessage: 'Database offline',
);

const emptyState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.empty,
);

const noResultsState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.loaded,
  orders: allOrders,
  filteredOrders: [],
  pageOrders: [],
  stats: DeliveryOrderHistoryStats(
    totalOrders: 6,
    completedCount: 3,
    cancelledCount: 1,
    pendingCount: 2,
    totalEarnings: 4211.75,
  ),
  page: 1,
  pageSize: 5,
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
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  void setMobileSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C1017),
      ),
      home: Scaffold(body: DeliveryOrderHistoryPage(bloc: mockBloc)),
    );
  }

  group('DeliveryOrderHistoryPage Widget Tests', () {
    testWidgets('renders top bar, KPI cards and search on desktop', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_sidebar')), findsNothing);
      expect(find.byKey(const Key('dp_oh_topbar')), findsOneWidget);
      expect(find.text('Order History'), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_search_field')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_filters_button')), findsOneWidget);
    });

    testWidgets('renders the five KPI metric cards', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_stat_total')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_completed')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_cancelled')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_pending')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_earnings')), findsOneWidget);

      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('Cancelled'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Total Earnings'), findsOneWidget);
      expect(find.text('₹4,211.75'), findsOneWidget);
      expect(find.text('+12.5%'), findsOneWidget);
      expect(find.text('+18.6%'), findsOneWidget);
    });

    testWidgets('renders the orders table with rows and pagination', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_table')), findsOneWidget);
      expect(find.text('ORD-1001'), findsOneWidget);
      expect(find.text('ORD-1002'), findsOneWidget);
      expect(find.text('ORD-1005'), findsOneWidget);
      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.text('9840112233'), findsOneWidget);
      expect(find.text('₹486.50'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_oh_view_details_ORD-1001')),
        findsOneWidget,
      );

      expect(find.byKey(const Key('dp_oh_pagination')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_summary')), findsOneWidget);
      expect(find.text('Showing 1 to 5 of 6 orders'), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_prev')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_page_1')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_page_2')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_next')), findsOneWidget);
    });

    testWidgets('renders order cards on mobile viewport', (tester) async {
      setMobileSize(tester);
      when(
        () => mockBloc.state,
      ).thenReturn(loadedState.copyWith(sidebarOpen: false));
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_card_ORD-1001')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_card_ORD-1002')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_table')), findsNothing);
      expect(find.byKey(const Key('dp_oh_pagination')), findsOneWidget);
    });

    testWidgets('does not show sidebar overlay since sidebar is removed', (
      tester,
    ) async {
      setMobileSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_sidebar')), findsNothing);
    });

    testWidgets('dispatches search changed event when typing', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('dp_oh_search_field')),
        'Priya',
      );
      await tester.pump();

      verify(
        () =>
            mockBloc.add(const DeliveryOrderHistorySearchChangedEvent('Priya')),
      ).called(1);
    });

    testWidgets('dispatches status filter event from the dropdown', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_oh_status_filter')));
      await tester.pumpAndSettle();

      await tester.tap(
        find
            .widgetWithText(
              DropdownMenuItem<DeliveryOrderHistoryStatusFilter>,
              'Completed',
            )
            .last,
      );
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(
          const DeliveryOrderHistoryStatusFilterChangedEvent(
            DeliveryOrderHistoryStatusFilter.completed,
          ),
        ),
      ).called(1);
    });

    testWidgets('dispatches payment filter event from the dropdown', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_oh_payment_filter')));
      await tester.pumpAndSettle();

      await tester.tap(
        find
            .widgetWithText(
              DropdownMenuItem<DeliveryOrderHistoryPaymentFilter>,
              'Online',
            )
            .last,
      );
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(
          const DeliveryOrderHistoryPaymentFilterChangedEvent(
            DeliveryOrderHistoryPaymentFilter.online,
          ),
        ),
      ).called(1);
    });

    testWidgets('dispatches date range event from the dropdown', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_oh_date_filter')));
      await tester.pumpAndSettle();

      await tester.tap(
        find
            .widgetWithText(
              DropdownMenuItem<String>,
              'May 18, 2025 - May 24, 2025',
            )
            .last,
      );
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(
          const DeliveryOrderHistoryDateRangeChangedEvent(
            startEpoch: 1747526400,
            endEpoch: 1748131140,
            dateLabel: 'May 18, 2025 - May 24, 2025',
          ),
        ),
      ).called(1);
    });

    testWidgets('dispatches page changed event when a page is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_oh_page_2')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryOrderHistoryPageChangedEvent(2)),
      ).called(1);
    });

    testWidgets('dispatches page size changed event from the rows selector', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_oh_rows_selector')));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(DropdownMenuItem<int>, '20').last);
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(const DeliveryOrderHistoryPageSizeChangedEvent(20)),
      ).called(1);
    });

    testWidgets('dispatches toggle sidebar event from the mobile menu button', (
      tester,
    ) async {
      setMobileSize(tester);
      when(
        () => mockBloc.state,
      ).thenReturn(loadedState.copyWith(sidebarOpen: false));
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_oh_sidebar_toggle')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryOrderHistoryToggleSidebarEvent()),
      ).called(1);
    });

    testWidgets('shows filters applied snackbar from the filters button', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_oh_filters_button')));
      await tester.pump();

      expect(find.text('Filters applied'), findsOneWidget);
    });

    testWidgets('shows details snackbar when view details is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_oh_view_details_ORD-1001')));
      await tester.pump();

      expect(find.text('Opening details for ORD-1001'), findsOneWidget);
    });

    testWidgets('renders error shell and dispatches init on retry', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(errorState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_error')), findsOneWidget);
      expect(
        find.text('Something went wrong while loading your order history.'),
        findsOneWidget,
      );
      expect(find.text('Database offline'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_oh_retry')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryOrderHistoryInitEvent()),
      ).called(1);
    });

    testWidgets('renders empty shell and dispatches refresh', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(emptyState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_empty')), findsOneWidget);
      expect(find.text('No order history available'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_oh_refresh')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryOrderHistoryRefreshEvent()),
      ).called(1);
    });

    testWidgets('renders no-results fallback when filters match nothing', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(noResultsState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_no_results')), findsOneWidget);
      expect(find.text('No orders found'), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_table')), findsNothing);
    });

    testWidgets('renders loading skeleton while initialising', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loading,
        ),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_loading')), findsOneWidget);
    });
  });
}
