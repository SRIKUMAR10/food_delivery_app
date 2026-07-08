import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_model.dart';

void main() {
  group('ProductRepositoryImpl', () {
    late ProductRepositoryImpl repository;

    setUp(() {
      repository = ProductRepositoryImpl();
    });

    test('getProducts returns a list of products', () async {
      final products = await repository.getProducts();
      expect(products, isA<List<Product>>());
      expect(products.isNotEmpty, true);
    });

    test('deleteProduct removes a product by id', () async {
      final initialProducts = await repository.getProducts();
      final productToDelete = initialProducts.first;

      await repository.deleteProduct(productToDelete.id);
      final afterDeleteProducts = await repository.getProducts();

      expect(afterDeleteProducts.contains(productToDelete), false);
      expect(afterDeleteProducts.length, initialProducts.length - 1);
    });
  });
}
