import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('DeliveryWalletPage Security Tests', () {
    test('wallet payload contains no secrets or credentials', () async {
      final service = DeliveryWalletPageService(
        firestore: MockFirebaseFirestore(),
        auth: MockFirebaseAuth(),
      );
      final data = await service.fetchWalletData();
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

    test('withdraw response contains only transaction-safe fields', () async {
      final service = DeliveryWalletPageService(
        firestore: MockFirebaseFirestore(),
        auth: MockFirebaseAuth(),
      );
      await service.fetchWalletData();
      final result = await service.withdraw(100);
      expect(result['success'], isTrue);
      expect(result.toString(), isNot(contains('authorization')));
      expect(
        result.toString().contains(
              RegExp(r'(password|passwd|secret)', caseSensitive: false),
            ),
        isFalse,
      );
    });
  });
}
