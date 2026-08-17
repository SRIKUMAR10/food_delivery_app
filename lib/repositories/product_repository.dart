import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

import 'package:image_picker/image_picker.dart';
import 'package:food_delivery_app/core/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Logger _logger = Logger();

  ProductRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  Future<void> addProduct(Product product, List<XFile> images, String sellerId) async {
    try {
      final String effectiveSellerId = sellerId.isNotEmpty
          ? sellerId
          : (_firestore.app.options.projectId.isNotEmpty
              ? 'default_seller'
              : 'default_seller');

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

  Future<void> updateProduct(Product product, List<XFile> newImages, String sellerId) async {
    try {
      final String effectiveSellerId = sellerId.isNotEmpty
          ? sellerId
          : (product.sellerId.isNotEmpty ? product.sellerId : 'default_seller');

      List<String> imageUrls = List<String>.from(product.imageUrls);

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

  /// Fetches products by category as a stream.
  Stream<List<Product>> getProductsByCategory(String categoryName) {
    if (categoryName.trim().isEmpty || categoryName.trim().toLowerCase() == 'all') {
      return _firestore
          .collection('products')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList());
    }
    return _firestore
        .collection('products')
        .where('category', isEqualTo: categoryName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList());
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
    });
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
              _logger.w(
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

  Future<void> toggleProductStatus(String productId, bool isActive, String sellerId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isActive': isActive,
      });
    } catch (e) {
      throw Exception('Failed to toggle product status: $e');
    }
  }

  Future<void> duplicateProduct(Product product, String sellerId) async {
    try {
      final newProduct = product.copyWith(
        id: '', // Will be assigned by Firestore
        name: '${product.name} (Copy)',
      );
      final payload = newProduct.toMap();
      payload['createdAt'] = FieldValue.serverTimestamp();
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

    Query query = _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId);

    return query.snapshots().map((snapshot) {
      List<Product> products = snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
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
