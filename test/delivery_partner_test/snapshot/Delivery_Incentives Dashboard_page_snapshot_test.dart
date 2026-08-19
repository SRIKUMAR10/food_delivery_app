import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_repository.dart';

DeliveryIncentivesDashboardLoadedState buildLoadedState() {
  return DeliveryIncentivesDashboardLoadedState(
    targetDeadline: DateTime(2026, 8, 31),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DeliveryIncentivesDashboardPage Snapshot Tests', () {
    test('initial snapshot has default ranges and locale', () {
      const state = DeliveryIncentivesDashboardInitialState();

      expect(state.selectedRange, IncentivesDateRange.thisMonth);
      expect(state.localeCode, 'en');
    });

    test('copyWith produces an updated snapshot without mutating original', () {
      final initial = buildLoadedState();
      final updated = initial.copyWith(
        walletBalance: 3100.50,
        selectedRange: IncentivesDateRange.today,
        localeCode: 'ta',
      );

      expect(updated.walletBalance, 3100.50);
      expect(updated.selectedRange, IncentivesDateRange.today);
      expect(updated.localeCode, 'ta');
      expect(initial.walletBalance, 2450.00);
      expect(initial.selectedRange, IncentivesDateRange.thisMonth);
      expect(initial.localeCode, 'en');
      expect(updated == initial, isFalse);
    });

    test('loading, error and loaded snapshots differ only by state', () {
      const loading = DeliveryIncentivesDashboardLoadingState();
      const error = DeliveryIncentivesDashboardErrorState(errorMessage: 'boom');
      final loaded = buildLoadedState();

      expect(loaded == loading, isFalse);
      expect(loaded == error, isFalse);
      expect(loading.localeCode, error.localeCode);
      expect(loaded.selectedRange, loading.selectedRange);
    });

    test('range snapshot flips selected range and preserves metrics', () {
      final thisMonth = buildLoadedState();
      final today = thisMonth.copyWith(
        selectedRange: IncentivesDateRange.today,
      );

      expect(today.selectedRange, IncentivesDateRange.today);
      expect(today.walletBalance, thisMonth.walletBalance);
      expect(today.monthlyBonus, thisMonth.monthlyBonus);
    });

    test('filter snapshot keeps only matching reward records', () {
      final now = DateTime(2026, 7, 31);
      final loaded = buildLoadedState().copyWith(
        rewardHistory: [
          DeliveryIncentivesRewardRecord(
            id: 'r_1',
            title: 'Peak Hour Reward',
            date: now,
            amount: 120.00,
            type: RewardFilterType.peakHour,
            status: 'completed',
            referenceId: 'REF-1040',
          ),
          DeliveryIncentivesRewardRecord(
            id: 'r_2',
            title: 'Performance Reward',
            date: now,
            amount: 200.00,
            type: RewardFilterType.performance,
            status: 'completed',
            referenceId: 'REF-1041',
          ),
        ],
      );

      final filtered = loaded.copyWith(activeFilter: RewardFilterType.peakHour);

      expect(filtered.filteredRewards, hasLength(1));
      expect(filtered.filteredRewards.first.type, RewardFilterType.peakHour);
      expect(filtered.filteredTotal, 1);
      expect(filtered.totalPages, 1);
    });

    test('pagination snapshot slices the reward list', () {
      final now = DateTime(2026, 7, 31);
      final records = List.generate(
        12,
        (i) => DeliveryIncentivesRewardRecord(
          id: 'r_$i',
          title: 'Reward $i',
          date: now,
          amount: 100.00 + i,
          type: RewardFilterType.others,
          status: 'completed',
          referenceId: 'REF-10$i',
        ),
      );
      final loaded = buildLoadedState().copyWith(
        rewardHistory: records,
        pageSize: 5,
      );

      expect(loaded.filteredTotal, 12);
      expect(loaded.totalPages, 3);
      expect(loaded.paginatedRewards, hasLength(5));

      final pageTwo = loaded.copyWith(currentPage: 2);
      expect(pageTwo.paginatedRewards, hasLength(2));
      expect(pageTwo.paginatedRewards.first.id, 'r_10');
    });

    test('repository loaded snapshot matches default metrics', () async {
      final repository = DeliveryIncentivesDashboardRepository(
        prefs: await SharedPreferences.getInstance(),
      );
      final state = await repository.loadIncentivesData();

      expect(state.walletBalance, 2450.00);
      expect(state.todayBonus, 350.00);
      expect(state.weeklyBonus, 1250.00);
      expect(state.monthlyBonus, 4750.00);
      expect(state.targetProgress, 76.0);
      expect(state.achievements, hasLength(4));
      expect(state.donutSlices, hasLength(4));
      expect(state.milestones, hasLength(5));
      expect(state.rewardHistory, hasLength(16));
      expect(state.currentRangePoints, hasLength(4));
    });

    test('export snapshot produces a CSV of all reward records', () async {
      final repository = DeliveryIncentivesDashboardRepository(
        prefs: await SharedPreferences.getInstance(),
      );
      final state = await repository.loadIncentivesData();
      final csv = await repository.exportRewardHistory(state.rewardHistory);

      expect(csv, startsWith('Reference,Title,Date,Amount,Type,Status'));
      expect(csv.trim().split('\n'), hasLength(17));
      expect(csv, contains('REF-1040'));
    });
  });
}
