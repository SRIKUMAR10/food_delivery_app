import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';

void main() {
  group('State Restoration Test', () {
    testWidgets('State is restored correctly after process death', (
      tester,
    ) async {
      await tester.pumpWidget(
        const RootRestorationScope(
          restorationId: 'root',
          child: MaterialApp(home: SellerOnboardPageUI()),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger restoration
      await tester.restartAndRestore();
      await tester.pumpAndSettle();

      // Ensure UI comes back correctly
      expect(find.text('Seller App'), findsOneWidget);
    });
  });
}
