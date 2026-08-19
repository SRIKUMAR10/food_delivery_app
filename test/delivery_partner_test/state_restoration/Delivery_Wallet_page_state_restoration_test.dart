import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('DeliveryWalletPage State Restoration Tests', () {
    test('cached wallet survives a repository recreation', () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = DeliveryWalletPageRepository(prefs: prefs);
      await repository.loadWalletData();
      await repository.withdraw(500);

      final restored = DeliveryWalletPageRepository(prefs: prefs);
      final state = await restored.loadCachedWallet();
      expect(state, isNotNull);
      expect(state!.isFromCache, isTrue);
      expect(state.walletBalance, 24080.50);
    });

    test('copyWith preserves selected period and filter across updates', () {
      const state = DeliveryWalletPageState(
        activeFilter: DeliveryWalletTransactionFilter.withdrawals,
        selectedPeriod: DeliveryWalletPeriod.lastMonth,
      );
      final restored = state.copyWith(walletBalance: 1000);
      expect(
        restored.activeFilter,
        DeliveryWalletTransactionFilter.withdrawals,
      );
      expect(restored.selectedPeriod, DeliveryWalletPeriod.lastMonth);
      expect(restored.walletBalance, 1000);
    });
  });
}
