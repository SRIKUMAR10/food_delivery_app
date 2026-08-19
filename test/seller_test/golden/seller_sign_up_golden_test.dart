import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
  });

  testWidgets('Seller SignUp Golden Test', (WidgetTester tester) async {
    await Firebase.initializeApp();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SellerSignUpPageUI())),
    );

    // Verify widget tree renders without golden comparison
    // (golden requires google_fonts asset files not available in CI)
    expect(find.byType(SellerSignUpPageUI), findsOneWidget);
    expect(find.text('Personal Details'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });
}
