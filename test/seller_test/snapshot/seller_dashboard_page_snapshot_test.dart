import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_ui.dart';

void main() {
  group('Snapshot Tests', () {
    // Note: Flutter doesn't have a built-in JSON/DOM snapshot test like Jest for React,
    // so this is often approximated via Golden tests or asserting widget trees.
    testWidgets('Dashboard initial widget tree snapshot', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SellerDashboardPageUI()));

      // Ensure the scaffold exists and has a specific structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
