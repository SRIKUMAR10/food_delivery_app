import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';

void main() {
  group('DeliverySettingsState State Restoration Tests', () {
    test('copyWith updates state immutably and preserves unmodified fields', () {
      const initial = DeliverySettingsState(
        deliveryRadius: 5.0,
        notificationsEnabled: true,
        autoAcceptEnabled: true,
        languageCode: 'en',
      );

      final updated = initial.copyWith(
        deliveryRadius: 10.0,
        notificationsEnabled: false,
      );

      expect(updated.deliveryRadius, 10.0);
      expect(updated.notificationsEnabled, isFalse);
      expect(updated.autoAcceptEnabled, isTrue);
      expect(updated.languageCode, 'en');
    });
  });
}
