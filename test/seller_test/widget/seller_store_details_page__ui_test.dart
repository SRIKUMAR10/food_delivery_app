import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__ui.dart';

void main() {
  testWidgets('SellerStoreDetailsPage renders skeleton first then details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SellerStoreDetailsPage()));

    // Initial state should show Store Details in AppBar
    expect(find.text('Store Details'), findsOneWidget);

    // After 2 seconds, it should load data
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Check if store details are rendered
    expect(find.text('Picarhub Restaurant'), findsOneWidget);
    expect(find.text('Opening Hours'), findsOneWidget);
    expect(find.text('Delivery Time'), findsOneWidget);
    expect(find.text('Delivery Area'), findsOneWidget);
    expect(find.text('Edit Store Details'), findsOneWidget);
  });
}
