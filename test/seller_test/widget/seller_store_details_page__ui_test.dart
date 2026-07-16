import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__ui.dart';

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

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
    expect(find.text('Commission Percentage'), findsOneWidget);
    expect(find.text('Minimum Order Value'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Edit Store Details'), findsOneWidget);
  });
}
