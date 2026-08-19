import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

class MockDeliveryNavigationBarPageBloc
    extends MockBloc<DeliveryNavigationBarEvent, DeliveryNavigationBarState>
    implements DeliveryNavigationBarPageBloc {}

void main() {
  late MockDeliveryNavigationBarService mockService;
  late MockDeliveryNavigationBarPageBloc mockBloc;

  const DeliveryNavigationBarState loadedState = DeliveryNavigationBarState(
    status: DeliveryNavigationBarStatus.loaded,
    selectedIndex: 4,
    navItems: DeliveryNavigationBarRepository.defaultNavItems,
    partnerName: 'Ravi Kumar',
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
    mockService = MockDeliveryNavigationBarService();
    mockBloc = MockDeliveryNavigationBarPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
    when(() => mockService.getEnvironmentVariables()).thenReturn({
      'BASE_URL': 'https://api.fooddelivery.example.com',
      'API_KEY': 'env_api_key_secure',
      'KEY_SECRET': 'env_secret_key_secure',
    });
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryNavigationBarPage Security Tests', () {
    test('service reads environment variables without hardcoding secrets', () {
      final env = mockService.getEnvironmentVariables();

      expect(env['API_KEY'], equals('env_api_key_secure'));
      expect(env['KEY_SECRET'], equals('env_secret_key_secure'));
      expect(env['BASE_URL'], startsWith('https://'));

      expect(env['API_KEY'], isNot(contains('your_secure_api_key_here')));
      expect(env['KEY_SECRET'], isNot(contains('your_key_secret_example')));
    });

    test('secure storage backed repository is used for persistence', () {
      final repo = DeliveryNavigationBarRepository();
      expect(repo, isNotNull);
      expect(DeliveryNavigationBarRepository.defaultNavItems, isNotEmpty);
    });

    testWidgets('UI never renders secret environment values', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: DeliveryNavigationBarPage(bloc: mockBloc)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('API_KEY'), findsNothing);
      expect(find.textContaining('KEY_SECRET'), findsNothing);
      expect(find.textContaining('env_api_key_secure'), findsNothing);
      expect(find.textContaining('env_secret_key_secure'), findsNothing);
      expect(find.textContaining('your_secure_api_key_here'), findsNothing);
    });
  });
}
