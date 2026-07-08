import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';

void main() {
  group('Orders List Page Golden Tests', () {
    testWidgets('Golden test for Orders List Page', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersListPage()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await expectLater(
        find.byType(OrdersListPage),
        matchesGoldenFile('goldens/orders_list_page_golden.png'),
      );
    });
  });
}
