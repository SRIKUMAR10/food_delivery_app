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
  });

  group('DeliveryLoginPage Accessibility Tests', () {
    testWidgets('meets minimum tap target size guidelines and semantic standards', (WidgetTester tester) async {
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

      final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
      expect(loginButtonFinder, findsOneWidget);

      final Size loginBtnSize = tester.getSize(loginButtonFinder);
      expect(loginBtnSize.height, greaterThanOrEqualTo(48.0));
      expect(loginBtnSize.width, greaterThanOrEqualTo(48.0));
    });
  });
}
