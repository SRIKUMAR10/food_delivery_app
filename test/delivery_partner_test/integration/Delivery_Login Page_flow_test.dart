import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_ui.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_service.dart';

import '../../font_loader_helper.dart';

class MockDeliveryLoginRepository extends Mock
    implements DeliveryLoginRepositoryBase {}

class MockDeliveryLoginService extends Mock
    implements DeliveryLoginServiceBase {}

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

    when(
      () => mockService.checkNetworkConnectivity(),
    ).thenAnswer((_) async => true);
    when(() => mockRepository.getSavedPhone()).thenAnswer((_) async => null);
    SharedPreferences.setMockInitialValues({});
  });

  group('Delivery Login Page Integration Flow Tests', () {
    testWidgets('successful user flow login with phone number', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(
        () => mockRepository.loginWithPhone('+919876543210', 'password123'),
      ).thenAnswer(
        (_) async => DeliveryPartnerModel(
          id: 'partner-1',
          phoneNumber: '9876543210',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      );
      when(
        () => mockRepository.saveSavedPhone('9876543210'),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryLoginPage(
            repository: mockRepository,
            service: mockService,
          ),
          routes: {
            '/deliveryNavigationBar': (context) =>
                const Scaffold(body: Center(child: Text('Nav stub'))),
          },
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final phoneFinder = find.byType(TextField).at(0);
      final passwordFinder = find.byType(TextField).at(1);
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');

      await tester.enterText(phoneFinder, '9876543210');
      await tester.enterText(passwordFinder, 'password123');
      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(loginButton, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 600));

      verify(
        () => mockRepository.loginWithPhone('+919876543210', 'password123'),
      ).called(1);
      expect(find.text('Login successful! Welcome Partner.'), findsOneWidget);
    });
  });
}
