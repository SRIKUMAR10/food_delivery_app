import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';

void main() {
  group('Orders List Page Localization Tests', () {
    testWidgets('UI elements should render correctly with LTR locale', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(locale: Locale('en', 'US'), home: OrdersListPage()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('5. Orders List'), findsOneWidget);
    });
  });
}
