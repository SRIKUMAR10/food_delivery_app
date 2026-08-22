import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';

class _FakeWalletService implements DeliveryWalletPageServiceBase {
  Map<String, dynamic> _payload() => {
        'walletBalance': 24580.50,
        'availableBalance': 24580.50,
        'pendingBalance': 0.00,
        'withdrawableAmount': 24580.50,
        'totalEarnings': 48250.00,
        'totalWithdrawn': 12000.00,
        'codAdjustment': 0.00,
      };

  @override
  Future<Map<String, dynamic>> fetchWalletData() async => _payload();

  @override
  Stream<Map<String, dynamic>> watchWalletData() =>
      Stream.value(_payload());

  @override
  Future<Map<String, dynamic>> withdraw(double amount) async => {
        'success': true,
        'walletBalance': 24580.50 - amount,
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
  Future<Map<String, dynamic>> addPaymentMethod(
    Map<String, dynamic> method,
  ) async =>
      {'success': true};

  @override
  Future<List<Map<String, dynamic>>> fetchReconciliationHistory() async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchTransactions(
    DeliveryWalletTransactionFilter filter,
  ) async =>
      [];

  @override
  Stream<List<Map<String, dynamic>>> watchTransactions(
    DeliveryWalletTransactionFilter filter,
  ) =>
      const Stream.empty();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('DeliveryWalletPage State Restoration Tests', () {
    test('cached wallet survives a repository recreation', () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = DeliveryWalletPageRepository(
        service: _FakeWalletService(),
        prefs: prefs,
      );
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
