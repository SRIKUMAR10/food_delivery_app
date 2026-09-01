import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BuyerOnboardingVerificationPage renders initial step correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerOnboardingVerificationPage(),
      ),
    );

    await tester.pump();

    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(find.text('👤 Personal Identity & Avatar'), findsOneWidget);
    expect(find.text('Full Name *'), findsOneWidget);
    expect(find.text('Continue to Contact Verification ➔'), findsOneWidget);
  });

  testWidgets('Tapping profile avatar opens photo options bottom sheet',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerOnboardingVerificationPage(),
      ),
    );
    await tester.pump();

    // Tap the camera icon on the avatar
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();

    // Verify ModalBottomSheet opened
    expect(find.text('Profile Photo'), findsOneWidget);
    expect(find.text('Choose from Gallery / Files'), findsOneWidget);
  });

  testWidgets('BuyerOnboardingVerificationPage pre-populates name and verified badge',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerOnboardingVerificationPage(
          initialFullName: 'Deepak Kumar',
          initialEmail: 'deepak@example.com',
          initialPhone: '+919876543210',
          initialIsPhoneVerified: true,
        ),
      ),
    );

    await tester.pump();

    await tester.ensureVisible(find.text('Continue to Contact Verification ➔'));
    await tester.tap(find.text('Continue to Contact Verification ➔'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Phone Number Verified ✅'), findsOneWidget);
    expect(find.text('Continue to Delivery Address ➔'), findsOneWidget);
  });

  testWidgets('Step 3 ChoiceChips (Home, Work, Other) toggle without leaving step and Save transitions to Step 4',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerOnboardingVerificationPage(
          initialFullName: 'Deepak Kumar',
          initialEmail: 'deepak@example.com',
          initialPhone: '+919876543210',
          initialIsPhoneVerified: true,
        ),
      ),
    );
    await tester.pump();

    // Go to Step 2
    await tester.ensureVisible(find.text('Continue to Contact Verification ➔'));
    await tester.tap(find.text('Continue to Contact Verification ➔'));
    await tester.pumpAndSettle();

    // Go to Step 3
    await tester.ensureVisible(find.text('Continue to Delivery Address ➔'));
    await tester.tap(find.text('Continue to Delivery Address ➔'));
    await tester.pumpAndSettle();

    // Verify on Step 3
    expect(find.text('📍 Primary Delivery Address'), findsOneWidget);
    expect(find.text('Use My Current GPS Location'), findsOneWidget);
    expect(find.text('Save Address As:'), findsOneWidget);

    // Tap 'Work' ChoiceChip
    await tester.ensureVisible(find.text('Work'));
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    // MUST STILL BE ON STEP 3!
    expect(find.text('📍 Primary Delivery Address'), findsOneWidget);
    expect(find.text('Step 3 of 6'), findsOneWidget);

    // Enter address in TextField
    await tester.enterText(
      find.byType(TextField).first,
      '123, Anna Salai, Chennai, 600002',
    );
    await tester.pumpAndSettle();

    // Tap 'Save Address & Continue ➔'
    await tester.ensureVisible(find.text('Save Address & Continue ➔'));
    await tester.tap(find.text('Save Address & Continue ➔'));
    await tester.pumpAndSettle();

    // Now transitioned to Step 4 (Payment Setup)
    expect(find.text('💳 Payment Preference & In-App Wallet'), findsOneWidget);
    expect(find.text('Step 4 of 6'), findsOneWidget);
  });

  testWidgets('Step 1 shows validation error snackbar when full name is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerOnboardingVerificationPage(),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Continue to Contact Verification ➔'));
    await tester.tap(find.text('Continue to Contact Verification ➔'));
    await tester.pumpAndSettle();

    // Verify error SnackBar is shown
    expect(find.text('Please enter your full name.'), findsOneWidget);
    expect(find.text('Step 1 of 6'), findsOneWidget);
  });

  testWidgets('Step 4 payment method and wallet switch toggle in-place, and advances to Step 5',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerOnboardingVerificationPage(
          initialFullName: 'Deepak Kumar',
          initialEmail: 'deepak@example.com',
          initialPhone: '+919876543210',
          initialIsPhoneVerified: true,
        ),
      ),
    );
    await tester.pump();

    // Step 1 -> Step 2
    await tester.ensureVisible(find.text('Continue to Contact Verification ➔'));
    await tester.tap(find.text('Continue to Contact Verification ➔'));
    await tester.pumpAndSettle();

    // Step 2 -> Step 3
    await tester.ensureVisible(find.text('Continue to Delivery Address ➔'));
    await tester.tap(find.text('Continue to Delivery Address ➔'));
    await tester.pumpAndSettle();

    // Enter address & Step 3 -> Step 4
    await tester.enterText(
      find.byType(TextField).first,
      '123, Anna Salai, Chennai, 600002',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Address & Continue ➔'));
    await tester.tap(find.text('Save Address & Continue ➔'));
    await tester.pumpAndSettle();

    // On Step 4
    expect(find.text('💳 Payment Preference & In-App Wallet'), findsOneWidget);

    // Toggle Cash on Delivery
    await tester.ensureVisible(find.text('Cash on Delivery (COD)'));
    await tester.tap(find.text('Cash on Delivery (COD)'));
    await tester.pumpAndSettle();

    // Still on Step 4
    expect(find.text('Step 4 of 6'), findsOneWidget);

    // Tap Continue to Permissions
    await tester.ensureVisible(find.text('Continue to Permissions ➔'));
    await tester.tap(find.text('Continue to Permissions ➔'));
    await tester.pumpAndSettle();

    // Transitioned to Step 5
    expect(find.text('🔔 App Permissions & Notifications'), findsOneWidget);
    expect(find.text('Step 5 of 6'), findsOneWidget);

    // Verify all 3 switches are ON (true) by default
    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.length, greaterThanOrEqualTo(3));
    for (final sw in switches) {
      expect(sw.value, isTrue);
    }

    // Tap Review & Activate Account ➔ to transition to Step 6
    await tester.ensureVisible(find.text('Review & Activate Account ➔'));
    await tester.tap(find.text('Review & Activate Account ➔'));
    await tester.pumpAndSettle();

    // Transitioned to Step 6
    expect(find.text('Step 6 of 6'), findsOneWidget);
    expect(find.text('🎉 Verification & Setup Complete!'), findsOneWidget);
    expect(find.text('WELCOME REWARD UNLOCKED'), findsOneWidget);
  });

  testWidgets('Step 3 retains address, flat no, and landmark values when navigating back from Step 4',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerOnboardingVerificationPage(
          initialFullName: 'Anand Kumar',
          initialEmail: 'anand@example.com',
          initialPhone: '+919876543210',
          initialIsPhoneVerified: true,
        ),
      ),
    );
    await tester.pump();

    // Step 1 -> Step 2
    await tester.ensureVisible(find.text('Continue to Contact Verification ➔'));
    await tester.tap(find.text('Continue to Contact Verification ➔'));
    await tester.pumpAndSettle();

    // Step 2 -> Step 3
    await tester.ensureVisible(find.text('Continue to Delivery Address ➔'));
    await tester.tap(find.text('Continue to Delivery Address ➔'));
    await tester.pumpAndSettle();

    // Fill Step 3 fields
    final textFields = find.byType(TextField);
    // 1st: Address, 2nd: Flat, 3rd: Landmark
    await tester.enterText(textFields.at(0), '77 MG Road, Bengaluru');
    await tester.enterText(textFields.at(1), 'Flat 502');
    await tester.enterText(textFields.at(2), 'Near Metro Gate 2');
    await tester.pumpAndSettle();

    // Save and continue to Step 4
    await tester.ensureVisible(find.text('Save Address & Continue ➔'));
    await tester.tap(find.text('Save Address & Continue ➔'));
    await tester.pumpAndSettle();

    expect(find.text('Step 4 of 6'), findsOneWidget);

    // Tap back button to return to Step 3
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    // Verify on Step 3 and values are preserved
    expect(find.text('Step 3 of 6'), findsOneWidget);
    expect(find.text('77 MG Road, Bengaluru'), findsOneWidget);
    expect(find.text('Flat 502'), findsOneWidget);
    expect(find.text('Near Metro Gate 2'), findsOneWidget);
  });

  testWidgets('populates initial/restored name arun and allows manual editing',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerOnboardingVerificationPage(
          initialFullName: 'arun',
          initialEmail: 'arun@example.com',
          initialPhone: '+919876543210',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('arun'), findsWidgets);

    final nameField = find.byType(TextField).first;
    await tester.enterText(nameField, 'arun kumar');
    await tester.pumpAndSettle();

    expect(find.text('arun kumar'), findsOneWidget);
  });
}
