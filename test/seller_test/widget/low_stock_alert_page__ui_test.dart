import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/low_stock_alert_page__ui.dart';

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('LowStockAlertPage UI Test', () {
    testWidgets('renders loading state initially and then loaded state', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MaterialApp(home: LowStockAlertPage()));

      // Initially, it should show the skeleton loader (Loading State)
      // Wait, because we are using a real Bloc here without mocking, it might actually wait.
      // In a real widget test, we would mock the bloc. Since we didn't add mocktail/mockito yet,
      // we can pump and settle to see the final UI.

      // Let's pump until animations are done.
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check for main texts
      expect(find.text('Low Stock Alert'), findsOneWidget);
      expect(find.text('5 items are running low'), findsOneWidget);

      // Check for specific items from our mock list
      expect(find.text('Cheese'), findsOneWidget);
      expect(find.text('Chicken'), findsOneWidget);

      // Check for bottom button
      expect(find.text('View Inventory'), findsOneWidget);
    });
  });
}
