import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_state.dart';

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
      expect(state.selectedLanguage, equals('en'));
      expect(state.uploadProgress, equals(0.0));
      expect(state.isLoggedIn, isFalse);
    });

    test('state copyWith preserves unmodified fields correctly', () {
      const state = DeliveryLoginPageState(phone: '9876543210', password: 'password123');
      final copy = state.copyWith(isPasswordVisible: true);

      expect(copy.phone, equals('9876543210'));
      expect(copy.password, equals('password123'));
      expect(copy.isPasswordVisible, isTrue);
    });
  });
}
