import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_ui.dart';

void main() {
  testWidgets('InventoryLowStockPage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryLowStockPage()));

    // Initially loading state
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);

    // Pump and wait for API simulation to finish
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Loaded State verification
    expect(find.text('Total items'), findsOneWidget);
    expect(find.text('Low Stock'), findsWidgets); // Used in Summary and Badges
    expect(find.text('Out of Stock'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('Cheese'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);
  });
}
