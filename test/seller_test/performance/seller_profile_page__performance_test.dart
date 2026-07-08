import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';

void main() {
  testWidgets('SellerProfilePageUI scrolling performance test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SellerProfilePageUI()));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final listFinder = find.byType(SingleChildScrollView);
    
    // Watch performance while scrolling
    await tester.scrollUntilVisible(
      find.text('Logout'),
      100,
      scrollable: listFinder,
    );
    
    // Wait for scroll animations to finish
    await tester.pumpAndSettle();
    
    // In a real performance test, we'd use flutter_driver or integration_test
    // to measure frame rendering times. Here we ensure scrolling doesn't crash.
    expect(find.text('Logout'), findsOneWidget);
  });
}
