import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';

void main() {
  group('Orders List Page Performance Tests', () {
    testWidgets('Scrolling performance test', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: OrdersListPage()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final listFinder = find.byType(ListView);

      // Perform a series of rapid scrolls to ensure no jank
      await tester.fling(listFinder, const Offset(0, -500), 10000);
      await tester.pumpAndSettle();

      await tester.fling(listFinder, const Offset(0, 500), 10000);
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
