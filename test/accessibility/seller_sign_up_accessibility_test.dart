import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_ui.dart';

void main() {
  testWidgets('Accessibility test for Seller Sign Up', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SellerSignUpPageUI()));

    // Check for semantics
    expect(tester.getSemantics(find.byType(SellerSignUpPageUI)), isNotNull);
  });
}
