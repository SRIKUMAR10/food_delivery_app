import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';

void main() {
  testWidgets('SellerProfilePageUI meets accessibility guidelines', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    
    await tester.pumpWidget(const MaterialApp(home: SellerProfilePageUI()));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify semantics of a specific button
    final logoutButton = find.text('Logout');
    expect(logoutButton, findsOneWidget);
    
    // Test that the app meets text contrast, tap target sizes, etc.
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    
    handle.dispose();
  });
}
