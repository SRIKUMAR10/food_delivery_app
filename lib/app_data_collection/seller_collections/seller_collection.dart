import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';

class SellerCollection {
  final CollectionReference<SellerModel> _sellerCollection = FirebaseFirestore.instance
      .collection('sellers')
      .withConverter<SellerModel>(
        fromFirestore: (snapshot, _) => SellerModel.fromFirestore(snapshot),
        toFirestore: (seller, _) => seller.toMap(),
      );

  Future<void> addSeller(SellerModel seller) async {
    try {
      await _sellerCollection.doc(seller.id).set(seller);
    } catch (e) {
      throw Exception('Failed to add seller to Firestore: $e');
    }
  }

  Future<SellerModel?> getSeller(String uid) async {
    try {
      DocumentSnapshot<SellerModel> doc = await _sellerCollection.doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get seller from Firestore: $e');
    }
  }

  Future<void> updateSeller(String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('sellers').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update seller in Firestore: $e');
    }
  }

  Future<void> deleteSeller(String uid) async {
    try {
      await _sellerCollection.doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete seller from Firestore: $e');
    }
  }

  Stream<QuerySnapshot<SellerModel>> getSellersStream() {
    return _sellerCollection.snapshots();
  }
}
