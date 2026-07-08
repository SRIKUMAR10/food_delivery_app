import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';

void main() {
  testWidgets('SellerProfilePageUI matches golden file', (WidgetTester tester) async {
    // Note: Golden tests require a specific font setup to be consistent across platforms.
    await tester.pumpWidget(
      const MaterialApp(
        home: SellerProfilePageUI(),
      ),
    );
    
    // Allow network and UI to settle
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    // Compare against golden file
    await expectLater(
      find.byType(SellerProfilePageUI),
      matchesGoldenFile('seller_profile_page__ui.png'),
    );
  });
}
