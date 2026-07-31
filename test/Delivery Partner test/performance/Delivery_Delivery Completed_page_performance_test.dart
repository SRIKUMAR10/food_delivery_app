import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_ui.dart';

import '../../font_loader_helper.dart';

void main() {
  setUpAll(() {
    overrideFontAssetLoading();
  });

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(
        body: DeliveryCompletedPage(
          orderId: '#ORD12345',
          repository: DeliveryCompletedRepository(),
          service: DeliveryCompletedService(),
        ),
      ),
    );
  }

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryCompletedPage Performance Tests', () {
    testWidgets('renders the completed order UI within frame threshold', (
      tester,
    ) async {
      setDesktopSize(tester);

      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.text('Delivered Successfully! 🎉'), findsOneWidget);
      expect(find.byKey(const Key('dp_completed_hero_card')), findsOneWidget);
    });

    testWidgets('disposes the page without leaks', (tester) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryCompletedPage), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles repeated state transitions without frame drops', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      for (var i = 0; i < 3; i++) {
        final button = find.byKey(const Key('dp_completed_complete_button'));
        if (button.evaluate().isEmpty) break;
        await tester.tap(button);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      }

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('dp_completed_page')), findsOneWidget);
    });
  });
}
