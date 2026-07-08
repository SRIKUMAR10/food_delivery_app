import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';

void main() {
  group('Security and Sensitive Data Test', () {
    test('Ensure sensitive data like passwords are not logged in State', () {
      const state = ProfileLoaded(
        storeName: 'Test Store',
        email: 'test@test.com',
        phone: '1234567890',
        profileImageUrl: 'url',
        notificationsEnabled: true,
      );

      final stateString = state.toString();

      // We shouldn't see any field named password or token in the state's string representation
      expect(stateString.contains('password'), isFalse);
      expect(stateString.contains('token'), isFalse);
    });
  });
}
