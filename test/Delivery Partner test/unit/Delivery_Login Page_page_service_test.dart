import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_service.dart';

void main() {
  late DeliveryLoginService service;

  setUp(() {
    service = DeliveryLoginService();
  });

  group('DeliveryLoginService Unit Tests', () {
    test('checkNetworkConnectivity returns true', () async {
      final isOnline = await service.checkNetworkConnectivity();
      expect(isOnline, isTrue);
    });

    test('getEnvironmentVariables returns non-empty map with key defaults', () {
      final env = service.getEnvironmentVariables();
      expect(env, containsPair('BASE_URL', isNotNull));
      expect(env, containsPair('API_KEY', isNotNull));
      expect(env, containsPair('KEY_SECRET', isNotNull));
    });

    test('uploadVideoChunked emits progress from 0.1 to 1.0', () async {
      final stream = service.uploadVideoChunked('sample_video.mp4');
      final progressList = await stream.toList();

      expect(progressList.length, equals(10));
      expect(progressList.first, equals(0.1));
      expect(progressList.last, equals(1.0));
    });

    test('checkStoragePermission returns true', () async {
      final permission = await service.checkStoragePermission();
      expect(permission, isTrue);
    });
  });
}
