import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Import kIsWeb

class ProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProductRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
    required String category,
    XFile? imageFile,
  }) async {
    try {
      // Identify the UID of the currently logged-in Seller
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception(
          'Seller must be logged in to add a product.',
        );
      }
      final String sellerId = currentUser.uid;

      String? imageUrl;
      if (imageFile != null) {
        // Upload image to Firebase Storage
        // By separating folders by sellerId, we assign these images to that specific seller
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
            .child('${DateTime.now().millisecondsSinceEpoch}_$safeFileName');

        if (kIsWeb) {
          // Use readAsBytes() for Web to upload bytes
          final bytes = await imageFile.readAsBytes();
          if (bytes.isNotEmpty) {
            await ref.putData(bytes, metadata);
            imageUrl = await ref.getDownloadURL();
          }
        } else {
          // Upload file path for Native
          await ref.putFile(File(imageFile.path), metadata);
          imageUrl = await ref.getDownloadURL();
        }
      }

      // Add product details to Firestore
      await _firestore.collection('products').add({
        'name': name,
        'price': price,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
        'sellerId': sellerId, // Add seller reference in Firestore
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
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
}
