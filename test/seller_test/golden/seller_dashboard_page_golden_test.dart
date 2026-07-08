import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_ui.dart';

void main() {
  group('SellerDashboardPage Golden Tests', () {
    testWidgets('Dashboard UI matches golden image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SellerDashboardPageUI()));

      // Assuming golden files are stored in a 'goldens' folder
      // await expectLater(find.byType(SellerDashboardPageUI), matchesGoldenFile('goldens/dashboard_initial.png'));
    });
  });
}
