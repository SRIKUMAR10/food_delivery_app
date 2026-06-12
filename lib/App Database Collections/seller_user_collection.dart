import 'package:cloud_firestore/cloud_firestore.dart';

class SellerUserCollection {
  // 'seller_users' என்ற பெயரில் Firestore collection-க்கான reference
  final CollectionReference _sellerCollection = FirebaseFirestore.instance
      .collection('seller_users');

  /// Seller விவரங்களை ஒரு Map ஆகப் பெற்று, UID-ஐ அடிப்படையாகக் கொண்டு
  /// Firestore-இல் புதிய ஆவணமாகச் சேர்க்கும் அல்லது மாற்றியமைக்கும் செயல்பாடு.
  Future<void> addSeller(String uid, Map<String, dynamic> sellerData) async {
    try {
      await _sellerCollection.doc(uid).set(sellerData);
    } catch (e) {
      throw Exception('Failed to add seller to Firestore: $e');
    }
  }

  /// ஒரு குறிப்பிட்ட Seller-இன் விவரங்களைப் பெறுதல்
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
