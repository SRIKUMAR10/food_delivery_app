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

    test('fetchWalletData returns an empty payload when unauthenticated', () async {
      final data = await service.fetchWalletData();

      expect(data, isEmpty);
      expect(data['walletBalance'], isNull);
    });

    test('watchWalletData emits an empty payload when unauthenticated', () async {
      final data = await service.watchWalletData().first;

      expect(data, isEmpty);
    });

    test('withdraw fails gracefully when unauthenticated', () async {
      final result = await service.withdraw(500.00);

      expect(result['success'], isFalse);
      expect(result['error'], isNotNull);
    });

    test('addPaymentMethod fails gracefully when unauthenticated', () async {
      final result = await service.addPaymentMethod({
        'id': 'pm_new',
        'type': 'UPI',
        'label': 'PhonePe',
        'maskedIdentifier': 'partner@okicici',
        'isDefault': false,
      });

      expect(result['success'], isFalse);
    });

    test('fetchTransactions returns an empty list when unauthenticated', () async {
      final income = await service.fetchTransactions(
        DeliveryWalletTransactionFilter.income,
      );
      expect(income, isEmpty);

      final all = await service.fetchTransactions(
        DeliveryWalletTransactionFilter.all,
      );
      expect(all, isEmpty);
    });

    test('watchTransactions emits an empty list when unauthenticated', () async {
      final all = await service
          .watchTransactions(DeliveryWalletTransactionFilter.all)
          .first;

      expect(all, isEmpty);
    });
  });
}
