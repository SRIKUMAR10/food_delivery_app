import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';

void main() {
  testWidgets('Seller Profile Page Integration Flow - Logout Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SellerProfilePageUI()));
    
    // Allow bloc to load profile
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap on Logout
    final logoutFinder = find.text('Logout');
    expect(logoutFinder, findsOneWidget);
    await tester.tap(logoutFinder);
    
    // Allow state to update
    await tester.pump();
    
    // Expect to be back to loading or initial based on bloc logic
    // We emitted ProfileInitial on logout, so Skeleton loader should be back
    expect(find.byType(ProfileSkeletonLoader), findsOneWidget);
  });
}
