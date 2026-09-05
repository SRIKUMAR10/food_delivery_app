import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:food_delivery_app/core/models/product_model.dart';
import '../core/repositories/i_product_repository.dart';

final Logger _repoLogger = Logger(
  printer: PrettyPrinter(methodCount: 0, lineLength: 80),
);

class FirebaseProductRepository implements IProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  FirebaseProductRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  Future<void> addProduct(Product product, List<XFile> images, String sellerId) async {
    try {
      final String effectiveSellerId = sellerId.isNotEmpty
          ? sellerId
          : (FirebaseAuth.instance.currentUser?.uid ?? '');

      if (effectiveSellerId.isEmpty) {
        throw Exception('User not authenticated: sellerId is required.');
      }

      List<String> imageUrls = [];
      int counter = 0;
      for (var imageFile in images) {
        final safeFileName = imageFile.name.replaceAll(
          RegExp(r'[^A-Za-z0-9._-]'),
          '_',
        );
        final metadata = SettableMetadata(
          contentType: _resolveContentType(imageFile.name, imageFile.mimeType),
        );
        final ref = _storage
            .ref()
            .child('product_images')
            .child(effectiveSellerId)
            .child(
              '${DateTime.now().millisecondsSinceEpoch}_${counter++}_$safeFileName',
            );

        final bytes = await imageFile.readAsBytes();
        if (bytes.isNotEmpty) {
          await ref.putData(bytes, metadata);
          imageUrls.add(await ref.getDownloadURL());
        }
      }

      final payload = product.toMap();
      payload['imageUrls'] = imageUrls;
      payload['sellerId'] = effectiveSellerId;
      payload['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('products').add(payload);
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product, List<XFile> newImages, String sellerId, {List<String>? existingImages}) async {
    try {
      String effectiveSellerId = sellerId;
      if (effectiveSellerId.isEmpty) {
        effectiveSellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
      }
      if (effectiveSellerId.isEmpty) {
        throw Exception('User not authenticated: sellerId is required.');
      }

      List<String> imageUrls = existingImages != null ? List<String>.from(existingImages) : List<String>.from(product.imageUrls);

      // Identify and delete removed images from Firebase Storage
      if (existingImages != null) {
        final removedImages = product.imageUrls.where((url) => !existingImages.contains(url)).toList();
        for (String removedUrl in removedImages) {
          try {
            final ref = _storage.refFromURL(removedUrl);
            await ref.delete();
            _repoLogger.i('Deleted orphaned product image from Storage: $removedUrl');
          } catch (e) {
            _repoLogger.w('Warning: Failed to delete orphaned product image: $e. URL: $removedUrl');
          }
        }
      }

      // Upload any newly added local images
      int counter = 0;
      for (var imageFile in newImages) {
        // If the XFile path is an http url, it means it's an existing image.
        if (imageFile.path.startsWith('http')) continue;

        final safeFileName = imageFile.name.replaceAll(
          RegExp(r'[^A-Za-z0-9._-]'),
          '_',
        );
        final metadata = SettableMetadata(
          contentType: _resolveContentType(imageFile.name, imageFile.mimeType),
        );
        final ref = _storage
            .ref()
            .child('product_images')
            .child(effectiveSellerId)
            .child(
              '${DateTime.now().millisecondsSinceEpoch}_${counter++}_$safeFileName',
            );

        final bytes = await imageFile.readAsBytes();
        if (bytes.isNotEmpty) {
          await ref.putData(bytes, metadata);
          imageUrls.add(await ref.getDownloadURL());
        }
      }

      final payload = product.toMap();
      payload['imageUrls'] = imageUrls;
      payload['sellerId'] = effectiveSellerId;
      payload['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('products').doc(product.id).update(payload);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Stream<List<Product>> getProductsByCategory(String categoryName) {
    final trimmedCategory = categoryName.trim().toLowerCase();
    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
          final allProducts = snapshot.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList();

          if (trimmedCategory.isEmpty || trimmedCategory == 'all') {
            return allProducts;
          }

          return allProducts.where((p) => p.category.trim().toLowerCase() == trimmedCategory).toList();
        }).handleError((_) => <Product>[]);
  }

  /// Searches products across Name, Ingredients, Add-ons, Category, and Description.
  Stream<List<Product>> searchProducts(String query, String categoryName) {
    Query<Map<String, dynamic>> queryRef = _firestore.collection('products');
    if (categoryName.isNotEmpty && categoryName != 'All') {
      queryRef = queryRef.where('category', isEqualTo: categoryName);
    }
    return queryRef.snapshots().map((snapshot) {
      final qLower = query.toLowerCase().trim();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .where((product) {
            if (qLower.isEmpty) return true;
            final nameMatch = product.name.toLowerCase().contains(qLower);
            final descMatch = product.description.toLowerCase().contains(qLower);
            final ingMatch = product.ingredients.any((ing) => ing.toLowerCase().contains(qLower));
            final addonMatch = product.addons.any((add) => add.toLowerCase().contains(qLower));
            final catMatch = product.category.toLowerCase().contains(qLower);
            return nameMatch || descMatch || ingMatch || addonMatch || catMatch;
          })
          .toList();
    }).handleError((_) => <Product>[]);
  }

  Future<void> deleteProduct(String productId, String sellerId) async {
    try {
      final docRef = _firestore.collection('products').doc(productId);
      final doc = await docRef.get();

      if (doc.exists) {
        if (doc.data()?['sellerId'] != sellerId) {
          throw Exception(
            'Unauthorized: You can only delete your own products.',
          );
        }

        final data = doc.data();
        if (data != null && data['imageUrls'] != null) {
          List<String> imageUrls = List<String>.from(data['imageUrls']);
          for (String url in imageUrls) {
            try {
              final ref = _storage.refFromURL(url);
              await ref.delete();
            } catch (e) {
              _repoLogger.w(
                'Warning: Failed to delete image from storage: $e. URL: $url',
              );
            }
          }
        }
      }
      await docRef.delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<void> toggleProductStatus(String productId, bool isActive, String sellerId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isActive': isActive,
        'status': isActive ? 'inStock' : 'outOfStock',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle product status: $e');
    }
  }

  @override
  Future<void> updateProductStock(String productId, int newStock, bool hasUnlimitedStock, String sellerId) async {
    try {
      final bool isStockAvailable = hasUnlimitedStock || newStock > 0;
      final String status = isStockAvailable ? 'inStock' : 'outOfStock';
      await _firestore.collection('products').doc(productId).update({
        'availableStock': newStock,
        'hasUnlimitedStock': hasUnlimitedStock,
        'isActive': isStockAvailable,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product stock: $e');
    }
  }

  @override
  Future<void> updateProductPrice(String productId, double newPrice, double newDiscountPrice, String sellerId) async {
    try {
      final docSnap = await _firestore.collection('products').doc(productId).get();
      final data = docSnap.data();
      double discountPercentage = 0.0;
      if (data != null && newDiscountPrice > 0 && newPrice > newDiscountPrice) {
        final rawPct = ((newPrice - newDiscountPrice) / newPrice) * 100.0;
        discountPercentage = ((rawPct * 100).roundToDouble()) / 100.0;
        if ((discountPercentage - discountPercentage.round()).abs() < 0.05) {
          discountPercentage = discountPercentage.roundToDouble();
        }
      }
      final updateData = <String, dynamic>{
        'price': newPrice,
        'discountPrice': newDiscountPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (discountPercentage > 0) {
        updateData['discountPercentage'] = discountPercentage;
      }
      await _firestore.collection('products').doc(productId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update product price: $e');
    }
  }

  @override
  Future<void> markProductOutOfStock(String productId, String sellerId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'availableStock': 0,
        'isActive': false,
        'status': 'outOfStock',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark product out of stock: $e');
    }
  }

  @override
  Future<void> duplicateProduct(Product product, String sellerId) async {
    try {
      final newProduct = product.copyWith(
        id: '', // Will be assigned by Firestore
        name: '${product.name} (Copy)',
      );
      final payload = newProduct.toMap();
      payload['createdAt'] = FieldValue.serverTimestamp();
      payload['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('products').add(payload);
    } catch (e) {
      throw Exception('Failed to duplicate product: $e');
    }
  }

  Stream<List<Product>> getProductsStream(String sellerId, {
    int limit = 20,
    String searchQuery = '',
    String filterType = 'All Products',
    String sortBy = 'Recently Added',
    String? categoryFilter,
  }) {

    final query = _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId);

    return query.snapshots().map((snapshot) {
      List<Product> products = snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data());
      }).toList();

      return products;
    });
  }

  /// Fetches all products for the current seller and converts them to a CSV formatted string.
  ///
  /// Returns a tuple containing the generated file path and the CSV data.
  Future<(String, String)> exportProductsToCsv(String sellerId) async {

    try {
      // Fetch all products for the current seller without pagination.
      final querySnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      final products = querySnapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();

      if (products.isEmpty) {
        throw Exception('No products to export.');
      }

      // Define CSV headers
      final List<String> headers = [
        'ID',
        'Name',
        'Price',
        'Discount Price',
        'Category',
        'Description',
        'Food Type',
        'Is Active',
        'Status',
        'Prep Time',
        'Calories',
        'Spicy Level',
        'Rating',
        'Review Count',
      ];

      // Map product data to rows
      List<List<dynamic>> rows = [headers];
      for (var p in products) {
        rows.add([
          p.id,
          p.name,
          p.price,
          p.discountPrice,
          p.category,
          p.description,
          p.foodType,
          p.isActive,
          p.status.toString().split('.').last,
          p.prepTime,
          p.calories,
          p.spicyLevel,
          p.rating,
          p.reviewCount,
        ]);
      }

      // Convert to CSV string
      String csvData = const ListToCsvConverter().convert(rows);
      final String fileName =
          'products_export_${DateTime.now().toIso8601String()}.csv';

      return (fileName, csvData);
    } catch (e) {
      throw Exception('Failed to export products to CSV: $e');
    }
  }

  @override
  Future<List<Product>> getProducts(String sellerId) async {
    if (sellerId.isEmpty) return [];

    final snapshot = await _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<Product?> getProduct(String id, String sellerId) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (doc.exists && doc.data() != null) {
      final docSellerId = doc.data()!['sellerId']?.toString().trim();
      final targetSellerId = sellerId.trim();
      if (targetSellerId.isEmpty || docSellerId == null || docSellerId.isEmpty || docSellerId == targetSellerId) {
        return Product.fromMap(doc.id, doc.data()!);
      }
    }
    return null;
  }

  @override
  Future<void> archiveProduct(String id, String sellerId) async {
    await _firestore.collection('products').doc(id).update({
      'isArchived': true,
    });
  }

  @override
  Future<void> unarchiveProduct(String id, String sellerId) async {
    await _firestore.collection('products').doc(id).update({
      'isArchived': false,
    });
  }

  static String _resolveContentType(String fileName, String? fallbackMime) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.svg')) return 'image/svg+xml';
    return fallbackMime ?? 'image/jpeg';
  }
}
