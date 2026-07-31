import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';

void main() {
  late DeliveryWalletPageRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = DeliveryWalletPageRepository(prefs: prefs);
  });

  group('DeliveryWalletPage Repository Tests', () {
    test('loadWalletData returns loaded status with correct metrics', () async {
      final state = await repository.loadWalletData();

      expect(state.status, DeliveryWalletStatus.loaded);
      expect(state.isFromCache, isFalse);
      expect(state.walletBalance, 24580.50);
      expect(state.totalEarnings, 128450.00);
      expect(state.totalWithdrawn, 89450.00);
      expect(state.bonusEarnings, 12500.00);
      expect(state.transactions, hasLength(12));
      expect(state.paymentMethods, hasLength(3));
      expect(state.bankAccount, isNotNull);
      expect(state.bankAccount!.bankName, 'HDFC Bank');
      expect(state.settlementSchedule, hasLength(3));
      expect(state.earningsBreakdown, hasLength(4));
      expect(state.currentPeriodPoints, hasLength(5));
    });

    test(
      'loadWalletData persists a local cache for offline fallback',
      () async {
        await repository.loadWalletData();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('dp_wallet_cache_v1'), isNotNull);
      },
    );

    test('loadCachedWallet restores cached snapshot when available', () async {
      await repository.loadWalletData();
      final cached = await repository.loadCachedWallet();

      expect(cached, isNotNull);
      expect(cached!.status, DeliveryWalletStatus.loaded);
      expect(cached.isFromCache, isTrue);
      expect(cached.walletBalance, 24580.50);
      expect(cached.transactions, hasLength(12));
    });

    test('loadCachedWallet returns null when no cache exists', () async {
      final cached = await repository.loadCachedWallet();
      expect(cached, isNull);
    });

    test(
      'withdraw reduces balance and prepends withdrawal transaction',
      () async {
        final initial = await repository.loadWalletData();
        expect(initial.walletBalance, 24580.50);

        final updated = await repository.withdraw(500.00);

        expect(updated.walletBalance, 24080.50);
        expect(updated.transactions, hasLength(13));
        expect(updated.transactions.first.type, 'withdrawal');
        expect(updated.transactions.first.amount, 500.00);
      },
    );

    test('withdrawal state persists to cache and is restored', () async {
      await repository.loadWalletData();
      await repository.withdraw(500.00);

      final fresh = DeliveryWalletPageRepository(
        prefs: await SharedPreferences.getInstance(),
      );
      final cached = await fresh.loadCachedWallet();

      expect(cached, isNotNull);
      expect(cached!.walletBalance, 24080.50);
      expect(cached.transactions.first.amount, 500.00);
    });

    test('filterTransactions returns only income transactions', () async {
      await repository.loadWalletData();

      final income = await repository.filterTransactions(
        DeliveryWalletTransactionFilter.income,
      );
      expect(income, isNotEmpty);
      expect(income.every((t) => t.type == 'income'), isTrue);

      final withdrawals = await repository.filterTransactions(
        DeliveryWalletTransactionFilter.withdrawals,
      );
      expect(withdrawals, isNotEmpty);
      expect(withdrawals.every((t) => t.type == 'withdrawal'), isTrue);

      final bonuses = await repository.filterTransactions(
        DeliveryWalletTransactionFilter.bonuses,
      );
      expect(bonuses, isNotEmpty);
      expect(bonuses.every((t) => t.type == 'bonus'), isTrue);
    });

    test('addPaymentMethod appends a new payment method', () async {
      await repository.loadWalletData();

      final updated = await repository.addPaymentMethod(
        const DeliveryPaymentMethod(
          id: 'pm_new',
          type: 'UPI',
          label: 'PhonePe',
          maskedIdentifier: 'partner@okicici',
          isDefault: false,
        ),
      );

      expect(updated.paymentMethods, hasLength(4));
      expect(updated.paymentMethods.last.label, 'PhonePe');
      expect(updated.paymentMethods.last.maskedIdentifier, 'partner@okicici');
    });

    test('clearCache removes the persisted snapshot', () async {
      await repository.loadWalletData();
      await repository.clearCache();

      final cached = await repository.loadCachedWallet();
      expect(cached, isNull);
    });
  });
}
