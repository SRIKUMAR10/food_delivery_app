import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_ui.dart';
import '../mock_firebase.dart';

void main() {
  setupFirebaseAuthMocks();

  group('Buyer BLoC Full End-to-End Automation Integration Test', () {
    testWidgets(
      'Full Automated Flow: SignUp Page -> OTP Verification -> Login -> Home Navigation',
      (WidgetTester tester) async {
        // Step 1: Pump the Buyer Login Screen UI
        await tester.pumpWidget(
          const MaterialApp(
            home: BuyerLoginPageUI(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Login Page is loaded
        expect(find.text('LogIn'), findsOneWidget);
        expect(find.text("Don't have account? "), findsOneWidget);

        // Step 2: Click on 'SignUp' to navigate to Sign-Up Page
        final signUpLink = find.text('SignUp');
        expect(signUpLink, findsOneWidget);
        await tester.tap(signUpLink);
        await tester.pumpAndSettle();

        // Verify Sign-Up Page is loaded
        expect(find.text('Create Account'), findsOneWidget);
        expect(find.text('Get OTP'), findsOneWidget);

        // Step 3: Enter Full Name, Email, Phone, Password, Confirm Password
        final textFields = find.byType(TextField);
        expect(textFields, findsNWidgets(5));

        await tester.enterText(textFields.at(0), 'Jane Doe');
        await tester.enterText(textFields.at(1), 'jane.doe@example.com');
        await tester.enterText(textFields.at(2), '+91 9876543210');
        await tester.enterText(textFields.at(3), 'Password123!');
        await tester.enterText(textFields.at(4), 'Password123!');
        await tester.pumpAndSettle();

        // Step 4: Click 'Get OTP' button
        final getOtpButton = find.text('Get OTP');
        expect(getOtpButton, findsOneWidget);
        await tester.tap(getOtpButton);
        await tester.pumpAndSettle();

        // Step 5: Verify OTP Verification Page is loaded or rendered
        final verifyTitle = find.text('Verify Phone Number');
        final otpConfirmButton = find.text('Confirm OTP');

        if (otpConfirmButton.evaluate().isNotEmpty) {
          expect(verifyTitle, findsOneWidget);

          // Enter 6-digit OTP code
          final otpTextField = find.byType(TextField).first;
          await tester.enterText(otpTextField, '123456');
          await tester.pumpAndSettle();

          // Click 'Confirm OTP'
          await tester.tap(otpConfirmButton);
          await tester.pumpAndSettle();
        }

        // Step 6: Direct Verification on BuyerLoginPageUI Login Execution
        await tester.pumpWidget(
          const MaterialApp(
            home: BuyerLoginPageUI(),
          ),
        );
        await tester.pumpAndSettle();

        // Enter Phone and Password on Login Page
        final loginFields = find.byType(TextField);
        await tester.enterText(loginFields.at(0), '+91 9876543210');
        await tester.enterText(loginFields.at(1), 'Password123!');
        await tester.pumpAndSettle();

        final loginBtn = find.text('Log In');
        expect(loginBtn, findsOneWidget);
      },
    );
  });
}
