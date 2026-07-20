import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__bloc.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';

class MockProductRepository extends Mock implements IProductRepository {}
class MockAuthService extends Mock implements IAuthService {}

Product _product({
  required String id,
  required String name,
  required double price,
  required bool isActive,
  required String foodType,
}) {
  return Product(
    id: id,
    name: name,
    price: price,
    imageUrls: [],
    status: ProductStatus.inStock,
    isActive: isActive,
    foodType: foodType,
    category: 'General',
    rating: 0.0,
    salesCount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Product List Page Integration Flow', () {
    testWidgets('verify products load and filter correctly', (
      WidgetTester tester,
    ) async {
      final repository = MockProductRepository();
      final authService = MockAuthService();

      when(() => authService.currentUserId).thenReturn('seller1');
      when(() => authService.authStateChanges).thenAnswer((_) => Stream.value('seller1'));

      final redPizza = _product(id: '1', name: 'Red Pizza', price: 200, isActive: true, foodType: 'veg');
      final chickenPizza = _product(id: '2', name: 'Chicken Pizza', price: 250, isActive: true, foodType: 'non-veg');
      final garlicBread = _product(id: '3', name: 'Garlic Bread', price: 100, isActive: false, foodType: 'veg');

      when(() => repository.getProductsStream('seller1'))
          .thenAnswer((_) => Stream.value([redPizza, chickenPizza, garlicBread]));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => ProductListBloc(repository: repository, authService: authService),
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
