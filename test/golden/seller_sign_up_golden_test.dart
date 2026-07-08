import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_ui.dart';

void main() {
  testWidgets('Seller SignUp Golden Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SellerSignUpPageUI())),
    );

    await expectLater(
      find.byType(SellerSignUpPageUI),
      matchesGoldenFile('goldens/seller_sign_up_initial.png'),
    );
  });
}
