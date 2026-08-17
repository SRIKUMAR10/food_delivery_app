import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';

void main() {
  group('Security and Sensitive Data Tests for Restaurant Profile', () {
    test('Ensure sensitive data like passwords or tokens are not leaked in State', () {
      final state = ProfileLoaded(
        storeName: 'Secured Kitchen',
        email: 'seller@secured.com',
        phone: '1234567890',
        profileImageUrl: 'https://example.com/img.jpg',
        coverImageUrl: 'https://example.com/cover.jpg',
        notificationsEnabled: true,
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
        role: 'seller',
      );

      final stateString = state.toString();

      // Rule #9 Compliance: We must not expose password, secret token, bank credential
      expect(stateString.contains('password'), isFalse);
      expect(stateString.contains('token'), isFalse);
      expect(stateString.contains('secretKey'), isFalse);
    });

    test('SellerModel toMap does not expose secret keys', () {
      final model = SellerModel(
        id: 'seller_123',
        name: 'Test Kitchen',
        email: 'seller@test.com',
        shopName: 'Test Kitchen',
        createdAt: DateTime(2025, 1, 1),
      );

      final map = model.toMap();
      expect(map.containsKey('password'), isFalse);
      expect(map.containsKey('secretKey'), isFalse);
      expect(map.containsKey('authToken'), isFalse);
    });
  });
}
