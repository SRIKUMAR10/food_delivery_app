import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:food_delivery_app/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import '../features/seller_bloc_architecture/product_list_page_/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProductRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  Future<void> addProduct(Product product, List<XFile> images) async {
    try {
      // Identify the UID of the currently logged-in Seller
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Seller must be logged in to add a product.');
      }
      final String sellerId = currentUser.uid;

      List<String> imageUrls = [];
      int counter = 0;
      for (var imageFile in images) {
        final safeFileName = imageFile.name.replaceAll(
          RegExp(r'[^A-Za-z0-9._-]'),
          '_',
        );
        final metadata = SettableMetadata(
          contentType: imageFile.mimeType ?? 'image/jpeg',
        );
        final ref = _storage
            .ref()
            .child('product_images')
            .child(sellerId)
            .child(
              '${DateTime.now().millisecondsSinceEpoch}_${counter++}_$safeFileName',
            );

        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          if (bytes.isNotEmpty) {
            await ref.putData(bytes, metadata);
            imageUrls.add(await ref.getDownloadURL());
          }
        } else {
          await ref.putFile(File(imageFile.path), metadata);
          imageUrls.add(await ref.getDownloadURL());
        }
      }

      final payload = product.toMap();
      payload['imageUrls'] = imageUrls;
      payload['sellerId'] = sellerId;
      payload['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('products').add(payload);
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(Product product, List<XFile> newImages) async {
    try {
      final String sellerId = product.sellerId.isNotEmpty
          ? product.sellerId
          : (FirebaseAuth.instance.currentUser?.uid ?? '');
      if (sellerId.isEmpty) throw Exception('Seller not logged in');

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
          contentType: imageFile.mimeType ?? 'image/jpeg',
        );
        final ref = _storage
            .ref()
            .child('product_images')
            .child(sellerId)
            .child(
              '${DateTime.now().millisecondsSinceEpoch}_${counter++}_$safeFileName',
            );

        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          if (bytes.isNotEmpty) {
            await ref.putData(bytes, metadata);
            imageUrls.add(await ref.getDownloadURL());
          }
        } else {
          await ref.putFile(File(imageFile.path), metadata);
          imageUrls.add(await ref.getDownloadURL());
        }
      }

      final payload = product.toMap();
      payload['imageUrls'] = imageUrls;
      payload['sellerId'] = sellerId;
      payload['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('products').doc(product.id).update(payload);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Fetches products by category as a stream.
  Stream<QuerySnapshot> getProductsByCategory(String categoryName) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: categoryName)
        .snapshots();
  }

  /// Searches products using a backend query (e.g., via Algolia or simple prefix matching).
  /// This replaces in-memory filtering for better scalability.
  Stream<QuerySnapshot> searchProducts(String query, String categoryName) {
    // Note: For a true enterprise app, this should call Algolia or Typesense.
    // As a fallback for Firestore, we use prefix matching.
    return _firestore
        .collection('products')
        .where('category', isEqualTo: categoryName)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots();
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Seller must be logged in to delete a product.');
      }
      final String sellerId = currentUser.uid;

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
              appLogger.w(
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

  Future<void> toggleProductStatus(String productId, bool isActive) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isActive': isActive,
      });
    } catch (e) {
      throw Exception('Failed to toggle product status: $e');
    }
  }

  Future<void> duplicateProduct(Product product) async {
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

  Stream<List<Product>> getProductsStream({
    int limit = 20,
    String searchQuery = '',
    String filterType = 'All Products',
    String sortBy = 'Recently Added',
    String? categoryFilter,
  }) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection('products')
        .where('sellerId', isEqualTo: currentUser.uid);

    if (categoryFilter != null &&
        categoryFilter.isNotEmpty &&
        categoryFilter != 'All Categories') {
      query = query.where('category', isEqualTo: categoryFilter);
    }

    if (filterType == 'Active') {
      query = query.where('isActive', isEqualTo: true);
    } else if (filterType == 'Inactive') {
      query = query.where('isActive', isEqualTo: false);
    }

    if (sortBy == 'Recently Added') {
      query = query.orderBy('createdAt', descending: true);
    } else if (sortBy == 'Price: Low to High') {
      query = query.orderBy('price', descending: false);
    } else if (sortBy == 'Price: High to Low') {
      query = query.orderBy('price', descending: true);
    } else if (sortBy == 'Most Popular') {
      query = query.orderBy('salesCount', descending: true);
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      List<Product> products = snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      if (searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        products = products
            .where((p) => p.name.toLowerCase().contains(lowerQuery))
            .toList();
      }

      // Fallback in-memory filter if complex Firestore queries aren't built
      if (filterType == 'Low Stock') {
        products = products
            .where((p) => p.status == ProductStatus.lowStock)
            .toList();
      }

      return products;
    });
  }

  /// Fetches all products for the current seller and converts them to a CSV formatted string.
  ///
  /// Returns a tuple containing the generated file path and the CSV data.
  Future<(String, String)> exportProductsToCsv() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('Seller must be logged in to export products.');
    }

    try {
      // Fetch all products for the current seller without pagination.
      final querySnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: currentUser.uid)
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
}
