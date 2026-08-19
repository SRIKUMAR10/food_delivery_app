import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> render(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Scaffold(body: DeliveryWalletPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryWalletPage Golden Tests', () {
    testWidgets('desktop dark dashboard structure is stable', (tester) async {
      await render(tester, const Size(1440, 1024));
      expect(find.byKey(const Key('dp_wallet_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_wallet_header')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_wallet_summary_balance')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_wallet_breakdown_card')), findsOneWidget);
    });

    testWidgets('tablet structure is stable', (tester) async {
      await render(tester, const Size(800, 1024));
      expect(find.byKey(const Key('dp_wallet_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_wallet_sidebar')), findsNothing);
      expect(find.byKey(const Key('dp_wallet_chart_card')), findsOneWidget);
    });

    testWidgets('mobile structure is stable', (tester) async {
      await render(tester, const Size(390, 844));
      expect(find.byKey(const Key('dp_wallet_page')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_wallet_transactions_panel')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
