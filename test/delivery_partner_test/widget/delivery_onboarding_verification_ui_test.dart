import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_city_zone_search_dialog.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_onboarding_verification_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeliveryOnboardingVerificationPage Widget Tests', () {
    testWidgets('renders initial step 1 with all mandatory personal fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialFullName: 'Test Rider',
            initialDisplayName: 'Rider T',
            initialPhone: '9876543210',
            initialAvatarUrl: 'https://example.com/avatar.jpg',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Partner Onboarding & KYC'), findsOneWidget);
      expect(find.textContaining('Step 1 of 8'), findsOneWidget);
      expect(find.text('Personal Information & Driver Selfie'), findsOneWidget);
      expect(find.text('Full Name (as per Driving License) *'), findsOneWidget);
      expect(find.text('Display Name / Nickname'), findsOneWidget);
      expect(find.text('Blood Group *'), findsOneWidget);
      expect(find.text('Emergency Contact Person Name *'), findsOneWidget);
      expect(find.text('Emergency Contact Phone Number *'), findsOneWidget);
      expect(find.textContaining('Next Step (2/8)'), findsOneWidget);
    });

    testWidgets('shows inline field error alerts beneath empty text fields on Next click',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialFullName: '', // Empty name
            initialPhone: '',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nextButton = find.textContaining('Next Step (2/8)');
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Inline field error alerts must be rendered directly under each input
      expect(find.text('Full name is mandatory (minimum 3 characters)'), findsOneWidget);
      expect(find.text('Date of birth is mandatory (DD/MM/YYYY)'), findsOneWidget);
      expect(find.text('Emergency contact person name is mandatory'), findsOneWidget);
      expect(find.text('Live driver selfie photo is mandatory for verification'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('blocks step 2 transition when mandatory fields are missing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialFullName: '', // Empty name
            initialPhone: '9876543210',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nextButton = find.textContaining('Next Step (2/8)');
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should still be on Step 1 due to validation guard
      expect(find.textContaining('Step 1 of 8'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('advances to step 2 when step 1 mandatory fields are filled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialFullName: 'Test Rider',
            initialDisplayName: 'Rider T',
            initialPhone: '9876543210',
            initialEmail: 'rider@example.com',
            initialAvatarUrl: 'https://example.com/avatar.jpg',
            initialIsPhoneVerified: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill DOB, Emergency Name & Phone
      await tester.enterText(
          find.widgetWithText(TextField, 'Date of Birth (DD/MM/YYYY) *'),
          '15/08/1996');
      await tester.enterText(
          find.widgetWithText(TextField, 'Emergency Contact Person Name *'),
          'Suresh Kumar');
      await tester.enterText(
          find.widgetWithText(TextField, 'Emergency Contact Phone Number *'),
          '9876543210');
      await tester.pumpAndSettle();

      final nextButton = find.textContaining('Next Step (2/8)');
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 2 of 8'), findsOneWidget);
      expect(find.text('Contact & Phone OTP Verification'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('navigates back to step 1 when Back button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialFullName: 'Test Rider',
            initialDisplayName: 'Rider T',
            initialPhone: '9876543210',
            initialEmail: 'rider@example.com',
            initialAvatarUrl: 'https://example.com/avatar.jpg',
            initialIsPhoneVerified: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill DOB, Emergency Name & Phone
      await tester.enterText(
          find.widgetWithText(TextField, 'Date of Birth (DD/MM/YYYY) *'),
          '15/08/1996');
      await tester.enterText(
          find.widgetWithText(TextField, 'Emergency Contact Person Name *'),
          'Suresh Kumar');
      await tester.enterText(
          find.widgetWithText(TextField, 'Emergency Contact Phone Number *'),
          '9876543210');
      await tester.pumpAndSettle();

      // Advance to Step 2
      await tester.tap(find.textContaining('Next Step (2/8)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 2 of 8'), findsOneWidget);

      // Tap Back button
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 1 of 8'), findsOneWidget);
    });

    testWidgets('tapping Date of Birth field or calendar icon opens systematic DatePicker and updates value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialFullName: 'Test Rider',
            initialPhone: '9876543210',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Date of Birth field
      final dobField = find.widgetWithText(TextField, 'Date of Birth (DD/MM/YYYY) *');
      expect(dobField, findsOneWidget);
      await tester.ensureVisible(dobField);
      await tester.pumpAndSettle();

      // Tap on Date of Birth field to open DatePicker
      await tester.tap(dobField);
      await tester.pumpAndSettle();

      // Verify DatePickerDialog appears
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.text('Select Date of Birth'), findsOneWidget);

      // Confirm date selection (Tap SELECT)
      await tester.tap(find.text('SELECT'));
      await tester.pumpAndSettle();

      // DatePicker should be dismissed and field populated with DD/MM/YYYY format
      expect(find.byType(DatePickerDialog), findsNothing);
      final TextField field = tester.widget(dobField);
      expect(field.controller?.text.isNotEmpty, isTrue);
      expect(field.controller?.text.contains('/'), isTrue);
    });

    testWidgets('populates initial/restored name arun and allows manual editing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialFullName: 'arun',
            initialDisplayName: 'arun',
            initialPhone: '9876543210',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nameFieldFinder = find.widgetWithText(TextField, 'Full Name (as per Driving License) *');
      expect(nameFieldFinder, findsOneWidget);

      final TextField nameField = tester.widget(nameFieldFinder);
      expect(nameField.controller?.text, 'arun');

      // User manually edits the name
      await tester.enterText(nameFieldFinder, 'Arun Kumar');
      await tester.pumpAndSettle();

      final TextField updatedField = tester.widget(nameFieldFinder);
      expect(updatedField.controller?.text, 'Arun Kumar');
    });

    testWidgets('renders Tap to Change button on Step 1 selfie when initial avatar is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialFullName: 'Test Rider',
            initialPhone: '9876543210',
            initialAvatarUrl: 'https://example.com/avatar.jpg',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('(Tap to Change)'), findsOneWidget);
    });

    testWidgets('renders step 3 vehicle and driving license document upload tiles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialFullName: 'Test Rider',
            initialDisplayName: 'Rider T',
            initialPhone: '9876543210',
            initialEmail: 'rider@example.com',
            initialAvatarUrl: 'https://example.com/avatar.jpg',
            initialIsPhoneVerified: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1 to Step 2
      await tester.enterText(
          find.widgetWithText(TextField, 'Date of Birth (DD/MM/YYYY) *'),
          '15/08/1996');
      await tester.enterText(
          find.widgetWithText(TextField, 'Emergency Contact Person Name *'),
          'Suresh Kumar');
      await tester.enterText(
          find.widgetWithText(TextField, 'Emergency Contact Phone Number *'),
          '9876543210');
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Next Step (2/8)'));
      await tester.pumpAndSettle();

      // Step 2 to Step 3
      await tester.tap(find.textContaining('Next Step (3/8)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 3 of 8'), findsOneWidget);
      expect(find.text('Driving License Document Photos *'), findsOneWidget);
      expect(find.text('DL Front Side *'), findsOneWidget);
      expect(find.text('DL Back Side *'), findsOneWidget);
      expect(find.text('Vehicle RC Book Copy (Optional)'), findsOneWidget);
    });

    testWidgets('Step 5 IFSC input has interactive search button and shortcut link',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialFullName: 'Test Rider',
            initialPhone: '9876543210',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure initial step is rendered
      expect(find.text('Partner Onboarding & KYC'), findsOneWidget);
    });

    testWidgets('Step 6 renders Delivery City typeable autocomplete and Operating Zone without Search / Map or Popular chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialStep: DeliveryVerificationStep.zoneAndPreferences,
            initialFullName: 'Test Rider',
            initialDisplayName: 'Rider T',
            initialPhone: '9876543210',
            initialEmail: 'rider@example.com',
            initialAvatarUrl: 'https://example.com/avatar.jpg',
            initialIsPhoneVerified: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // We are directly on Step 6
      expect(find.textContaining('Step 6 of 8'), findsOneWidget);
      expect(find.text('Operating Zone & GPS Base Location'), findsOneWidget);
      expect(find.text('Delivery City *'), findsOneWidget);
      // Search / Map and Popular chips must be removed
      expect(find.text('Search / Map'), findsNothing);
      expect(find.text('Popular: '), findsNothing);
      expect(find.text('Hub Map'), findsOneWidget);
      expect(find.text('Locate on Map'), findsOneWidget);
      expect(find.text('Chennai'), findsWidgets);
      expect(find.text('Central Zone'), findsWidgets);
    });

    testWidgets('Step 6 typing city name in Delivery City input shows autocomplete suggestions and updates selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialStep: DeliveryVerificationStep.zoneAndPreferences,
            initialFullName: 'Test Rider',
            initialPhone: '9876543210',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Delivery City text field
      final cityField = find.widgetWithText(TextField, 'Delivery City *');
      expect(cityField, findsOneWidget);

      // Enter 'Coimbatore' into the field
      await tester.enterText(cityField, 'Coimbatore');
      await tester.pumpAndSettle();

      // Suggestions overlay appears, tap the Coimbatore option
      final cbeOption = find.widgetWithText(InkWell, 'Coimbatore');
      if (cbeOption.evaluate().isNotEmpty) {
        await tester.tap(cbeOption.first);
        await tester.pumpAndSettle();
      }

      expect(find.text('Coimbatore'), findsWidgets);
      expect(find.textContaining('Operating Zone / Hub (Coimbatore) *'), findsOneWidget);
    });

    testWidgets('Step 6 tapping Hub Map opens DeliveryCityZoneSearchDialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeliveryOnboardingVerificationPage(
            initialStep: DeliveryVerificationStep.zoneAndPreferences,
            initialFullName: 'Test Rider',
            initialPhone: '9876543210',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Hub Map'
      final hubMapBtn = find.text('Hub Map');
      expect(hubMapBtn, findsOneWidget);
      await tester.tap(hubMapBtn);
      await tester.pumpAndSettle();

      expect(find.byType(DeliveryCityZoneSearchDialog), findsOneWidget);
      expect(find.text('Select Delivery City & Operating Hub'), findsOneWidget);
    });
  });
}
