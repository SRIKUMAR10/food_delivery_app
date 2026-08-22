import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryEarningsDashboardRepository extends Mock
    implements DeliveryEarningsDashboardRepositoryBase {}

class MockDeliveryEarningsDashboardService extends Mock
    implements DeliveryEarningsDashboardServiceBase {}

class _FakeEarningsService implements DeliveryEarningsDashboardServiceBase {
  Map<String, dynamic> _payload() => {
        'totalEarnings': 12850.00,
        'walletBalance': 12850.00,
        'totalWithdrawn': 0.00,
        'todayEarnings': 2450.00,
        'weeklyEarnings': 12850.00,
        'monthlyEarnings': 48900.00,
        'rangeEarnings': {
          'today': [
            {'label': '6AM', 'value': 180.0, 'date': '2026-07-31T06:00:00'},
          ],
        },
        'transactions': [
          {
            'id': 'tx_1',
            'title': 'Delivery Earnings',
            'date': '2026-07-31T10:00:00',
            'amount': 240.00,
            'type': 'credit',
            'status': 'completed',
          },
        ],
        'withdrawals': [
          {
            'id': 'wd_1',
            'amount': 2000.00,
            'method': 'Bank Transfer',
            'date': '2026-07-31T09:00:00',
            'status': 'completed',
          },
        ],
      };

  @override
  Future<Map<String, dynamic>> fetchEarningsData() async => _payload();

  @override
  Stream<Map<String, dynamic>> watchEarningsData() =>
      Stream.value(_payload());

  @override
  Future<Map<String, dynamic>> withdraw(double amount) async => {
        'success': true,
        'walletBalance': 12850.00 - amount,
        'transaction': {
          'id': 'tx_withdraw',
          'title': 'Withdrawal',
          'date': DateTime(2026, 7, 31).toIso8601String(),
          'amount': -amount,
          'type': 'withdrawal',
          'status': 'pending',
        },
        'withdrawal': {
          'id': 'wd_new',
          'amount': amount,
          'method': 'Bank Transfer',
          'date': DateTime(2026, 7, 31).toIso8601String(),
          'status': 'pending',
        },
      };

  @override
  Future<Map<String, dynamic>> submitCash({
    required double amount,
    required String method,
  }) async =>
      {'success': true};

  @override
  Stream<double> simulateMediaUpload() => Stream.fromIterable([1.0]);
}

DeliveryEarningsDashboardState buildLoadedState() {
  return DeliveryEarningsDashboardState(
    status: DeliveryEarningsStatus.loaded,
    walletBalance: 12850.00,
    totalEarnings: 12850.00,
    rangeEarnings: {
      EarningsDateRange.today: [
        DeliveryEarningsPoint(
          label: '6AM',
          value: 180.0,
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
    DeliveryEarningsDashboardRepositoryBase? repository,
    DeliveryEarningsDashboardServiceBase? service,
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D131E),
      ),
      home: Scaffold(
        body: DeliveryEarningsDashboardPage(
          repository: repository ?? DeliveryEarningsDashboardRepository(),
          service: service ?? DeliveryEarningsDashboardService(),
        ),
      ),
    );
  }

  Future<void> loadDashboard(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryEarningsDashboardPage State Restoration Tests', () {
    testWidgets('preserves tab selection when switching tabs away and back', (
      tester,
    ) async {
      setDesktopSize(tester);
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(buildPage());
      await loadDashboard(tester);

      expect(find.text('Earnings Overview'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_earnings_tab_transactions')));
      await tester.pump();
      expect(find.text('Recent Transactions'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_earnings_tab_overview')));
      await tester.pump();
      expect(find.byKey(const Key('dp_earnings_chart_card')), findsOneWidget);
    });

    testWidgets('preserves updated wallet balance across tab switches', (
      tester,
    ) async {
      setDesktopSize(tester);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        buildPage(
          repository: DeliveryEarningsDashboardRepository(
            service: _FakeEarningsService(),
            prefs: prefs,
          ),
        ),
      );
      await loadDashboard(tester);

      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.byKey(const Key('dp_earnings_withdraw_amount')),
        '500',
      );
      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('₹12350.00'), findsWidgets);

      await tester.tap(find.byKey(const Key('dp_earnings_tab_transactions')));
      await tester.pump();
      expect(find.text('Recent Transactions'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_earnings_tab_overview')));
      await tester.pump();
      expect(find.text('₹12350.00'), findsWidgets);
    });

    testWidgets('restores cached state across lifecycle restart when offline', (
      tester,
    ) async {
      setDesktopSize(tester);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        buildPage(
          repository: DeliveryEarningsDashboardRepository(
            service: _FakeEarningsService(),
            prefs: prefs,
          ),
        ),
      );
      await loadDashboard(tester);
      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.byKey(const Key('dp_earnings_withdraw_amount')),
        '500',
      );
      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('₹12350.00'), findsWidgets);

      final failingService = MockDeliveryEarningsDashboardService();
      when(
        () => failingService.fetchEarningsData(),
      ).thenThrow(Exception('offline'));

      await tester.pumpWidget(
        buildPage(
          repository: DeliveryEarningsDashboardRepository(
            service: failingService,
            prefs: prefs,
          ),
          service: DeliveryEarningsDashboardService(),
        ),
      );
      await loadDashboard(tester);

      expect(find.text('₹12350.00'), findsWidgets);
      expect(find.text('Earnings Overview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'withdraw preserves selected range and tab in restored state',
      build: () {
        final mockRepository = MockDeliveryEarningsDashboardRepository();
        when(() => mockRepository.withdraw(500.0)).thenAnswer(
          (_) async => buildLoadedState().copyWith(walletBalance: 12350.00),
        );
        return DeliveryEarningsDashboardPageBloc(
          repository: mockRepository,
          service: MockDeliveryEarningsDashboardService(),
        );
      },
      seed: () => buildLoadedState().copyWith(
        selectedRange: EarningsDateRange.thisMonth,
        selectedTab: EarningsTab.withdrawals,
      ),
      act: (bloc) => bloc.add(const DeliveryEarningsWithdrawEvent(500.0)),
      expect: () => [
        buildLoadedState().copyWith(
          selectedRange: EarningsDateRange.thisMonth,
          selectedTab: EarningsTab.withdrawals,
          isWithdrawing: true,
        ),
        buildLoadedState().copyWith(
          walletBalance: 12350.00,
          selectedRange: EarningsDateRange.thisMonth,
          selectedTab: EarningsTab.withdrawals,
        ),
      ],
    );
  });
}
