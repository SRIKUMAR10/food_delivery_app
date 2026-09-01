import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_service.dart';

void main() {
  late DeliverySettingsService service;

  setUp(() {
    service = DeliverySettingsService();
  });

  test('requestNotificationPermission and location permissions resolve', () async {
    expect(await service.requestNotificationPermission(), isTrue);
    expect(await service.requestLocationPermission(), isTrue);
  });
}
