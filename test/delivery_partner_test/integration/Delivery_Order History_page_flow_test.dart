import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_ui.dart';

import '../helpers/delivery_test_utils.dart';

class MockDeliveryOrderHistoryRepository extends Mock
    implements DeliveryOrderHistoryRepositoryBase {}

List<DeliveryOrderHistoryModel> buildDemoOrders() {
  return List.generate(245, (index) {
    final i = index + 1;
    final DeliveryOrderHistoryStatus status = i <= 182
        ? DeliveryOrderHistoryStatus.completed
        : (i <= 210
              ? DeliveryOrderHistoryStatus.cancelled
              : DeliveryOrderHistoryStatus.pending);
    final String paymentType = i <= 162 ? 'Online' : 'COD';
    return DeliveryOrderHistoryModel(
      orderId: 'ORD-${1000 + i}',
      restaurantName: 'Restaurant $i',
      restaurantAddress: 'Restaurant Address $i',
      customerName: 'Customer $i',
      customerArea: 'Area $i',
      phoneNumber: i == 1 ? '9840112233' : '9840${1000 + i}',
      pickupAddress: 'Pickup $i Street',
      dropAddress: 'Drop $i Street',
      deliveryDate: 'May $i, 2025',
      deliveryTime: '10:30',
      dateLabel: 'May $i, 2025 \u2022 10:30',
      epochSeconds: 1747909800 + i,
      distanceKm: 2.5 + (i % 10),
      amount: 100.0 + i,
      status: status,
      paymentType: paymentType,
    );
  });
}

void main() {
  late MockDeliveryOrderHistoryRepository mockRepository;

  setUpAll(() {
    setupDeliveryTestChannels();
  });

  setUp(() {
    mockRepository = MockDeliveryOrderHistoryRepository();
    when(
      () => mockRepository.watchOrderHistory(),
    ).thenAnswer((_) => Stream.value(buildDemoOrders()));
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1440, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> pumpHistoryPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0C1017),
        ),
        home: Scaffold(
          body: DeliveryOrderHistoryPage(
            repository: mockRepository,
            service: DeliveryOrderHistoryService(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> selectDropdownItem(
    WidgetTester tester,
    Key triggerKey,
    Type menuItemType,
    String label,
  ) async {
    await tester.tap(find.byKey(triggerKey));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(menuItemType, label).last);
    await tester.pumpAndSettle();
  }

  group('DeliveryOrderHistoryPage Integration Flow Tests', () {
    testWidgets('loads the full order history and renders the data table', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpHistoryPage(tester);

      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_table')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_total')), findsOneWidget);
      expect(find.text('245'), findsOneWidget);
      expect(find.text('ORD-1001'), findsOneWidget);
      expect(find.text('ORD-1010'), findsOneWidget);
      expect(find.text('Showing 1 to 10 of 245 orders'), findsOneWidget);
    });

    testWidgets('filters the history by search query', (tester) async {
      setDesktopSize(tester);
      await pumpHistoryPage(tester);

      await tester.enterText(
        find.byKey(const Key('dp_oh_search_field')),
        'ORD-1001',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.descendant(
          of: find.byKey(const Key('dp_oh_table')),
          matching: find.text('ORD-1001'),
        ),
        findsOneWidget,
      );
      expect(find.text('Showing 1 to 1 of 1 orders'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('dp_oh_search_field')),
        '9840112233',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.descendant(
          of: find.byKey(const Key('dp_oh_table')),
          matching: find.text('ORD-1001'),
        ),
        findsOneWidget,
      );
      expect(find.text('Showing 1 to 1 of 1 orders'), findsOneWidget);
    });

    testWidgets('filters the history by status from the dropdown', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpHistoryPage(tester);

      await selectDropdownItem(
        tester,
        const Key('dp_oh_status_filter'),
        DropdownMenuItem<DeliveryOrderHistoryStatusFilter>,
        'Completed',
      );

      expect(find.text('Showing 1 to 10 of 182 orders'), findsOneWidget);

      await selectDropdownItem(
        tester,
        const Key('dp_oh_status_filter'),
        DropdownMenuItem<DeliveryOrderHistoryStatusFilter>,
        'Cancelled',
      );

      expect(find.text('Showing 1 to 10 of 28 orders'), findsOneWidget);
    });

    testWidgets('filters the history by payment method from the dropdown', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpHistoryPage(tester);

      await selectDropdownItem(
        tester,
        const Key('dp_oh_payment_filter'),
        DropdownMenuItem<DeliveryOrderHistoryPaymentFilter>,
        'Online',
      );

      expect(find.text('Showing 1 to 10 of 162 orders'), findsOneWidget);
    });

    testWidgets('paginates through the order history', (tester) async {
      setDesktopSize(tester);
      await pumpHistoryPage(tester);

      expect(find.text('Showing 1 to 10 of 245 orders'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_oh_next')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Showing 11 to 20 of 245 orders'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_oh_prev')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Showing 1 to 10 of 245 orders'), findsOneWidget);
    });

    testWidgets('changes the page size from the rows selector', (tester) async {
      setDesktopSize(tester);
      await pumpHistoryPage(tester);

      await selectDropdownItem(
        tester,
        const Key('dp_oh_rows_selector'),
        DropdownMenuItem<int>,
        '20',
      );

      expect(find.text('Showing 1 to 20 of 245 orders'), findsOneWidget);
    });

    testWidgets('shows the no-results fallback for a non-matching search', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpHistoryPage(tester);

      await tester.enterText(
        find.byKey(const Key('dp_oh_search_field')),
        'nonexistent-order',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('dp_oh_no_results')), findsOneWidget);
      expect(find.text('No orders found'), findsOneWidget);
    });

    testWidgets('opens a details snackbar from the table action', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpHistoryPage(tester);

      await tester.tap(find.byKey(const Key('dp_oh_view_details_ORD-1001')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Opening details for ORD-1001'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
