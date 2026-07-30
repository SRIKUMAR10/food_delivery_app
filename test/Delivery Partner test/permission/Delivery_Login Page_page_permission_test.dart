import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_service.dart';

class MockDeliveryLoginService extends Mock implements DeliveryLoginServiceBase {}

void main() {
  late MockDeliveryLoginService mockService;

  setUp(() {
    mockService = MockDeliveryLoginService();
  });

  group('DeliveryLoginPage Permission Tests', () {
    test('verifies storage permission state check', () async {
      when(() => mockService.checkStoragePermission()).thenAnswer((_) async => true);
      final permissionGranted = await mockService.checkStoragePermission();
      expect(permissionGranted, isTrue);
      verify(() => mockService.checkStoragePermission()).called(1);
    });
  });
}
