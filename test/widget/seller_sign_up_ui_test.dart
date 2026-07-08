import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up/seller_sign_up_ui.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  testWidgets('Seller SignUp UI renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: const SellerSignUpPageUI())),
    );

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });
}
