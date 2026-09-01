import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_verification_page/delivery_documents_page.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_state.dart';

import '../../font_loader_helper.dart';

class MockDeliveryOnboardingVerificationBloc extends MockBloc<
        DeliveryOnboardingVerificationEvent,
        DeliveryOnboardingVerificationState>
    implements DeliveryOnboardingVerificationBloc {}

void main() {
  late MockDeliveryOnboardingVerificationBloc mockBloc;

  final completedState = DeliveryOnboardingVerificationState(
    currentStep: DeliveryVerificationStep.personalDetails,
    status: DeliveryVerificationStatus.initial,
    fullName: 'John Rider',
    displayName: 'John',
    dob: '01/01/1995',
    gender: 'Male',
    bloodGroup: 'O+',
    emergencyContactName: 'Jane Rider',
    emergencyContactPhone: '9876543210',
    avatarUrl: 'https://example.com/avatar.jpg',
    phone: '9876543210',
    email: 'rider@foodgo.com',
    isPhoneVerified: true,
    vehicleType: 'Motorcycle',
    vehicleNumber: 'TN01AB1234',
    vehicleModel: 'Honda Activa',
    drivingLicenseNumber: 'DL1234567890',
    dlExpiryDate: '01/01/2030',
    dlFrontUrl: 'https://example.com/dl_front.jpg',
    dlBackUrl: 'https://example.com/dl_back.jpg',
    rcBookUrl: 'https://example.com/rc.jpg',
    aadhaarNumber: '123456789012',
    panNumber: 'ABCDE1234F',
    aadhaarFrontUrl: 'https://example.com/aadhaar_front.jpg',
    aadhaarBackUrl: 'https://example.com/aadhaar_back.jpg',
    panCardUrl: 'https://example.com/pan.jpg',
    bankAccountNumber: '123456789012',
    confirmAccountNumber: '123456789012',
    ifscCode: 'HDFC0001234',
    bankName: 'HDFC Bank',
    accountHolderName: 'John Rider',
    upiId: 'john@okhdfcbank',
    payoutFrequency: 'Daily',
    city: 'Chennai',
    operatingZone: 'Central',
    formattedAddress: '123 Anna Salai, Chennai',
    houseFlatNo: 'Flat 4B',
    locationPermissionGranted: true,
    cameraPermissionGranted: true,
    backgroundLocationGranted: true,
    pushNotificationsGranted: true,
    hasDeliveryBag: true,
    hasHelmet: true,
    acknowledgedCodeOfConduct: true,
  );

  final emptyState = const DeliveryOnboardingVerificationState(
    currentStep: DeliveryVerificationStep.personalDetails,
    status: DeliveryVerificationStatus.initial,
    fullName: '',
    dob: '',
    emergencyContactName: '',
    emergencyContactPhone: '',
    phone: '',
    email: '',
    isPhoneVerified: false,
    vehicleNumber: '',
    drivingLicenseNumber: '',
    dlExpiryDate: '',
    aadhaarNumber: '',
    panNumber: '',
    bankAccountNumber: '',
    confirmAccountNumber: '',
    ifscCode: '',
    accountHolderName: '',
    upiId: '',
    city: '',
    operatingZone: '',
    formattedAddress: '',
    houseFlatNo: '',
    locationPermissionGranted: false,
    cameraPermissionGranted: false,
    hasDeliveryBag: false,
    hasHelmet: false,
    acknowledgedCodeOfConduct: false,
  );

  setUpAll(() {
    overrideFontAssetLoading();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
  });

  setUp(() {
    mockBloc = MockDeliveryOnboardingVerificationBloc();
  });

  Widget buildTestWidget({
    required DeliveryOnboardingVerificationState state,
    String localeCode = 'en',
  }) {
    when(() => mockBloc.state).thenReturn(state);
    return MaterialApp(
      home: DeliveryDocumentsPage(
        bloc: mockBloc,
        localeCode: localeCode,
      ),
    );
  }

  group('DeliveryDocumentsPage Widget Tests', () {
    testWidgets('renders header, overview card and all 8 document step cards',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget(state: completedState));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Documents & Verification'), findsOneWidget);
      expect(
        find.text(
          'Manage your 8-step KYC documents, vehicle licenses, and profile verifications.',
        ),
        findsOneWidget,
      );

      // Section title
      expect(find.text('8 Verification Steps & Documents'), findsOneWidget);

      // 8 Step Cards
      for (int i = 1; i <= 8; i++) {
        expect(
          find.byKey(Key('dp_doc_card_step_$i')),
          findsOneWidget,
          reason: 'Step $i card must be rendered',
        );
      }

      // Step Titles
      expect(find.text('Personal Details & Live Photo'), findsOneWidget);
      expect(find.text('Contact & Phone Verification'), findsOneWidget);
      expect(find.text('Vehicle & Driving License'), findsOneWidget);
      expect(find.text('Government KYC Documents'), findsOneWidget);
      expect(find.text('Bank Account & Payouts'), findsOneWidget);
      expect(find.text('Operating Zone & Preferences'), findsOneWidget);
      expect(find.text('Hardware & Device Permissions'), findsOneWidget);
      expect(find.text('Safety Kit & Activation'), findsOneWidget);

      // Security banner
      expect(find.text('Bank-Grade 256-bit Data Encryption'), findsOneWidget);
    });

    testWidgets('displays 8 of 8 completed progress and verified badges when completed',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget(state: completedState));
      await tester.pumpAndSettle();

      expect(find.text('8 of 8 Steps Completed'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('All Documents Verified'), findsOneWidget);
      expect(find.text('Verified'), findsWidgets);
    });

    testWidgets('displays incomplete badges when state is empty',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget(state: emptyState));
      await tester.pumpAndSettle();

      expect(find.text('0 of 8 Steps Completed'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('Verification Incomplete'), findsOneWidget);
      expect(find.text('Incomplete'), findsWidgets);
    });

    testWidgets('renders Tamil localized text properly', (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestWidget(state: completedState, localeCode: 'ta'),
      );
      await tester.pumpAndSettle();

      expect(find.text('ஆவணங்கள் மற்றும் சரிபார்ப்பு'), findsOneWidget);
      expect(find.text('அனைத்து ஆவணங்களும் சரிபார்க்கப்பட்டன'), findsOneWidget);
      expect(find.text('8-ல் 8 படிகள் நிறைவடைந்துள்ளன'), findsOneWidget);
      expect(find.text('சரிபார்க்கப்பட்டது'), findsWidgets);
    });

    testWidgets('tapping a step card opens onboarding verification page',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget(state: completedState));
      await tester.pumpAndSettle();

      final step3Card = find.byKey(const Key('dp_doc_card_step_3'));
      expect(step3Card, findsOneWidget);

      await tester.tap(step3Card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Partner Onboarding & KYC'), findsOneWidget);
      expect(find.text('Step 3 of 8 — Vehicle & Driving License'), findsOneWidget);
    });

    testWidgets('responsive layout renders correctly on mobile viewport',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget(state: completedState));
      await tester.pumpAndSettle();

      expect(find.text('Documents & Verification'), findsOneWidget);
      expect(find.byKey(const Key('dp_doc_card_step_1')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders multi-document preview chips for vehicle and kyc documents',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget(state: completedState));
      await tester.pumpAndSettle();

      // Step 3 Document Chips
      expect(find.text('DL Front'), findsOneWidget);
      expect(find.text('DL Back'), findsOneWidget);
      expect(find.text('RC Book'), findsOneWidget);

      // Step 4 Document Chips
      expect(find.text('Aadhaar Front'), findsOneWidget);
      expect(find.text('Aadhaar Back'), findsOneWidget);
      expect(find.text('PAN Card'), findsOneWidget);
    });
  });
}
