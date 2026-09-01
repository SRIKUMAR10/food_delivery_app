import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';

void main() {
  group('DeliverySettingsState Snapshot Tests', () {
    test('State snapshot serializes and restores fully without loss', () {
      const state = DeliverySettingsState(
        partnerId: 'DP-TEST-999',
        partnerName: 'Speedy Rider',
        phone: '+91 9876543210',
        vehicleType: 'EV Scooter',
        vehicleNumber: 'KA-01-EQ-9999',
        bankName: 'Axis Bank',
        bankAccountNumber: '918273645',
        bankAccountStatus: 'Verified',
        todayEarnings: 850.0,
        totalEarnings: 24500.0,
        completedOrdersCount: 120,
        estimatedDailyEarnings: 1800.0,
        deliveryRadius: 8.0,
      );

      final json = state.toJson();
      final restored = DeliverySettingsState.fromJson(json);

      expect(restored.partnerId, 'DP-TEST-999');
      expect(restored.partnerName, 'Speedy Rider');
      expect(restored.phone, '+91 9876543210');
      expect(restored.vehicleType, 'EV Scooter');
      expect(restored.vehicleNumber, 'KA-01-EQ-9999');
      expect(restored.bankName, 'Axis Bank');
      expect(restored.bankAccountNumber, '918273645');
      expect(restored.bankAccountStatus, 'Verified');
      expect(restored.todayEarnings, 850.0);
      expect(restored.totalEarnings, 24500.0);
      expect(restored.completedOrdersCount, 120);
      expect(restored.estimatedDailyEarnings, 1800.0);
      expect(restored.deliveryRadius, 8.0);
    });
  });
}
