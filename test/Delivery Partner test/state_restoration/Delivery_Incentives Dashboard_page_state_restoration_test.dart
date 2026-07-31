import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryIncentivesDashboardRepository extends Mock
    implements DeliveryIncentivesDashboardRepositoryBase {}

class MockDeliveryIncentivesDashboardService extends Mock
    implements DeliveryIncentivesDashboardServiceBase {}

DeliveryIncentivesDashboardLoadedState buildLoadedState() {
  return DeliveryIncentivesDashboardLoadedState(
    targetDeadline: DateTime(2026, 8, 31),
    walletBalance: 2450.00,
    rangePoints: {
      IncentivesDateRange.thisMonth: [
        DeliveryIncentivesBonusPoint(
          label: '6AM',
          value: 40.0,
          date: DateTime(2026, 7, 31),
        ),
      ],
    },
  );
}

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

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage({
    DeliveryIncentivesDashboardRepositoryBase? repository,
    DeliveryIncentivesDashboardServiceBase? service,
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      home: Scaffold(
        body: DeliveryIncentivesDashboardPage(
          repository: repository ?? DeliveryIncentivesDashboardRepository(),
          service: service ?? DeliveryIncentivesDashboardService(),
        ),
      ),
    );
  }

  Future<void> loadDashboard(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryIncentivesDashboardPage State Restoration Tests', () {
    testWidgets(
      'preserves selected range when switching ranges away and back',
      (tester) async {
        setDesktopSize(tester);
        SharedPreferences.setMockInitialValues({});
        await tester.pumpWidget(buildPage());
        await loadDashboard(tester);

        expect(find.text('Incentives Dashboard'), findsOneWidget);

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
      },
    );

    testWidgets(
      'preserves active filter and pagination across range switches',
      (tester) async {
        setDesktopSize(tester);
        SharedPreferences.setMockInitialValues({});
        await tester.pumpWidget(buildPage());
        await loadDashboard(tester);

        await tester.ensureVisible(
          find.byKey(const Key('dp_incentives_filter_peakhour')),
        );
        await tester.tap(
          find.byKey(const Key('dp_incentives_filter_peakhour')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('1 to 5 of 8 rewards'), findsOneWidget);

        final todayChip = find.byKey(const Key('dp_incentives_range_today'));
        await tester.ensureVisible(todayChip);
        await tester.tap(todayChip);
        await tester.pump();

        expect(find.text('1 to 5 of 8 rewards'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('restores cached state across lifecycle restart when offline', (
      tester,
    ) async {
      setDesktopSize(tester);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(buildPage());
      await loadDashboard(tester);
      expect(find.text('₹2450.00'), findsWidgets);

      final failingService = MockDeliveryIncentivesDashboardService();
      when(
        () => failingService.fetchIncentivesData(),
      ).thenThrow(Exception('offline'));

      await tester.pumpWidget(
        buildPage(
          repository: DeliveryIncentivesDashboardRepository(
            service: failingService,
            prefs: prefs,
          ),
          service: DeliveryIncentivesDashboardService(),
        ),
      );
      await loadDashboard(tester);

      expect(find.text('₹2450.00'), findsWidgets);
      expect(find.text('Incentives Dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'update date range preserves filter and page in restored state',
      build: () {
        final mockRepository = MockDeliveryIncentivesDashboardRepository();
        return DeliveryIncentivesDashboardPageBloc(
          repository: mockRepository,
          service: MockDeliveryIncentivesDashboardService(),
        );
      },
      seed: () => buildLoadedState().copyWith(
        selectedRange: IncentivesDateRange.thisMonth,
        activeFilter: RewardFilterType.peakHour,
        currentPage: 1,
      ),
      act: (bloc) =>
          bloc.add(const UpdateDateRangeEvent(IncentivesDateRange.today)),
      expect: () => [
        buildLoadedState().copyWith(
          selectedRange: IncentivesDateRange.today,
          activeFilter: RewardFilterType.peakHour,
          currentPage: 1,
        ),
      ],
    );
  });
}
