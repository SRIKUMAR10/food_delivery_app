import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('DeliveryWalletPage Service Tests', () {
    late DeliveryWalletPageService service;

    setUp(() {
      service = DeliveryWalletPageService(
        firestore: MockFirebaseFirestore(),
        auth: MockFirebaseAuth(),
      );
    });

    test('fetchWalletData returns valid wallet payload data', () async {
      final data = await service.fetchWalletData();

      expect(data['walletBalance'], 2450.00);
      expect(data['totalEarnings'], 48500.00);
      expect(data['todayEarnings'], 2450.00);
      expect(data['pendingWithdrawal'], 500.00);
      expect(data['lastUpdated'], isA<String>());
    });

    test('withdraw returns a success record', () async {
      final result = await service.withdraw(500.00);

      expect(result['success'], isTrue);
    });

    test('addPaymentMethod returns a success record', () async {
      final result = await service.addPaymentMethod({
        'id': 'pm_new',
        'type': 'UPI',
        'label': 'PhonePe',
        'maskedIdentifier': 'partner@okicici',
        'isDefault': false,
      });

      expect(result['success'], isTrue);
    });

    test('fetchTransactions filters by type', () async {
      final income = await service.fetchTransactions(
        DeliveryWalletTransactionFilter.income,
      );
      expect(income, isNotEmpty);
      expect(income.every((t) => ((t['amount'] as num?) ?? 0) > 0), isTrue);

      final withdrawals = await service.fetchTransactions(
        DeliveryWalletTransactionFilter.withdrawals,
      );
      expect(withdrawals, isNotEmpty);
      expect(
        withdrawals.every((t) => ((t['amount'] as num?) ?? 0) < 0),
        isTrue,
      );

      final all = await service.fetchTransactions(
        DeliveryWalletTransactionFilter.all,
      );
      expect(all, isNotEmpty);
    });
  });
}
