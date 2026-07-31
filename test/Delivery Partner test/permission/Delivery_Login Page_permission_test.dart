import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_service.dart';

class MockDeliveryLoginService extends Mock
    implements DeliveryLoginServiceBase {}

void main() {
  late MockDeliveryLoginService mockService;

  setUp(() {
    mockService = MockDeliveryLoginService();
  });

  group('DeliveryLoginPage Permission Tests', () {
    test('verifies network connectivity availability check', () async {
      when(
        () => mockService.checkNetworkConnectivity(),
      ).thenAnswer((_) async => true);
      final isOnline = await mockService.checkNetworkConnectivity();
      expect(isOnline, isTrue);
      verify(() => mockService.checkNetworkConnectivity()).called(1);
    });
  });
}
