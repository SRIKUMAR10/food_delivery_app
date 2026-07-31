import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';

void main() {
  group('DeliveryWalletPage Service Tests', () {
    test('fetchWalletData returns valid wallet payload data', () async {
      final service = DeliveryWalletPageService();
      final data = await service.fetchWalletData();

      expect(data['walletBalance'], 24580.50);
      expect(data['totalEarnings'], 128450.00);
      expect(data['totalWithdrawn'], 89450.00);
      expect(data['bonusEarnings'], 12500.00);
      expect(data['transactions'], hasLength(12));
      expect(data['paymentMethods'], hasLength(3));

      final bankAccount = data['bankAccount'] as Map<String, dynamic>;
      expect(bankAccount['bankName'], 'HDFC Bank');
      expect(bankAccount['accountHolder'], 'Ravi Kumar');

      expect(data['settlementSchedule'], hasLength(3));

      final periods = data['periodEarnings'] as Map<String, dynamic>;
      expect(periods['thisWeek'], hasLength(7));
      expect(periods['thisMonth'], hasLength(5));
      expect(periods['lastMonth'], hasLength(4));
      expect(periods['last3Months'], hasLength(3));

      expect(data['earningsBreakdown'], hasLength(4));
    });

    test('fetchWalletData serves cached payload within lifetime', () async {
      final service = DeliveryWalletPageService();
      final first = await service.fetchWalletData();
      final second = await service.fetchWalletData();

      expect(second, same(first));
      expect(second['walletBalance'], 24580.50);
    });

    test(
      'withdraw computes a reduced wallet balance and returns a record',
      () async {
        final service = DeliveryWalletPageService();
        await service.fetchWalletData();
        final result = await service.withdraw(500.00);

        expect(result['success'], isTrue);
        expect(result['walletBalance'], 24080.50);
        expect((result['transaction'] as Map)['type'], 'withdrawal');
        expect((result['transaction'] as Map)['amount'], 500.00);

        final updated = await service.fetchWalletData();
        expect(updated['walletBalance'], 24080.50);
      },
    );

    test(
      'addPaymentMethod appends a new method to the cached payload',
      () async {
        final service = DeliveryWalletPageService();
        await service.fetchWalletData();

        await service.addPaymentMethod({
          'id': 'pm_new',
          'type': 'UPI',
          'label': 'PhonePe',
          'maskedIdentifier': 'partner@okicici',
          'isDefault': false,
        });

        final updated = await service.fetchWalletData();
        final methods = updated['paymentMethods'] as List;
        expect(methods, hasLength(4));
        expect((methods.last as Map)['label'], 'PhonePe');
      },
    );

    test('fetchTransactions filters by type', () async {
      final service = DeliveryWalletPageService();
      await service.fetchWalletData();

      final income = await service.fetchTransactions(
        DeliveryWalletTransactionFilter.income,
      );
      expect(income, isNotEmpty);
      expect(income.every((t) => t['type'] == 'income'), isTrue);

      final withdrawals = await service.fetchTransactions(
        DeliveryWalletTransactionFilter.withdrawals,
      );
      expect(withdrawals, isNotEmpty);
      expect(withdrawals.every((t) => t['type'] == 'withdrawal'), isTrue);

      final bonuses = await service.fetchTransactions(
        DeliveryWalletTransactionFilter.bonuses,
      );
      expect(bonuses, isNotEmpty);
      expect(bonuses.every((t) => t['type'] == 'bonus'), isTrue);
    });

    test('api base url falls back safely', () {
      final service = DeliveryWalletPageService();
      expect(service.apiBaseUrl, isNotEmpty);
      expect(service.apiBaseUrl, startsWith('https://'));
    });
  });
}
