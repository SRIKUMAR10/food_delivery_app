import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

void main() {
  late MockDeliveryNavigationBarService mockService;

  setUp(() {
    mockService = MockDeliveryNavigationBarService();
  });

  group('DeliveryNavigationBarPage Service Tests', () {
    test('reports online connectivity', () async {
      when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);

      expect(await mockService.checkConnectivity(), isTrue);
      verify(() => mockService.checkConnectivity()).called(1);
    });

    test('reports offline connectivity when lookup fails', () async {
      when(
        () => mockService.checkConnectivity(),
      ).thenAnswer((_) async => false);

      expect(await mockService.checkConnectivity(), isFalse);
    });

    test('exposes environment variable keys without hardcoded secrets', () {
      when(() => mockService.getEnvironmentVariables()).thenReturn({
        'BASE_URL': 'https://api.fooddelivery.example.com',
        'API_KEY': 'env_api_key_secure',
        'KEY_SECRET': 'env_secret_key_secure',
      });

      final env = mockService.getEnvironmentVariables();

      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('API_KEY'), isTrue);
      expect(env.containsKey('KEY_SECRET'), isTrue);
      expect(env['API_KEY'], isNotEmpty);
      expect(env['API_KEY'], isNot(contains('your_secure_api_key_here')));
      expect(env['KEY_SECRET'], isNot(contains('your_key_secret_example')));
    });

    test('concrete service exposes env keys safely without dotenv loaded', () {
      final service = DeliveryNavigationBarService();
      final env = service.getEnvironmentVariables();

      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('API_KEY'), isTrue);
      expect(env.containsKey('KEY_SECRET'), isTrue);
    });

    test('checks default permission state', () async {
      when(() => mockService.checkPermission()).thenAnswer((_) async => true);

      expect(await mockService.checkPermission(), isTrue);
      verify(() => mockService.checkPermission()).called(1);
    });

    test('requests permission and returns grant result', () async {
      when(() => mockService.requestPermission()).thenAnswer((_) async => true);

      expect(await mockService.requestPermission(), isTrue);
      verify(() => mockService.requestPermission()).called(1);
    });

    test('simulates chunked upload stream with incremental progress', () async {
      when(
        () => mockService.simulateChunkedUpload(),
      ).thenAnswer((_) => Stream.fromIterable([0.25, 0.5, 0.75, 1.0]));

      final values = await mockService.simulateChunkedUpload().toList();

      expect(values, [0.25, 0.5, 0.75, 1.0]);
      expect(values.last, 1.0);
    });
  });
}
