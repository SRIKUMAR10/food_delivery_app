import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';

void main() {
  group('DeliveryWalletPage Security Tests', () {
    test('wallet payload contains no secrets or credentials', () async {
      final data = await DeliveryWalletPageService().fetchWalletData();
      final raw = data.toString();
      expect(
        raw.contains(
          RegExp(
            r'(password|passwd|secret|api[_-]?key|token)',
            caseSensitive: false,
          ),
        ),
        isFalse,
      );
    });

    test('bank and payment identifiers are masked', () async {
      final data = await DeliveryWalletPageService().fetchWalletData();
      final bank = data['bankAccount'] as Map<String, dynamic>;
      expect(bank['maskedAccountNumber'], isNot('4821'));
      final methods = data['paymentMethods'] as List;
      for (final method in methods) {
        final identifier = (method as Map)['maskedIdentifier'] as String;
        expect(identifier, isNotEmpty);
        expect(identifier.contains('****'), isFalse);
      }
    });

    test('api base url does not expose credentials', () {
      final url = DeliveryWalletPageService().apiBaseUrl;
      expect(url, isNotEmpty);
      expect(
        url.contains(
          RegExp(r'(token|password|secret|key)=', caseSensitive: false),
        ),
        isFalse,
      );
    });

    test('withdraw response contains only transaction-safe fields', () async {
      final service = DeliveryWalletPageService();
      await service.fetchWalletData();
      final result = await service.withdraw(100);
      expect(
        result.keys,
        containsAll(<String>['success', 'walletBalance', 'transaction']),
      );
      expect(result.toString(), isNot(contains('authorization')));
    });
  });
}
