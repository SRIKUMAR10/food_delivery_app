import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_forgot_password/seller_forgot_password_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_auth_shared/seller_auth_shared_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('Seller ForgotPassword UI Tests', () {
    testWidgets('Seller ForgotPassword UI renders correctly with all fields & buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SellerForgotPasswordPageUI(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsWidgets);
      expect(find.text('Verify mobile number & create new password'), findsOneWidget);
      expect(find.text('Reset Your Password'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Get OTP'), findsOneWidget);
      expect(find.text('OTP Code'), findsOneWidget);
      expect(find.text('Create Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.byType(SellerPrimaryButton), findsOneWidget);
    });

    testWidgets('User can enter mobile number, OTP, and passwords in the UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SellerForgotPasswordPageUI(),
        ),
      );
      await tester.pumpAndSettle();

      // Find fields
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), '9876543210');
      await tester.enterText(textFields.at(1), '123456');
      await tester.enterText(textFields.at(2), 'Password123!');
      await tester.enterText(textFields.at(3), 'Password123!');
      await tester.pumpAndSettle();

      expect(find.text('9876543210'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
      expect(find.text('Password123!'), findsNWidgets(2));
    });

    testWidgets('Password visibility toggle updates input obscure state', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SellerForgotPasswordPageUI(),
        ),
      );
      await tester.pumpAndSettle();

      final toggleIcons = find.byIcon(Icons.visibility_off_outlined);
      expect(toggleIcons, findsNWidgets(2));

      await tester.ensureVisible(toggleIcons.first);
      await tester.tap(toggleIcons.first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}

