import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';

class SellerCollection {
  final FirebaseFirestore _firestore;
  final CollectionReference<SellerModel> _sellerCollection;

  SellerCollection({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _sellerCollection = (firestore ?? FirebaseFirestore.instance)
            .collection('sellers')
            .withConverter<SellerModel>(
              fromFirestore: (snapshot, _) => SellerModel.fromFirestore(snapshot),
              toFirestore: (seller, _) => seller.toMap(),
            );

  CollectionReference<SellerModel> get sellerCollection => _sellerCollection;
  DocumentReference<SellerModel> sellerDoc(String uid) => _sellerCollection.doc(uid);

  CollectionReference get payoutRequestsCollection =>
      _firestore.collection('payout_requests');

  CollectionReference get payoutsCollection =>
      _firestore.collection('payouts');

  CollectionReference get inventoryLogsCollection =>
      _firestore.collection('inventory_logs');

  CollectionReference get productsCollection =>
      _firestore.collection('products');

  CollectionReference settingsSubCollection(String uid) =>
      _firestore.collection('sellers').doc(uid).collection('settings');

  CollectionReference kycDocumentsSubCollection(String uid) =>
      _firestore.collection('sellers').doc(uid).collection('kyc_documents');

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
      await _firestore.collection('sellers').doc(uid).set(data, SetOptions(merge: true));
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

  Stream<QuerySnapshot> watchPayoutRequests(String sellerId) {
    return payoutRequestsCollection
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> watchInventoryLogs(String sellerId) {
    return inventoryLogsCollection
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getKycDocument(String uid) async {
    try {
      return await kycDocumentsSubCollection(uid).doc('details').get();
    } catch (e) {
      throw Exception('Failed to get seller KYC document: $e');
    }
  }

  Stream<DocumentSnapshot> watchKycDocument(String uid) {
    return kycDocumentsSubCollection(uid).doc('details').snapshots();
  }

  Future<void> updateKycDocument(String uid, Map<String, dynamic> data) async {
    try {
      final sanitized = Map<String, dynamic>.from(data);
      sanitized['updatedAt'] = FieldValue.serverTimestamp();
      await kycDocumentsSubCollection(uid).doc('details').set(sanitized, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update seller KYC document: $e');
    }
  }

  Future<void> createSellerWithSubCollections(String uid, Map<String, dynamic> sellerData) async {
    try {
      final docRef = _firestore.collection('sellers').doc(uid);
      await docRef.set(sellerData, SetOptions(merge: true));

      // Auto-initialize Seller subcollections under sellers/{uid}/
      await settingsSubCollection(uid).doc('general').set({
        'notificationsEnabled': true,
        'autoAcceptOrders': true,
        'soundEnabled': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await kycDocumentsSubCollection(uid).doc('details').set({
        'sellerId': uid,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create seller with subcollections in Firestore: $e');
    }
  }

  /// Merges a secondary fragmented seller document and subcollections
  /// into the primary canonical UID document in Firestore.
  Future<void> mergeSellerDocuments(String primaryUid, String secondaryUid) async {
    if (primaryUid == secondaryUid || secondaryUid.isEmpty || primaryUid.isEmpty) {
      return;
    }

    try {
      final subcollections = ['settings', 'kyc_documents'];

      for (final subColl in subcollections) {
        final secSubRef = _firestore.collection('sellers').doc(secondaryUid).collection(subColl);
        final priSubRef = _firestore.collection('sellers').doc(primaryUid).collection(subColl);
        final snap = await secSubRef.get();
        for (final doc in snap.docs) {
          await priSubRef.doc(doc.id).set(doc.data(), SetOptions(merge: true));
          await doc.reference.delete();
        }
      }

      final secDoc = await _firestore.collection('sellers').doc(secondaryUid).get();
      if (secDoc.exists) {
        final secData = Map<String, dynamic>.from(secDoc.data() ?? {});
        secData['id'] = primaryUid;
        secData['uid'] = primaryUid;
        secData['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('sellers').doc(primaryUid).set(secData, SetOptions(merge: true));
        await _firestore.collection('sellers').doc(secondaryUid).delete();
      }
    } catch (e) {
      // Safely handle merge errors
    }
  }
}

