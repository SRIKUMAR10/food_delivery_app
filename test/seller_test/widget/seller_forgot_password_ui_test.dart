import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_forgot_password/seller_forgot_password_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
  });

  testWidgets('Seller ForgotPassword UI renders correctly', (WidgetTester tester) async {
    await Firebase.initializeApp();
    await tester.pumpWidget(
      const MaterialApp(
        home: SellerForgotPasswordPageUI(),
      ),
    );

    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });
}
