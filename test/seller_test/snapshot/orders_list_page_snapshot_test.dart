import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';

void main() {
  group('Orders List Page Snapshot Tests', () {
    testWidgets('Snapshot test validates layout', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersListPage()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // In Flutter, snapshot testing is effectively golden testing.
      await expectLater(
        find.byType(OrdersListPage),
        matchesGoldenFile('snapshots/orders_list_page_snapshot.png'),
      );
    });
  });
}
