import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('DeliveryWalletPage Snapshot Tests', () {
    test('initial state has stable wallet defaults', () {
      const state = DeliveryWalletPageState();
      expect(state.status, DeliveryWalletStatus.initial);
      expect(state.walletBalance, 24580.50);
      expect(state.totalEarnings, 128450.00);
      expect(state.activeFilter, DeliveryWalletTransactionFilter.all);
      expect(state.selectedPeriod, DeliveryWalletPeriod.thisMonth);
    });

    test('copyWith is immutable and preserves unrelated values', () {
      const initial = DeliveryWalletPageState();
      final updated = initial.copyWith(
        walletBalance: 1000,
        activeFilter: DeliveryWalletTransactionFilter.income,
      );
      expect(updated.walletBalance, 1000);
      expect(updated.activeFilter, DeliveryWalletTransactionFilter.income);
      expect(initial.walletBalance, 24580.50);
      expect(initial.activeFilter, DeliveryWalletTransactionFilter.all);
    });

    test('filteredTransactions returns the selected category', () {
      final transactions = [
        DeliveryWalletTransaction(
          id: 'income',
          title: 'Income',
          date: DateTime(2026, 1, 1),
          amount: 1,
          type: 'income',
          status: 'completed',
        ),
        DeliveryWalletTransaction(
          id: 'bonus',
          title: 'Bonus',
          date: DateTime(2026, 1, 1),
          amount: 1,
          type: 'bonus',
          status: 'completed',
        ),
      ];
      final state = DeliveryWalletPageState(
        transactions: transactions,
        activeFilter: DeliveryWalletTransactionFilter.bonuses,
      );
      expect(state.filteredTransactions.single.id, 'bonus');
    });

    test('repository snapshot contains complete mock data', () async {
      final repository = DeliveryWalletPageRepository(
        prefs: await SharedPreferences.getInstance(),
      );
      final state = await repository.loadWalletData();
      expect(state.transactions, hasLength(12));
      expect(state.paymentMethods, hasLength(3));
      expect(state.earningsBreakdown, hasLength(4));
    });
  });
}
