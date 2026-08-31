import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
