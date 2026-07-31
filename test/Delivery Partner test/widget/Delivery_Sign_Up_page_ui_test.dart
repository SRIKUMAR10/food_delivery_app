import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliverySignUpPageBloc
    extends MockBloc<DeliverySignUpPageEvent, DeliverySignUpPageState>
    implements DeliverySignUpPageBloc {}

void main() {
  late MockDeliverySignUpPageBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );

    registerFallbackValue(const DeliverySignUpInitEvent());
    registerFallbackValue(const DeliverySignUpNameChanged(''));
    registerFallbackValue(const DeliverySignUpPhoneChanged(''));
  });

  setUp(() {
    mockBloc = MockDeliverySignUpPageBloc();
    when(() => mockBloc.state).thenReturn(
      const DeliverySignUpPageState(status: DeliverySignUpStatus.initial),
    );
  });

  Widget buildWidget() {
    return MaterialApp(home: DeliverySignUpPage(bloc: mockBloc));
  }

  group('DeliverySignUpPage Widget Tests', () {
    testWidgets('renders all essential UI elements properly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Join as Partner'), findsOneWidget);
      expect(find.text('Create your delivery partner account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('aligns card to right side on desktop viewport', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final alignFinder = find.byType(Align);
      expect(alignFinder, findsWidgets);

      final alignWidget = tester.widget<Align>(alignFinder.first);
      expect(alignWidget.alignment, Alignment.centerRight);
    });
  });
}
