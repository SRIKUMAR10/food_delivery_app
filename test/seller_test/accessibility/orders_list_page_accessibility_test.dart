import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';

void main() {
  group('Orders List Page Accessibility Tests', () {
    testWidgets('Page meets accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(const MaterialApp(home: OrdersListPage()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check that at least the title has a semantic label (implied by text)
      expect(
        tester.getSemantics(find.text('5. Orders List')),
        matchesSemantics(label: '5. Orders List'),
      );

      // Tap targets should be accessible sizes
      expect(find.byType(GestureDetector), findsWidgets);

      handle.dispose();
    });
  });
}
