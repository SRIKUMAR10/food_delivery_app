import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';

abstract interface class IProductRepository {
  Future<void> addProduct(Product product, List<XFile> images, String sellerId);
  Future<void> updateProduct(Product product, List<XFile> newImages, String sellerId, {List<String>? existingImages});
  Future<void> deleteProduct(String id, String sellerId);
  Future<void> toggleProductStatus(String id, bool isActive, String sellerId);
  Future<void> archiveProduct(String id, String sellerId);
  Future<void> unarchiveProduct(String id, String sellerId);
  Future<void> duplicateProduct(Product product, String sellerId);
  Future<void> updateProductStock(String id, int stock, bool hasUnlimitedStock, String sellerId);
  Future<void> updateProductPrice(String id, double price, double discountPrice, String sellerId);
  Future<void> markProductOutOfStock(String id, String sellerId);
  Future<Product?> getProduct(String id, String sellerId);
  Future<List<Product>> getProducts(String sellerId);
  Stream<List<Product>> getProductsStream(String sellerId, {
    int limit,
    String searchQuery,
    String filterType,
    String sortBy,
    String? categoryFilter,
  });
  Stream<List<Product>> getProductsByCategory(String categoryName);
  Stream<List<Product>> searchProducts(String query, String categoryName);
  Future<(String, String)> exportProductsToCsv(String sellerId);
}
