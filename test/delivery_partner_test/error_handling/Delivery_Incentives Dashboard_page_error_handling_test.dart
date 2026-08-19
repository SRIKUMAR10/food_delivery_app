import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';
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
    rewardHistory: [
      DeliveryIncentivesRewardRecord(
        id: 'r_1',
        title: 'Peak Hour Reward',
        date: DateTime(2026, 7, 31),
        amount: 120.00,
        type: RewardFilterType.peakHour,
        status: 'completed',
        referenceId: 'REF-1040',
      ),
    ],
  );
}

void main() {
  late MockDeliveryIncentivesDashboardRepository mockRepository;
  late MockDeliveryIncentivesDashboardService mockService;

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

    mockRepository = MockDeliveryIncentivesDashboardRepository();
    mockService = MockDeliveryIncentivesDashboardService();

    when(
      () => mockRepository.watchIncentivesData(),
    ).thenAnswer((_) => Stream.value(buildLoadedState()));
    when(
      () => mockRepository.loadIncentivesData(),
    ).thenAnswer((_) async => buildLoadedState());
    when(
      () => mockRepository.exportRewardHistory(any()),
    ).thenAnswer((_) async => 'csv');
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
      home: Scaffold(
        body: DeliveryIncentivesDashboardPage(
          repository: mockRepository,
          service: mockService,
        ),
      ),
    );
  }

  group('DeliveryIncentivesDashboardPage Error Handling Tests', () {
    testWidgets('shows fallback error UI when initialization fails', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.watchIncentivesData(),
      ).thenAnswer((_) => Stream.error(Exception('Server unreachable')));
      when(
        () => mockRepository.loadIncentivesData(),
      ).thenThrow(Exception('Server unreachable'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_incentives_error')), findsOneWidget);
      expect(find.textContaining('Server unreachable'), findsWidgets);
      expect(find.byKey(const Key('dp_incentives_retry')), findsOneWidget);
    });

    testWidgets('retry recovers and loads the dashboard', (tester) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.watchIncentivesData()).thenAnswer((_) {
        calls++;
        if (calls == 1) {
          return Stream.error(Exception('Temporary failure'));
        }
        return Stream.value(buildLoadedState());
      });
      when(() => mockRepository.loadIncentivesData()).thenAnswer((_) async {
        if (calls == 1) {
          throw Exception('Temporary failure');
        }
        return buildLoadedState();
      });

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_incentives_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_incentives_retry')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_incentives_error')), findsNothing);
      expect(find.text('Incentives Dashboard'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
    });

    testWidgets('shows cached dashboard when offline data is restored', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.loadIncentivesData(),
      ).thenAnswer((_) async => buildLoadedState().copyWith(isFromCache: true));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_incentives_error')), findsNothing);
      expect(find.text('Incentives Dashboard'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
    });

    testWidgets('export failure keeps the dashboard usable', (tester) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.exportRewardHistory(any()),
      ).thenThrow(Exception('gateway timeout'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.ensureVisible(find.byKey(const Key('dp_incentives_export')));
      await tester.tap(find.byKey(const Key('dp_incentives_export')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Incentives Dashboard'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
