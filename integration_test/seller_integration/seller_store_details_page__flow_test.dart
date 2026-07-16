import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Store Details Page Flow Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SellerStoreDetailsPage()));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify UI Elements
    expect(find.text('Picarhub Restaurant'), findsOneWidget);

    // Tap on Edit Store Details
    final editButton = find.text('Edit Store Details');
    expect(editButton, findsOneWidget);

    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // Add verification for next screen or state here
  });
}
