import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_service.dart';
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

const loadedState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.loaded,
  orders: [order1],
  filteredOrders: [order1],
  pageOrders: [order1],
  stats: DeliveryOrderHistoryStats(
    totalOrders: 1,
    completedCount: 1,
    cancelledCount: 0,
    pendingCount: 0,
    totalEarnings: 486.50,
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
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
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
      home: Scaffold(body: DeliveryOrderHistoryPage(bloc: mockBloc)),
    );
  }

  group('DeliveryOrderHistoryPage Permission Tests', () {
    test('notification permission service returns granted', () async {
      final service = DeliveryOrderHistoryService();
      expect(await service.requestNotificationPermission(), isTrue);
    });

    test('location permission service returns granted', () async {
      final service = DeliveryOrderHistoryService();
      expect(await service.requestLocationPermission(), isTrue);
    });

    test('permission service does not expose raw environment secrets', () {
      final service = DeliveryOrderHistoryService();
      final env = service.getEnvironmentVariables();
      for (final value in env.values) {
        expect(
          value.contains(
            RegExp(r'(token|password|passwd|secret)', caseSensitive: false),
          ),
          isFalse,
        );
      }
    });

    testWidgets('renders the order history page when running', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_search_field')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_table')), findsOneWidget);
      expect(find.text('ORD-1001'), findsOneWidget);
    });

    testWidgets('view details action is reachable and tappable', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final detailsButton = find.byKey(
        const Key('dp_oh_view_details_ORD-1001'),
      );
      expect(detailsButton, findsOneWidget);
      await tester.scrollUntilVisible(
        detailsButton,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(detailsButton);
      await tester.pump();

      expect(
        find.textContaining('Opening details for ORD-1001'),
        findsOneWidget,
      );
    });

    testWidgets('sidebar navigation toggle is reachable and tappable', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_sidebar')), findsOneWidget);
      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
    });

    testWidgets('pagination controls are reachable and tappable', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_pagination')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_page_1')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_oh_page_1')));
      await tester.pump();
    });

    testWidgets('status filter dropdown is accessible', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_oh_status_filter')));
      await tester.pumpAndSettle();

      expect(find.text('All Status'), findsAtLeast(1));
      expect(find.text('Completed'), findsAtLeast(1));
      expect(find.text('Pending'), findsAtLeast(1));
      expect(find.text('Cancelled'), findsAtLeast(1));
    });
  });
}
