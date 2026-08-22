import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> load(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(body: DeliveryWalletPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryWalletPage Performance Tests', () {
    testWidgets('renders within the dashboard frame threshold', (tester) async {
      final stopwatch = Stopwatch()..start();
      await load(tester);
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.text('My Wallet'), findsWidgets);
    });

    testWidgets('handles repeated filters and period switches', (tester) async {
      await load(tester);
      for (var i = 0; i < 3; i++) {
        await tester.tap(
          find.byKey(const Key('dp_wallet_transaction_filter_income')),
        );
        await tester.pump(const Duration(milliseconds: 120));
        await tester.tap(find.byKey(const Key('dp_wallet_period_thisMonth')));
        await tester.pump();
        await tester.tap(
          find.byKey(const Key('dp_wallet_transaction_filter_all')),
        );
        await tester.pump(const Duration(milliseconds: 120));
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes cleanly when the page is removed', (tester) async {
      await load(tester);
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DeliveryWalletPage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
