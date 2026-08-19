import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_state.dart';

void main() {
  group('DeliveryLoginPage Snapshot State Tests', () {
    test('initial state snapshot matches expected properties', () {
      const state = DeliveryLoginPageState();
      expect(state.status, equals(DeliveryLoginStatus.initial));
      expect(state.phone, isEmpty);
      expect(state.password, isEmpty);
      expect(state.isPasswordVisible, isFalse);
      expect(state.isRememberMeChecked, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.isLoggedIn, isFalse);
      expect(state.isForgotPasswordLoading, isFalse);
    });

    test('state copyWith preserves unmodified fields correctly', () {
      const state = DeliveryLoginPageState(
        phone: '9876543210',
        password: 'password123',
      );
      final copy = state.copyWith(isPasswordVisible: true);

      expect(copy.phone, equals('9876543210'));
      expect(copy.password, equals('password123'));
      expect(copy.isPasswordVisible, isTrue);
    });
  });
}
