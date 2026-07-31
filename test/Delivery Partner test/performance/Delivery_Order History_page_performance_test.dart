import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_ui.dart';

void main() {
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
          repository: DeliveryOrderHistoryRepository(),
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
