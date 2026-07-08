import 'product_model.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<void> deleteProduct(String id);
}

class ProductRepositoryImpl implements ProductRepository {
  // Mock data representing database or API
  final List<Product> _mockProducts = [
    const Product(
      id: '1',
      name: 'Red Pizza',
      price: 400,
      imageUrl: 'https://via.placeholder.com/150',
      status: ProductStatus.inStock,
      isActive: true,
    ),
    const Product(
      id: '2',
      name: 'Chicken Pizza',
      price: 300,
      imageUrl: 'https://via.placeholder.com/150',
      status: ProductStatus.inStock,
      isActive: true,
    ),
    const Product(
      id: '3',
      name: 'Italian Continental',
      price: 600,
      imageUrl: 'https://via.placeholder.com/150',
      status: ProductStatus.lowStock,
      isActive: true,
    ),
    const Product(
      id: '4',
      name: 'Garlic Bread',
      price: 150,
      imageUrl: 'https://via.placeholder.com/150',
      status: ProductStatus.inStock,
      isActive: false, // Inactive example
    ),
  ];

  @override
  Future<List<Product>> getProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_mockProducts);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockProducts.removeWhere((product) => product.id == id);
  }
}
