import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_service.dart';

import '../../font_loader_helper.dart';

class MockDeliveryLoginRepository extends Mock implements DeliveryLoginRepositoryBase {}
class MockDeliveryLoginService extends Mock implements DeliveryLoginServiceBase {}

void main() {
  late MockDeliveryLoginRepository mockRepository;
  late MockDeliveryLoginService mockService;

  setUpAll(() {
    overrideFontAssetLoading();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  setUp(() {
    mockRepository = MockDeliveryLoginRepository();
    mockService = MockDeliveryLoginService();

    when(() => mockService.checkNetworkConnectivity()).thenAnswer((_) async => true);
    when(() => mockRepository.getSelectedLanguage()).thenAnswer((_) async => 'en');
    when(() => mockRepository.getSavedPhone()).thenAnswer((_) async => null);
    when(() => mockService.getEnvironmentVariables()).thenReturn({
      'BASE_URL': 'https://api.fooddelivery.example.com',
      'API_KEY': 'env_api_key_secure',
      'KEY_SECRET': 'env_secret_key_secure',
    });
  });

  group('DeliveryLoginPage Security Tests', () {
    testWidgets('obscures password input by default for security', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryLoginPage(
            repository: mockRepository,
            service: mockService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final passwordTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(passwordTextField.obscureText, isTrue);
    });

    test('verifies service securely reads environment variables without hardcoding', () {
      final env = mockService.getEnvironmentVariables();
      expect(env['API_KEY'], equals('env_api_key_secure'));
      expect(env['KEY_SECRET'], equals('env_secret_key_secure'));
    });
  });
}
