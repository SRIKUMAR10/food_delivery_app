import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import '../mock_firebase.dart';

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
  });

  testWidgets('Accessibility test for Seller Sign Up', (
    WidgetTester tester,
  ) async {
    await Firebase.initializeApp();
    await tester.pumpWidget(const MaterialApp(home: SellerSignUpPageUI()));

    // Check for semantics
    expect(tester.getSemantics(find.byType(SellerSignUpPageUI)), isNotNull);
  });
}
