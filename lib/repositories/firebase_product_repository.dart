import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:food_delivery_app/main.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:food_delivery_app/core/models/product_model.dart';
import '../core/repositories/i_product_repository.dart';

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
          : (FirebaseAuth.instance.currentUser?.uid ?? 'default_seller');

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
        effectiveSellerId = product.sellerId;
      }
      if (effectiveSellerId.isEmpty) {
        effectiveSellerId = 'default_seller';
      }

      List<String> imageUrls = existingImages != null ? List<String>.from(existingImages) : List<String>.from(product.imageUrls);

      // Identify and delete removed images from Firebase Storage
      if (existingImages != null) {
        final removedImages = product.imageUrls.where((url) => !existingImages.contains(url)).toList();
        for (String removedUrl in removedImages) {
          try {
            final ref = _storage.refFromURL(removedUrl);
            await ref.delete();
            appLogger.i('Deleted orphaned product image from Storage: $removedUrl');
          } catch (e) {
            appLogger.w('Warning: Failed to delete orphaned product image: $e. URL: $removedUrl');
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

  /// Fetches products by category as a stream.
  Stream<List<Product>> getProductsByCategory(String categoryName) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: categoryName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Searches products using a backend query (e.g., via Algolia or simple prefix matching).
  /// This replaces in-memory filtering for better scalability.
  Stream<List<Product>> searchProducts(String query, String categoryName) {
    // Note: For a true enterprise app, this should call Algolia or Typesense.
    // As a fallback for Firestore, we use prefix matching.
    return _firestore
        .collection('products')
        .where('category', isEqualTo: categoryName)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList());
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
    if (sellerId.isEmpty) return null;

    final doc = await _firestore.collection('products').doc(id).get();
    if (doc.exists && doc.data() != null) {
      if (doc.data()!['sellerId'] == sellerId) {
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
