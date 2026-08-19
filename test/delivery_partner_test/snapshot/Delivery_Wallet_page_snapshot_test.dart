import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';

class _FakeWalletService implements DeliveryWalletPageServiceBase {
  @override
  Future<Map<String, dynamic>> fetchWalletData() async {
    return {
      'walletBalance': 24580.50,
      'totalEarnings': 128450.00,
      'transactions': List.generate(12, (i) {
        return {
          'id': 'txn_$i',
          'title': 'Delivery Earnings',
          'date': DateTime(2026, 8, 1).add(Duration(days: i)).toIso8601String(),
          'amount': 120.00 + i,
          'type': 'income',
          'status': 'completed',
        };
      }),
      'paymentMethods': [
        {
          'id': 'pm_1',
          'type': 'UPI',
          'label': 'Google Pay',
          'maskedIdentifier': 'ravi***@okbank',
          'isDefault': true,
        },
        {
          'id': 'pm_2',
          'type': 'Bank',
          'label': 'Bank Account',
          'maskedIdentifier': '****1234',
          'isDefault': false,
        },
        {
          'id': 'pm_3',
          'type': 'Card',
          'label': 'Debit Card',
          'maskedIdentifier': '****4321',
          'isDefault': false,
        },
      ],
      'earningsBreakdown': [
        {'label': 'Order Earnings', 'value': 80.0, 'colorHex': '#00E676'},
        {'label': 'Incentives', 'value': 10.0, 'colorHex': '#2979FF'},
        {'label': 'Bonuses', 'value': 6.0, 'colorHex': '#FFC400'},
        {'label': 'Tips', 'value': 4.0, 'colorHex': '#FF6D00'},
      ],
    };
  }

  @override
  Stream<Map<String, dynamic>> watchWalletData() =>
      const Stream<Map<String, dynamic>>.empty();

  @override
  Future<Map<String, dynamic>> withdraw(double amount) async => {};

  @override
  Future<Map<String, dynamic>> submitCash({
    required double amount,
    required String method,
  }) async {
    return {'success': true};
  }

  @override
  Future<List<Map<String, dynamic>>> fetchReconciliationHistory() async => [];

  @override
  Future<Map<String, dynamic>> addPaymentMethod(
    Map<String, dynamic> method,
  ) async {
    return method;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTransactions(
    DeliveryWalletTransactionFilter filter,
  ) async {
    return [];
  }

  @override
  Stream<List<Map<String, dynamic>>> watchTransactions(
    DeliveryWalletTransactionFilter filter,
  ) {
    return const Stream<List<Map<String, dynamic>>>.empty();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('DeliveryWalletPage Snapshot Tests', () {
    test('initial state has stable wallet defaults', () {
      const state = DeliveryWalletPageState();
      expect(state.status, DeliveryWalletStatus.initial);
      expect(state.walletBalance, 0.0);
      expect(state.totalEarnings, 0.0);
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
      expect(initial.walletBalance, 0.0);
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
        service: _FakeWalletService(),
        prefs: await SharedPreferences.getInstance(),
      );
      final state = await repository.loadWalletData();
      expect(state.transactions, hasLength(12));
      expect(state.paymentMethods, hasLength(3));
      expect(state.earningsBreakdown, hasLength(4));
    });
  });
}
