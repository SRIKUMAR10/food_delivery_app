import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';

void main() {
  group('DeliverySettingsPage Security Tests', () {
    test('State serialization handles security and privacy flags safely', () {
      const state = DeliverySettingsState(
        biometricLockEnabled: true,
        twoFactorAuthEnabled: true,
        dataSharingConsent: false,
      );

      final json = state.toJson();
      expect(json['biometricLockEnabled'], isTrue);
      expect(json['twoFactorAuthEnabled'], isTrue);
      expect(json['dataSharingConsent'], isFalse);

      final restored = DeliverySettingsState.fromJson(json);
      expect(restored.biometricLockEnabled, isTrue);
      expect(restored.twoFactorAuthEnabled, isTrue);
      expect(restored.dataSharingConsent, isFalse);
    });
  });
}
