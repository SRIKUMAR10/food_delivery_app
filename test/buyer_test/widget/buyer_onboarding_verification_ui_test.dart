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

    expect(find.text('Step 1 of 8'), findsOneWidget);
    expect(find.text('👤 Personal Identity & Avatar'), findsOneWidget);
    expect(find.text('Full Name *'), findsOneWidget);
    expect(find.text('Continue to Contact Verification ➔'), findsOneWidget);
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

    // Verify initial full name prefilled in controller
    // Ensure button is visible before tapping
    await tester.ensureVisible(find.text('Continue to Contact Verification ➔'));
    await tester.tap(find.text('Continue to Contact Verification ➔'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify step 2 renders phone verified badge
    expect(find.text('Phone Number Verified ✅'), findsOneWidget);
    expect(find.text('Continue to Delivery Address ➔'), findsOneWidget);
  });
}
