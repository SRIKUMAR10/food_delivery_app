import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';

void main() {
  testWidgets('End-to-End User Flow Test on Profile Page', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SellerProfilePageUI()));
    
    // Wait for the bloc to load data
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify all menu items exist
    final menuItems = [
      'Business Details',
      'Bank Details',
      'Change Password',
      'Notification Settings',
      'Logout'
    ];
    
    for (var item in menuItems) {
      expect(find.text(item), findsOneWidget);
    }
    
    // Test tapping a menu item
    await tester.tap(find.text('Business Details'));
    await tester.pumpAndSettle();
    // In a real app, verify navigation occurred. Here we just ensure no crash.
    
    // Test tapping Settings if it was present here
    // await tester.tap(find.text('Notification Settings'));
    // await tester.pumpAndSettle();
  });
}
