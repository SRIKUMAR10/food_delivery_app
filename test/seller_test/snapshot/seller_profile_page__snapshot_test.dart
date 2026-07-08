import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';

void main() {
  testWidgets('SellerProfilePageUI snapshot test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SellerProfilePageUI()));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // A snapshot test verifies the UI structure hasn't changed.
    // We check the specific count of critical widgets
    expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });
}
