import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> loadPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(body: DeliveryWalletPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryWalletPage Integration Flow Tests', () {
    testWidgets('loads the complete dashboard', (tester) async {
      setDesktopSize(tester);
      await loadPage(tester);

      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.text('₹24580.50'), findsWidgets);
      expect(find.byKey(const Key('dp_wallet_chart_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_wallet_transactions_panel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_wallet_settlement_card')),
        findsOneWidget,
      );
    });

    testWidgets('filters transactions through the rendered UI', (tester) async {
      setDesktopSize(tester);
      await loadPage(tester);

      await tester.tap(
        find.byKey(const Key('dp_wallet_transaction_filter_income')),
      );
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Delivery Earnings'), findsWidgets);
      expect(find.text('Peak Hour Bonus'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('changes earnings period without exceptions', (tester) async {
      setDesktopSize(tester);
      await loadPage(tester);

      await tester.tap(find.byKey(const Key('dp_wallet_period_last3Months')));
      await tester.pump();
      expect(find.byKey(const Key('dp_wallet_chart')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('withdraws funds and updates the balance', (tester) async {
      setDesktopSize(tester);
      await loadPage(tester);

      await tester.tap(find.byKey(const Key('dp_wallet_withdraw_button')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('dp_wallet_withdraw_amount')),
        '500',
      );
      await tester.tap(find.byKey(const Key('dp_wallet_withdraw_confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('₹24080.50'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
