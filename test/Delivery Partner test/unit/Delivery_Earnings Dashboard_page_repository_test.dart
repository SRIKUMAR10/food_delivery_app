import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';

class MockDeliveryEarningsDashboardService extends Mock
    implements DeliveryEarningsDashboardServiceBase {}

Map<String, dynamic> rawData() => {
      'totalEarnings': 12850.00,
      'totalDeliveries': 312,
      'todayEarnings': 2450.00,
      'todayDeliveries': 18,
      'earningsGrowth': 18.5,
      'weeklyEarnings': 12850.00,
      'weeklyDeliveries': 85,
      'monthlyEarnings': 48900.00,
      'monthlyDeliveries': 312,
      'averagePerOrder': 155.45,
      'rating': 4.8,
      'walletBalance': 12850.00,
      'pendingWithdrawal': 1200.00,
      'totalWithdrawn': 48250.00,
      'rangeEarnings': {
        'today': [
          {'label': '6AM', 'value': 180.0, 'date': '2026-07-31T06:00:00.000'},
        ],
      },
      'transactions': [
        {
          'id': 'tx_1',
          'title': 'Delivery Earnings',
          'date': '2026-07-31T10:00:00.000',
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
          'date': '2026-07-31T09:00:00.000',
          'status': 'completed',
        },
      ],
    };

void main() {
  late DeliveryEarningsDashboardRepository repository;
  late MockDeliveryEarningsDashboardService mockService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    mockService = MockDeliveryEarningsDashboardService();
    repository = DeliveryEarningsDashboardRepository(
      service: mockService,
      prefs: prefs,
    );
  });

  group('DeliveryEarningsDashboardPage Repository Tests', () {
    test('loadEarningsData maps raw metrics into the state', () async {
      when(
        () => mockService.fetchEarningsData(),
      ).thenAnswer((_) async => rawData());

      final state = await repository.loadEarningsData();

      expect(state.status, DeliveryEarningsStatus.loaded);
      expect(state.isFromCache, isFalse);
      expect(state.totalEarnings, 12850.00);
      expect(state.todayEarnings, 2450.00);
      expect(state.weeklyEarnings, 12850.00);
      expect(state.monthlyEarnings, 48900.00);
      expect(state.walletBalance, 12850.00);
      expect(state.pendingWithdrawal, 1200.00);
      expect(state.totalWithdrawn, 48250.00);
      expect(state.transactions, hasLength(1));
      expect(state.withdrawalHistory, hasLength(1));
      expect(state.currentRangePoints, hasLength(1));
    });

    test('loadEarningsData persists a local cache for offline fallback', () async {
      when(
        () => mockService.fetchEarningsData(),
      ).thenAnswer((_) async => rawData());
      await repository.loadEarningsData();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('dp_earnings_cache_v1'), isNotNull);
    });

    test('loadCachedEarnings restores cached snapshot when available', () async {
      when(
        () => mockService.fetchEarningsData(),
      ).thenAnswer((_) async => rawData());
      await repository.loadEarningsData();
      final cached = await repository.loadCachedEarnings();

      expect(cached, isNotNull);
      expect(cached!.status, DeliveryEarningsStatus.loaded);
      expect(cached.isFromCache, isTrue);
      expect(cached.walletBalance, 12850.00);
      expect(cached.transactions, hasLength(1));
    });

    test('loadCachedEarnings returns null when no cache exists', () async {
      final cached = await repository.loadCachedEarnings();
      expect(cached, isNull);
    });

    test('maps an empty payload to zeroed metrics', () async {
      when(
        () => mockService.fetchEarningsData(),
      ).thenAnswer((_) async => <String, dynamic>{});

      final state = await repository.loadEarningsData();

      expect(state.totalEarnings, 0.0);
      expect(state.todayEarnings, 0.0);
      expect(state.walletBalance, 0.0);
      expect(state.transactions, isEmpty);
      expect(state.withdrawalHistory, isEmpty);
    });

    test('withdraw reduces balance and prepends withdrawal and transaction', () async {
      when(
        () => mockService.fetchEarningsData(),
      ).thenAnswer((_) async => rawData());
      when(
        () => mockService.withdraw(500.00),
      ).thenAnswer((_) async => {
        'success': true,
        'walletBalance': 12350.00,
        'withdrawal': {
          'id': 'wd_new',
          'amount': 500.00,
          'method': 'Bank Transfer',
          'date': '2026-08-01T10:00:00.000',
          'status': 'pending',
        },
        'transaction': {
          'id': 'tx_new',
          'title': 'Withdrawal',
          'date': '2026-08-01T10:00:00.000',
          'amount': -500.00,
          'type': 'withdrawal',
          'status': 'pending',
        },
      });

      final initial = await repository.loadEarningsData();
      expect(initial.walletBalance, 12850.00);

      final updated = await repository.withdraw(500.00);

      expect(updated.walletBalance, 12350.00);
      expect(updated.withdrawalHistory, hasLength(2));
      expect(updated.withdrawalHistory.first.amount, 500.00);
      expect(updated.transactions, hasLength(2));
      expect(
        updated.transactions.first.type,
        EarningsTransactionType.withdrawal,
      );
    });

    test('clearCache removes the persisted snapshot', () async {
      when(
        () => mockService.fetchEarningsData(),
      ).thenAnswer((_) async => rawData());
      await repository.loadEarningsData();
      await repository.clearCache();

      final cached = await repository.loadCachedEarnings();
      expect(cached, isNull);
    });

    test('mediaUploadStream yields progress events', () async {
      when(
        () => mockService.simulateMediaUpload(),
      ).thenAnswer((_) => Stream.fromIterable([0.1, 0.5, 1.0]));

      final values = <double>[];
      await for (final progress in repository.mediaUploadStream()) {
        values.add(progress);
      }

      expect(values.last, 1.0);
      expect(values.length, greaterThan(1));
    });
  });
}
