import 'package:cloud_firestore/cloud_firestore.dart';

class SellerUserCollection {
  // Reference to the Firestore collection named 'seller_users'
  final CollectionReference _sellerCollection = FirebaseFirestore.instance
      .collection('seller_users');

  /// Function to receive Seller details as a Map and, based on UID,
  /// add or modify it as a new document in Firestore.
  Future<void> addSeller(String uid, Map<String, dynamic> sellerData) async {
    try {
      await _sellerCollection.doc(uid).set(sellerData);
    } catch (e) {
      throw Exception('Failed to add seller to Firestore: $e');
    }
  }

  /// Getting details of a specific Seller
  Future<DocumentSnapshot> getSeller(String uid) async {
    try {
      return await _sellerCollection.doc(uid).get();
    } catch (e) {
      throw Exception('Failed to get seller details: $e');
    }
  }

  Stream<QuerySnapshot> getSellersStream() {
    return _sellerCollection.snapshots();
  }
}
