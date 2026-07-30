import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_service.dart';

void main() {
  late DeliveryOnboardingService service;

  setUp(() {
    service = DeliveryOnboardingService();
  });

  group('DeliveryOnboardingService Unit Tests', () {
    test('checkNetworkConnectivity returns true', () async {
      final isOnline = await service.checkNetworkConnectivity();
      expect(isOnline, true);
    });

    test('uploadVideoChunked streams upload progress from 0 to 1.0', () async {
      final progressList = <double>[];
      await for (final progress in service.uploadVideoChunked('test_video.mp4')) {
        progressList.add(progress);
      }
      expect(progressList.isNotEmpty, true);
      expect(progressList.last, 1.0);
    });
  });
}
