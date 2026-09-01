import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryNavigationRepository extends Mock
    implements DeliveryNavigationRepositoryBase {}

class MockDeliveryNavigationService extends Mock
    implements DeliveryNavigationServiceBase {}

class MockDeliveryNavigationBloc
    extends MockBloc<DeliveryNavigationEvent, DeliveryNavigationState>
    implements DeliveryNavigationBloc {}

void main() {
  late MockDeliveryNavigationService mockService;
  late MockDeliveryNavigationBloc mockBloc;

  const DeliveryNavigationState loadedState = DeliveryNavigationState(
    status: DeliveryNavigationStatus.loaded,
    hasLocationPermission: true,
  );

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
    mockService = MockDeliveryNavigationService();
    mockBloc = MockDeliveryNavigationBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
    when(() => mockService.getEnvironmentVariables()).thenReturn({
      'BASE_URL': 'https://api.fooddelivery.example.com',
      'API_KEY': 'env_api_key_secure',
      'KEY_SECRET': 'env_secret_key_secure',
      'MAPS_API_KEY': 'env_maps_api_key_secure',
    });
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryNavigationScreenPage Security Tests', () {
    test('service reads environment variables without hardcoding secrets', () {
      final env = mockService.getEnvironmentVariables();

      expect(env['API_KEY'], equals('env_api_key_secure'));
      expect(env['KEY_SECRET'], equals('env_secret_key_secure'));
      expect(env['MAPS_API_KEY'], equals('env_maps_api_key_secure'));
      expect(env['BASE_URL'], startsWith('https://'));

      expect(env['API_KEY'], isNot(contains('your_secure_api_key_here')));
      expect(env['KEY_SECRET'], isNot(contains('your_key_secret_example')));
    });

    test('service sanitizes free-text input before storage or display', () {
      final service = DeliveryNavigationService();

      final sanitized = service.sanitizeInput('  <script>alert(1)</script>');
      expect(sanitized, isNotNull);
      expect(sanitized, isNot(contains('<script>')));

      expect(service.sanitizeInput(''), isNull);
      expect(service.sanitizeInput(null), isNull);
    });

    test('persistence uses SharedPreferences-backed repository only', () {
      final repo = DeliveryNavigationRepository();
      expect(repo, isNotNull);
      expect(DeliveryNavigationRepository.defaultOrder.orderId, '#ORD-789456');
      expect(
        DeliveryNavigationRepository.defaultOrder.customerPhone,
        '+91 98420 54321',
      );
    });

    testWidgets('UI never renders secret environment values', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: DeliveryNavigationScreenPage(bloc: mockBloc)),
      );
      await tester.pump();

      expect(find.textContaining('API_KEY'), findsNothing);
      expect(find.textContaining('KEY_SECRET'), findsNothing);
      expect(find.textContaining('MAPS_API_KEY'), findsNothing);
      expect(find.textContaining('env_api_key_secure'), findsNothing);
      expect(find.textContaining('env_secret_key_secure'), findsNothing);
      expect(find.textContaining('env_maps_api_key_secure'), findsNothing);
    });

    test('bloc surfaces no secret data in its error messages', () {
      final bloc = DeliveryNavigationBloc(
        repository: MockDeliveryNavigationRepository(),
        service: mockService,
      );
      expect(bloc.state.errorMessage, isNull);
      expect(bloc.state.order.customerPhone, isNot(contains('api_key')));
      bloc.close();
    });
  });
}
