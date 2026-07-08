import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__ui.dart';

void main() {
  group('AddProductPage UI', () {
    testWidgets('renders all form fields correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddProductPage()));

      // Verify the title
      expect(find.text('13. Add Product'), findsOneWidget);
      expect(find.text('Add New Product'), findsOneWidget);

      // Verify the presence of form fields by labels
      expect(find.text('Product Name'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);

      // Verify the Save Product button exists
      expect(find.text('Save Product'), findsOneWidget);
    });
  });
}
