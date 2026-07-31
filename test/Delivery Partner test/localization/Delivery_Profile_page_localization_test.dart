import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryProfileBloc
    extends MockBloc<DeliveryProfileEvent, DeliveryProfileState>
    implements DeliveryProfileBloc {}

void main() {
  late MockDeliveryProfileBloc mockBloc;

  const DeliveryProfileState enState = DeliveryProfileState(
    status: DeliveryProfileStatus.loaded,
    completionPercentage: 75,
    verificationStatuses: DeliveryProfileRepository.defaultVerificationStatuses,
    documents: DeliveryProfileRepository.defaultDocuments,
  );

  const DeliveryProfileState taState = DeliveryProfileState(
    status: DeliveryProfileStatus.loaded,
    completionPercentage: 75,
    localeCode: 'ta',
    verificationStatuses: DeliveryProfileRepository.defaultVerificationStatuses,
    documents: DeliveryProfileRepository.defaultDocuments,
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
    mockBloc = MockDeliveryProfileBloc();
    when(() => mockBloc.state).thenReturn(enState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryProfilePage Localization Tests', () {
    testWidgets('renders English UI text by default', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryProfilePage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Save & Continue'), findsOneWidget);
      expect(find.text('Profile Completion'), findsOneWidget);
      expect(find.text('Verification Status'), findsOneWidget);
      expect(find.text('Upload Documents'), findsOneWidget);
    });

    testWidgets('renders Tamil UI text when locale is Tamil', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(taState);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryProfilePage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('என் சுயவிவரம்'), findsOneWidget);
      expect(find.text('சேமித்து தொடரவும்'), findsOneWidget);
      expect(find.text('சுயவிவர முழுமை'), findsOneWidget);
      expect(find.text('சரிபார்ப்பு நிலை'), findsOneWidget);
    });

    testWidgets('translates document labels in Tamil', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(taState);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryProfilePage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.text('ஓட்டுநர் உரிமம்'), findsOneWidget);
      expect(find.text('வாகன RC'), findsOneWidget);
      expect(find.text('காப்பீடு'), findsOneWidget);
    });

    test('string lookup falls back to English for unknown locales', () {
      expect(DeliveryProfileStrings.of('title', 'fr'), 'My Profile');
      expect(
        DeliveryProfileStrings.of('saveContinue', 'hi'),
        'Save & Continue',
      );
    });
  });
}
