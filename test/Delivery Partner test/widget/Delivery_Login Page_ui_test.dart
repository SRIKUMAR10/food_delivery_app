import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryLoginPageBloc
    extends MockBloc<DeliveryLoginPageEvent, DeliveryLoginPageState>
    implements DeliveryLoginPageBloc {}

void main() {
  late MockDeliveryLoginPageBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );

    registerFallbackValue(const DeliveryLoginInitEvent());
    registerFallbackValue(const DeliveryLoginPhoneChangedEvent(''));
    registerFallbackValue(const DeliveryLoginPasswordChangedEvent(''));
    registerFallbackValue(const DeliveryLoginToggleRememberMeEvent());
  });

  setUp(() {
    mockBloc = MockDeliveryLoginPageBloc();
    when(() => mockBloc.state).thenReturn(
      const DeliveryLoginPageState(status: DeliveryLoginStatus.initial),
    );
  });

  Widget buildWidget() {
    return MaterialApp(home: DeliveryLoginPage(bloc: mockBloc));
  }

  group('DeliveryLoginPage Widget Tests', () {
    testWidgets('renders all essential UI elements properly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(
        find.text('Login to continue your delivery journey'),
        findsOneWidget,
      );
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Remember Me'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('allows entering phone number and password', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final phoneFinder = find.byType(TextField).at(0);
      final passwordFinder = find.byType(TextField).at(1);

      await tester.enterText(phoneFinder, '9876543210');
      await tester.enterText(passwordFinder, 'mySecretPass');
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockBloc.add(const DeliveryLoginPhoneChangedEvent('9876543210')),
      ).called(1);
      verify(
        () => mockBloc.add(
          const DeliveryLoginPasswordChangedEvent('mySecretPass'),
        ),
      ).called(1);
    });

    testWidgets('toggles remember me checkbox when tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final checkboxFinder = find.byType(Checkbox);
      await tester.tap(checkboxFinder, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));

      verify(
        () => mockBloc.add(const DeliveryLoginToggleRememberMeEvent()),
      ).called(1);
    });
  });
}
