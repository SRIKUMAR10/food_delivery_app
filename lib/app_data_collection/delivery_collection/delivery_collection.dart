import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryCollection {
  final CollectionReference _collection = FirebaseFirestore.instance
      .collection('delivery_partners');

  Future<void> addDeliveryPartner(String uid, Map<String, dynamic> data) async {
    try {
      await _collection.doc(uid).set(data);
    } catch (e) {
      throw Exception('Failed to add delivery partner to Firestore: $e');
    }
  }

  Future<DocumentSnapshot> getDeliveryPartner(String uid) async {
    try {
      return await _collection.doc(uid).get();
    } catch (e) {
      throw Exception('Failed to get delivery partner from Firestore: $e');
    }
  }

  Future<void> updateDeliveryPartner(String uid, Map<String, dynamic> data) async {
    try {
      await _collection.doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update delivery partner in Firestore: $e');
    }
  }

  Future<void> deleteDeliveryPartner(String uid) async {
    try {
      await _collection.doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete delivery partner from Firestore: $e');
    }
  }

  Stream<QuerySnapshot> getDeliveryPartnersStream() {
    return _collection.snapshots();
  }
}
