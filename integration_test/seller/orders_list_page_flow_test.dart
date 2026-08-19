import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Orders List Flow Integration Test', () {
    testWidgets('Navigate through tabs and see orders', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersListPage()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Initial tab is New
      expect(find.text('Mike Ross'), findsOneWidget);

      // Tap on Preparing tab
      // Note: the text might be 'Preparing (2)', so we use find.textContaining
      await tester.tap(find.textContaining('Preparing'));
      await tester.pumpAndSettle();

      // Check for Preparing order
      expect(find.text('Jane Smith'), findsOneWidget);

      // Tap on Completed
      await tester.tap(find.textContaining('Completed'));
      await tester.pumpAndSettle();
      expect(find.text('David Lee'), findsOneWidget);
    });
  });
}
