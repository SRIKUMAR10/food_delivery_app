import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
  });

  testWidgets('Seller SignUp UI renders correctly', (
    WidgetTester tester,
  ) async {
    await Firebase.initializeApp();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: const SellerSignUpPageUI())),
    );

    expect(find.text('Personal Details'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });
}
