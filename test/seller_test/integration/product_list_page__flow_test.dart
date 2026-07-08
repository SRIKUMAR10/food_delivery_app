import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Product List Page Integration Flow', () {
    testWidgets('verify products load and filter correctly', (
      WidgetTester tester,
    ) async {
      // Setup real repository but maybe with seeded mock data for integration
      final repository = ProductRepositoryImpl();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => ProductListBloc(repository: repository),
            child: const ProductListPage(),
          ),
        ),
      );

      // Wait for initial load animation/skeleton
      await tester.pumpAndSettle();

      // Verify header exists
      expect(find.text('Products'), findsWidgets);

      // Verify specific product from mock repo exists
      expect(find.text('Red Pizza'), findsOneWidget);
      expect(find.text('Chicken Pizza'), findsOneWidget);

      // Tap on 'Active' filter
      await tester.tap(find.textContaining('Active ('));
      await tester.pumpAndSettle();

      // Garlic bread is inactive in mock repo, so it shouldn't be here
      expect(find.text('Garlic Bread'), findsNothing);

      // Tap on 'Inactive' filter
      await tester.tap(find.textContaining('Inactive ('));
      await tester.pumpAndSettle();

      // Now Garlic bread should be the only one visible
      expect(find.text('Garlic Bread'), findsOneWidget);
      expect(find.text('Red Pizza'), findsNothing);
    });
  });
}
