import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
// Adjust if main.dart is different
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Seller Onboard Page Flow Test', () {
    testWidgets('User can navigate through onboard page successfully', (
      WidgetTester tester,
    ) async {
      // Assuming you can push this page directly or start the app at this page for the test
      // Here we pump the specific widget for isolated integration testing
      await tester.pumpWidget(const MaterialApp(home: SellerOnboardPageUI()));
      await tester.pumpAndSettle();

      // Verify initial UI elements
      expect(find.text('Seller App'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Tap 'Get Started' button
      await tester.tap(find.text('Get Started'));
      await tester.pump(); // Start loading

      // Expect CircularProgressIndicator (loading state)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the simulated delay in BLoC
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // After loading, it should show success snackbar (or navigate)
      expect(find.text('Successfully started!'), findsOneWidget);
    });
  });
}
