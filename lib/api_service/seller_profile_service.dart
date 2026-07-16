import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          'name': _auth.currentUser?.displayName ?? 'Picarhub Kitchen',
          'email': _auth.currentUser?.email ?? 'picarhub@foodgo.com',
          'phone': _auth.currentUser?.phoneNumber ?? '+91 98765 43210',
          'storeName': 'Picarhub Kitchen',
          'storeDescription': 'Authentic home-cooked meals with fresh ingredients, delivered hot.',
          'avatarUrl': _auth.currentUser?.photoURL ?? 'https://images.unsplash.com/photo-1581299894007-aaa50297cf16?w=200',
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
      // Typically in Firebase, you'd want a Cloud Function to clean up data before deleting user
      await _firestore.collection('sellers').doc(user.uid).delete();
      await user.delete();
      return true;
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }
}
