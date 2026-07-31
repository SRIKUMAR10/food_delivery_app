import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';

class MockDeliveryIncentivesDashboardService extends Mock
    implements DeliveryIncentivesDashboardServiceBase {}

void main() {
  late DeliveryIncentivesDashboardRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = DeliveryIncentivesDashboardRepository(prefs: prefs);
  });

  group('DeliveryIncentivesDashboardPage Repository Tests', () {
    test(
      'loadIncentivesData returns loaded state with correct metrics',
      () async {
        final state = await repository.loadIncentivesData();

        expect(state.walletBalance, 2450.00);
        expect(state.todayBonus, 350.00);
        expect(state.todayBonusGrowth, 12.5);
        expect(state.weeklyBonus, 1250.00);
        expect(state.weeklyBonusGrowth, 18.6);
        expect(state.monthlyBonus, 4750.00);
        expect(state.monthlyBonusGrowth, 24.3);
        expect(state.targetProgress, 76.0);
        expect(state.targetEarned, 7650.00);
        expect(state.targetGoal, 10000.00);
        expect(state.isFromCache, isFalse);
      },
    );

    test(
      'loadIncentivesData parses chart, achievements and milestones',
      () async {
        final state = await repository.loadIncentivesData();

        expect(state.achievements, hasLength(4));
        expect(state.achievements.first.title, 'Early Bird');
        expect(state.donutSlices, hasLength(4));
        expect(state.milestones, hasLength(5));
        expect(
          state.milestones.first.status,
          DeliveryIncentivesMilestoneStatus.completed,
        );
        expect(state.currentRangePoints, isNotEmpty);
      },
    );

    test('loadIncentivesData parses the full reward history', () async {
      final state = await repository.loadIncentivesData();

      expect(state.rewardHistory, hasLength(32));
      expect(state.rewardHistory.first.referenceId, 'REF-1040');
      expect(state.filteredTotal, 32);
    });

    test(
      'loadIncentivesData persists a local cache for offline fallback',
      () async {
        await repository.loadIncentivesData();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('dp_incentives_cache_v1'), isNotNull);
      },
    );

    test(
      'loadCachedIncentives restores cached snapshot when available',
      () async {
        await repository.loadIncentivesData();
        final cached = await repository.loadCachedIncentives();

        expect(cached, isNotNull);
        expect(cached!.isFromCache, isTrue);
        expect(cached.walletBalance, 2450.00);
        expect(cached.rewardHistory, hasLength(32));
      },
    );

    test('loadCachedIncentives returns null when no cache exists', () async {
      final cached = await repository.loadCachedIncentives();
      expect(cached, isNull);
    });

    test('clearCache removes the persisted snapshot', () async {
      await repository.loadIncentivesData();
      await repository.clearCache();

      final cached = await repository.loadCachedIncentives();
      expect(cached, isNull);
    });

    test('falls back to cached data when the remote service fails', () async {
      await repository.loadIncentivesData();

      final failingService = MockDeliveryIncentivesDashboardService();
      when(
        () => failingService.fetchIncentivesData(),
      ).thenThrow(Exception('offline'));

      final offlineRepository = DeliveryIncentivesDashboardRepository(
        service: failingService,
        prefs: await SharedPreferences.getInstance(),
      );

      final state = await offlineRepository.loadIncentivesData();
      expect(state.isFromCache, isTrue);
      expect(state.walletBalance, 2450.00);
    });

    test('rethrows when service fails and no cache is available', () async {
      final failingService = MockDeliveryIncentivesDashboardService();
      when(
        () => failingService.fetchIncentivesData(),
      ).thenThrow(Exception('offline'));

      final offlineRepository = DeliveryIncentivesDashboardRepository(
        service: failingService,
        prefs: await SharedPreferences.getInstance(),
      );

      expect(
        () => offlineRepository.loadIncentivesData(),
        throwsA(isA<Exception>()),
      );
    });

    test('exportRewardHistory produces a CSV payload', () async {
      final state = await repository.loadIncentivesData();
      final csv = await repository.exportRewardHistory(state.rewardHistory);

      expect(csv, startsWith('Reference,Title,Date,Amount,Type,Status'));
      expect(csv.trim().split('\n'), hasLength(33));
      expect(csv, contains('REF-1040'));
    });
  });
}
