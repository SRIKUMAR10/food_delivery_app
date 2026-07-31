import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_service.dart';

void main() {
  late DeliveryLoginService service;

  setUp(() {
    service = DeliveryLoginService();
  });

  group('DeliveryLoginService Unit Tests', () {
    test('checkNetworkConnectivity returns a boolean result', () async {
      final isOnline = await service.checkNetworkConnectivity();
      expect(isOnline, isA<bool>());
    });
  });
}
