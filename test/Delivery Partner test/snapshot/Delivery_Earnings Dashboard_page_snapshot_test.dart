import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DeliveryEarningsDashboardPage Snapshot Tests', () {
    test('initial snapshot has default metrics and overview tab', () {
      const state = DeliveryEarningsDashboardState();

      expect(state.status, DeliveryEarningsStatus.initial);
      expect(state.totalEarnings, 12850.00);
      expect(state.todayEarnings, 2450.00);
      expect(state.weeklyEarnings, 12850.00);
      expect(state.monthlyEarnings, 48900.00);
      expect(state.earningsGrowth, 18.5);
      expect(state.walletBalance, 12850.00);
      expect(state.pendingWithdrawal, 1200.00);
      expect(state.totalWithdrawn, 48250.00);
      expect(state.selectedRange, EarningsDateRange.today);
      expect(state.selectedTab, EarningsTab.overview);
      expect(state.rangeEarnings, isEmpty);
      expect(state.transactions, isEmpty);
      expect(state.withdrawalHistory, isEmpty);
      expect(state.mediaUploadProgress, 0.0);
      expect(state.isMediaUploading, isFalse);
      expect(state.isWithdrawing, isFalse);
      expect(state.isFromCache, isFalse);
    });

    test('copyWith produces an updated snapshot without mutating original', () {
      const initial = DeliveryEarningsDashboardState();
      final updated = initial.copyWith(
        walletBalance: 3100.50,
        selectedRange: EarningsDateRange.thisWeek,
        selectedTab: EarningsTab.withdrawals,
      );

      expect(updated.walletBalance, 3100.50);
      expect(updated.selectedRange, EarningsDateRange.thisWeek);
      expect(updated.selectedTab, EarningsTab.withdrawals);
      expect(initial.walletBalance, 12850.00);
      expect(initial.selectedRange, EarningsDateRange.today);
      expect(initial.selectedTab, EarningsTab.overview);
      expect(updated == initial, isFalse);
    });

    test('loading, loaded and error snapshots differ only by status', () {
      const loaded = DeliveryEarningsDashboardState(
        status: DeliveryEarningsStatus.loaded,
      );
      const loading = DeliveryEarningsDashboardState(
        status: DeliveryEarningsStatus.loading,
      );
      const error = DeliveryEarningsDashboardState(
        status: DeliveryEarningsStatus.error,
        errorMessage: 'boom',
      );

      expect(loaded == loading, isFalse);
      expect(loaded == error, isFalse);
      expect(loaded.walletBalance, error.walletBalance);
      expect(loaded.selectedTab, error.selectedTab);
    });

    test('range snapshot flips selected range and preserves metrics', () {
      const today = DeliveryEarningsDashboardState(
        selectedRange: EarningsDateRange.today,
      );
      final thisMonth = today.copyWith(
        selectedRange: EarningsDateRange.thisMonth,
      );

      expect(thisMonth.selectedRange, EarningsDateRange.thisMonth);
      expect(thisMonth.walletBalance, today.walletBalance);
    });

    test('media upload snapshot tracks progress and uploading flag', () {
      const idle = DeliveryEarningsDashboardState();
      final uploading = idle.copyWith(
        isMediaUploading: true,
        mediaUploadProgress: 0.4,
      );
      final done = uploading.copyWith(
        isMediaUploading: false,
        mediaUploadProgress: 1.0,
      );

      expect(uploading.isMediaUploading, isTrue);
      expect(uploading.mediaUploadProgress, 0.4);
      expect(done.isMediaUploading, isFalse);
      expect(done.mediaUploadProgress, 1.0);
    });

    test('repository loaded snapshot matches default metrics', () async {
      final repository = DeliveryEarningsDashboardRepository(
        prefs: await SharedPreferences.getInstance(),
      );
      final state = await repository.loadEarningsData();

      expect(state.status, DeliveryEarningsStatus.loaded);
      expect(state.walletBalance, 12850.00);
      expect(state.totalEarnings, 12850.00);
      expect(state.transactions, hasLength(5));
      expect(state.withdrawalHistory, hasLength(3));
      expect(state.currentRangePoints, hasLength(8));
    });

    test('withdrawal snapshot reduces balance and persists', () async {
      final repository = DeliveryEarningsDashboardRepository(
        prefs: await SharedPreferences.getInstance(),
      );
      await repository.loadEarningsData();
      final afterWithdraw = await repository.withdraw(500.00);

      expect(afterWithdraw.walletBalance, 12350.00);
      expect(afterWithdraw.withdrawalHistory, hasLength(4));
      expect(afterWithdraw.transactions, hasLength(6));
    });
  });
}
