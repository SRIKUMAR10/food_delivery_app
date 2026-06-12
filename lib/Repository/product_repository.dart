import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // kIsWeb-ஐ இறக்குமதி செய்யவும்

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
    required String category,
    XFile? imageFile,
  }) async {
    try {
      // தற்போது லாகின் செய்துள்ள Seller-ன் UID-ஐ அடையாளம் காணுதல்
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception(
          'Product-ஐச் சேர்க்க Seller லாகின் செய்திருக்க வேண்டும்.',
        );
      }
      final String sellerId = currentUser.uid;

      String? imageUrl;
      if (imageFile != null) {
        // Upload image to Firebase Storage
        // Folder-ஐ sellerId மூலம் பிரிப்பதன் மூலம் அந்தப் படங்களை அந்த குறிப்பிட்ட seller-க்குச் சொந்தமாக்குகிறோம்
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
          // Web-க்கு readAsBytes() பயன்படுத்தி bytes-ஐ பதிவேற்றவும்
          final bytes = await imageFile.readAsBytes();
          if (bytes.isNotEmpty) {
            await ref.putData(bytes, metadata);
            imageUrl = await ref.getDownloadURL();
          }
        } else {
          // Native-க்கு file path-ஐ பதிவேற்றவும்
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
        'sellerId': sellerId, // Firestore-ல் seller reference-ஐச் சேர்த்தல்
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }
}
