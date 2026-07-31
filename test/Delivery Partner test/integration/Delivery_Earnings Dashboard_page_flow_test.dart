import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

void main() {
  setUpAll(() {
    overrideFontAssetLoading();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D131E),
      ),
      home: Scaffold(body: DeliveryEarningsDashboardPage()),
    );
  }

  Future<void> loadDashboard(WidgetTester tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryEarningsDashboardPage Integration Flow Tests', () {
    testWidgets('loads earnings data and renders all key sections', (
      tester,
    ) async {
      setDesktopSize(tester);
      await loadDashboard(tester);

      expect(find.text('Earnings Overview'), findsOneWidget);
      expect(find.text('₹12850.00'), findsWidgets);
      expect(find.byKey(const Key('dp_earnings_chart_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_earnings_wallet_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_earnings_media_upload_card')),
        findsOneWidget,
      );
      expect(find.text('Withdraw'), findsOneWidget);
    });

    testWidgets('switches date ranges and updates chart selection', (
      tester,
    ) async {
      setDesktopSize(tester);
      await loadDashboard(tester);

      await tester.tap(find.byKey(const Key('dp_earnings_range_thisWeek')));
      await tester.pump();

      expect(find.byKey(const Key('dp_earnings_chart')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_earnings_range_thisMonth')));
      await tester.pump();

      expect(find.byKey(const Key('dp_earnings_chart')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'switches between overview, transactions and withdrawals tabs',
      (tester) async {
        setDesktopSize(tester);
        await loadDashboard(tester);

        await tester.tap(find.byKey(const Key('dp_earnings_tab_transactions')));
        await tester.pump();

        expect(find.text('Recent Transactions'), findsOneWidget);
        expect(find.text('Delivery Earnings'), findsOneWidget);
        expect(find.text('Peak Hour Bonus'), findsOneWidget);

        await tester.tap(find.byKey(const Key('dp_earnings_tab_withdrawals')));
        await tester.pump();

        expect(find.text('Withdrawal History'), findsOneWidget);
        expect(find.text('Bank Transfer'), findsWidgets);
        expect(find.text('₹2000.00'), findsOneWidget);

        await tester.tap(find.byKey(const Key('dp_earnings_tab_overview')));
        await tester.pump();

        expect(find.byKey(const Key('dp_earnings_chart_card')), findsOneWidget);
      },
    );

    testWidgets('withdraws funds and updates wallet balance live', (
      tester,
    ) async {
      setDesktopSize(tester);
      await loadDashboard(tester);

      expect(find.text('₹12850.00'), findsWidgets);

      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Withdraw Funds'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('dp_earnings_withdraw_amount')),
        '500',
      );
      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('₹12350.00'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('media upload runs to completion', (tester) async {
      setDesktopSize(tester);
      await loadDashboard(tester);

      await tester.tap(
        find.byKey(const Key('dp_earnings_media_upload_button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Upload complete'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
