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

  Widget buildPage() {
    return MaterialApp(
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
    );
  }

  Future<void> settleLoad(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('DeliveryOrderHistoryPage Performance & Memory Tests', () {
    testWidgets('renders the history UI within frame threshold', (
      tester,
    ) async {
      setDesktopSize(tester);

      final Stopwatch stopwatch = Stopwatch()..start();
      await tester.pumpWidget(buildPage());
      await settleLoad(tester);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_table')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_total')), findsOneWidget);
    });

    testWidgets('disposes the page without leaks', (tester) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await settleLoad(tester);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(DeliveryOrderHistoryPage), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles rapid pagination without frame drops', (tester) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await settleLoad(tester);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('dp_oh_next')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.text('Showing 31 to 40 of 245 orders'), findsOneWidget);
    });

    testWidgets('keeps the list responsive under repeated searches', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await settleLoad(tester);

      for (var i = 0; i < 5; i++) {
        await tester.enterText(
          find.byKey(const Key('dp_oh_search_field')),
          'ORD-100$i',
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
    });
  });
}
