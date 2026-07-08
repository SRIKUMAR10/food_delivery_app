import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_forgot_password/seller_forgot_password_ui.dart';

void main() {
  testWidgets('Seller ForgotPassword UI renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SellerForgotPasswordPageUI(),
      ),
    );

    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });
}
