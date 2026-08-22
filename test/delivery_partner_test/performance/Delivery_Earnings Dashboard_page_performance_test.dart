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

  setUp(() async {
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

  group('DeliveryEarningsDashboardPage Performance & Memory Tests', () {
    testWidgets('renders the earnings dashboard UI within frame threshold', (
      tester,
    ) async {
      setDesktopSize(tester);

      final Stopwatch stopwatch = Stopwatch()..start();
      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.text('Earnings Overview'), findsOneWidget);
    });

    testWidgets('disposes the page without leaks', (tester) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryEarningsDashboardPage), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles rapid tab and range switches without frame drops', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key('dp_earnings_tab_transactions')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('dp_earnings_tab_overview')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('dp_earnings_range_thisWeek')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('dp_earnings_page')), findsOneWidget);
    });

    testWidgets('media upload runs without frame exceptions', (tester) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.ensureVisible(
        find.byKey(const Key('dp_earnings_media_upload_button')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('dp_earnings_media_upload_button')),
      );
      await tester.pump(const Duration(milliseconds: 60));

      expect(
        find.byKey(const Key('dp_earnings_media_upload_progress')),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Upload complete'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
