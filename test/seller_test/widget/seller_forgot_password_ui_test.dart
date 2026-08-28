import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_forgot_password/seller_forgot_password_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
  });

  testWidgets('Seller ForgotPassword UI renders correctly with phone and OTP fields', (WidgetTester tester) async {
    await Firebase.initializeApp();
    await tester.pumpWidget(
      const MaterialApp(
        home: SellerForgotPasswordPageUI(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reset Password'), findsWidgets);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('Get OTP'), findsOneWidget);
    expect(find.text('OTP Code'), findsOneWidget);
    expect(find.text('Create Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
  });
}
