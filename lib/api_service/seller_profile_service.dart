import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class SellerProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerProfileService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchProfile() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('401 Unauthorized: User not logged in');
    }

    try {
      final docSnapshot = await _firestore.collection('sellers').doc(sellerId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;
        
        // Convert Timestamp to ISO strings for UI consistency
        if (data['memberSince'] is Timestamp) {
          data['memberSince'] = (data['memberSince'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      } else {
        // Create a default profile if it doesn't exist
        final defaultProfile = {
          'id': sellerId,
          'name': _auth.currentUser?.displayName ?? '',
          'email': _auth.currentUser?.email ?? '',
          'phone': _auth.currentUser?.phoneNumber ?? '',
          'storeName': _auth.currentUser?.displayName ?? '',
          'storeDescription': '',
          'avatarUrl': _auth.currentUser?.photoURL ?? '',
          'rating': 0.0,
          'totalOrders': 0,
          'memberSince': DateTime.now().toIso8601String(),
          'isVerified': false,
          'address': '',
          'bankAccountLinked': false,
        };
        await _firestore.collection('sellers').doc(sellerId).set(defaultProfile);
        return defaultProfile;
      }
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        throw Exception('403 Forbidden: Seller access revoked');
      }
      rethrow;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('401 Unauthorized: User not logged in');
    }

    try {
      await _firestore.collection('sellers').doc(sellerId).update(updates);
      return true;
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        throw Exception('403 Forbidden: Seller access revoked');
      }
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('401 Unauthorized: User not logged in');
    }

    try {
      // 1. Fetch seller profile to get profile image URL
      final docSnapshot = await _firestore.collection('sellers').doc(user.uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final imageUrl = data['imageUrl'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            await FirebaseStorage.instance.refFromURL(imageUrl).delete();
            debugPrint('Deleted seller profile image: $imageUrl');
          } catch (e) {
            debugPrint('Warning: Failed to delete seller profile image: $e');
          }
        }
      }

      // 2. Fetch and delete all products and their images for this seller
      final productsQuery = await _firestore.collection('products').where('sellerId', isEqualTo: user.uid).get();
      for (var productDoc in productsQuery.docs) {
        final productData = productDoc.data();
        if (productData['imageUrls'] != null) {
          List<dynamic> imageUrls = productData['imageUrls'];
          for (var url in imageUrls) {
            try {
              await FirebaseStorage.instance.refFromURL(url as String).delete();
              debugPrint('Deleted product image: $url');
            } catch (e) {
              debugPrint('Warning: Failed to delete product image: $e');
            }
          }
        }
        await productDoc.reference.delete();
      }

      // 3. Delete the seller profile document and auth account
      await _firestore.collection('sellers').doc(user.uid).delete();
      await user.delete();
      return true;
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }
}
