import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';

void main() {
  testWidgets('State restoration test for Profile Page', (WidgetTester tester) async {
    await tester.pumpWidget(
      const RootRestorationScope(
        restorationId: 'root',
        child: MaterialApp(
          home: SellerProfilePageUI(),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    // Simulate OS killing and restoring the app
    await tester.restartAndRestore();
    
    // Check if the page still loads and renders
    expect(find.byType(SellerProfilePageUI), findsOneWidget);
  });
}
