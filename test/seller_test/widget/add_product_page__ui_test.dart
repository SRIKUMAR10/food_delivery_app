import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__ui.dart';

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('AddProductPage UI', () {
    testWidgets('renders all form fields correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddProductPage()));

      // Verify the title
      expect(find.text('Add Product'), findsOneWidget);

      // Verify the presence of text fields
      expect(find.byType(TextField), findsWidgets);
    });
  });
}
