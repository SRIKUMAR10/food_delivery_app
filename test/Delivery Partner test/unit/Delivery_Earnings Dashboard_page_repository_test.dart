import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';

void main() {
  late DeliveryEarningsDashboardRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = DeliveryEarningsDashboardRepository(prefs: prefs);
  });

  group('DeliveryEarningsDashboardPage Repository Tests', () {
    test(
      'loadEarningsData returns loaded status with correct metrics',
      () async {
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
        expect(state.transactions, hasLength(5));
        expect(state.withdrawalHistory, hasLength(3));
        expect(state.currentRangePoints, hasLength(8));
      },
    );

    test(
      'loadEarningsData persists a local cache for offline fallback',
      () async {
        await repository.loadEarningsData();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('dp_earnings_cache_v1'), isNotNull);
      },
    );

    test(
      'loadCachedEarnings restores cached snapshot when available',
      () async {
        await repository.loadEarningsData();
        final cached = await repository.loadCachedEarnings();

        expect(cached, isNotNull);
        expect(cached!.status, DeliveryEarningsStatus.loaded);
        expect(cached.isFromCache, isTrue);
        expect(cached.walletBalance, 12850.00);
        expect(cached.transactions, hasLength(5));
      },
    );

    test('loadCachedEarnings returns null when no cache exists', () async {
      final cached = await repository.loadCachedEarnings();
      expect(cached, isNull);
    });

    test(
      'withdraw reduces balance and prepends withdrawal and transaction',
      () async {
        final initial = await repository.loadEarningsData();
        expect(initial.walletBalance, 12850.00);

        final updated = await repository.withdraw(500.00);

        expect(updated.walletBalance, 12350.00);
        expect(updated.withdrawalHistory, hasLength(4));
        expect(updated.withdrawalHistory.first.amount, 500.00);
        expect(updated.transactions, hasLength(6));
        expect(
          updated.transactions.first.type,
          EarningsTransactionType.withdrawal,
        );
      },
    );

    test('withdrawal state persists to cache and is restored', () async {
      await repository.loadEarningsData();
      await repository.withdraw(500.00);

      final fresh = DeliveryEarningsDashboardRepository(
        prefs: await SharedPreferences.getInstance(),
      );
      final cached = await fresh.loadCachedEarnings();

      expect(cached, isNotNull);
      expect(cached!.walletBalance, 12350.00);
      expect(cached.withdrawalHistory.first.amount, 500.00);
    });

    test('clearCache removes the persisted snapshot', () async {
      await repository.loadEarningsData();
      await repository.clearCache();

      final cached = await repository.loadCachedEarnings();
      expect(cached, isNull);
    });

    test('mediaUploadStream yields progress events', () async {
      final values = <double>[];
      await for (final progress in repository.mediaUploadStream()) {
        values.add(progress);
      }

      expect(values.last, 1.0);
      expect(values.length, greaterThan(1));
    });
  });
}
