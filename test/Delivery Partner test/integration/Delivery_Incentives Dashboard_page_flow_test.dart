import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_ui.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      home: Scaffold(body: DeliveryIncentivesDashboardPage()),
    );
  }

  Future<void> loadDashboard(WidgetTester tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryIncentivesDashboardPage Integration Flow Tests', () {
    testWidgets('loads incentives data and renders all key sections', (
      tester,
    ) async {
      setDesktopSize(tester);
      await loadDashboard(tester);

      expect(find.text('Incentives Dashboard'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
      expect(find.text('₹350.00'), findsOneWidget);
      expect(find.text('₹1250.00'), findsOneWidget);
      expect(find.text('₹4750.00'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_incentives_summary_today')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_summary_target')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_overview_card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_incentives_donut_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_incentives_milestones_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_reward_history_card')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('switches date ranges and updates chart selection', (
      tester,
    ) async {
      setDesktopSize(tester);
      await loadDashboard(tester);

      await tester.tap(find.byKey(const Key('dp_incentives_range_today')));
      await tester.pump();

      expect(
        find.byKey(const Key('dp_incentives_overview_chart')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('dp_incentives_range_thisWeek')));
      await tester.pump();

      expect(
        find.byKey(const Key('dp_incentives_overview_chart')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('filters reward history and updates pagination totals', (
      tester,
    ) async {
      setDesktopSize(tester);
      await loadDashboard(tester);

      expect(find.text('1 to 5 of 32 rewards'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const Key('dp_incentives_filter_peakhour')),
      );
      await tester.tap(find.byKey(const Key('dp_incentives_filter_peakhour')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('1 to 5 of 8 rewards'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('paginates through reward history', (tester) async {
      setDesktopSize(tester);
      await loadDashboard(tester);

      expect(find.text('1 to 5 of 32 rewards'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const Key('dp_incentives_page_next')),
      );
      await tester.tap(find.byKey(const Key('dp_incentives_page_next')));
      await tester.pump();

      expect(find.text('6 to 10 of 32 rewards'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const Key('dp_incentives_page_next')),
      );
      await tester.tap(find.byKey(const Key('dp_incentives_page_next')));
      await tester.pump();

      expect(find.text('11 to 15 of 32 rewards'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('switches between achievement cards in the carousel', (
      tester,
    ) async {
      setDesktopSize(tester);
      await loadDashboard(tester);

      expect(
        find.byKey(const Key('dp_incentives_achievements_carousel')),
        findsOneWidget,
      );

      await tester.drag(
        find.byKey(const Key('dp_incentives_achievements_carousel')),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('export action completes without exceptions', (tester) async {
      setDesktopSize(tester);
      await loadDashboard(tester);

      await tester.ensureVisible(find.byKey(const Key('dp_incentives_export')));
      await tester.tap(find.byKey(const Key('dp_incentives_export')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });
  });
}
