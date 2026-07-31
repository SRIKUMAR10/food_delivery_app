import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';

void main() {
  group('DeliveryDashboardPage Service Tests', () {
    test('fetchDashboardMetrics returns valid metric data', () async {
      final service = DeliveryDashboardService();
      final metrics = await service.fetchDashboardMetrics();

      expect(metrics['todayEarnings'], 2450.00);
      expect(metrics['walletBalance'], 2450.00);
      expect(metrics['todayOrdersCount'], 18);
      expect(metrics['activeOrdersCount'], 2);
      expect(metrics['partnerName'], 'Ravi Kumar');
      expect(metrics['vehicleNumber'], 'TN 01 AB 1234');
      expect((metrics['activities'] as List).length, 5);
    });

    test('updateOnlineStatus returns updated online status boolean', () async {
      final service = DeliveryDashboardService();

      expect(await service.updateOnlineStatus(true), isTrue);
      expect(await service.updateOnlineStatus(false), isFalse);
    });
  });
}
