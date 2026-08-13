import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryCollection {
  final CollectionReference _collection;

  DeliveryCollection({FirebaseFirestore? firestore})
      : _collection = (firestore ?? FirebaseFirestore.instance)
            .collection('delivery_partners');

  DocumentReference partnerDoc(String uid) => _collection.doc(uid);

  CollectionReference ridersSubCollection(String uid) =>
      _collection.doc(uid).collection('riders');

  CollectionReference earningsSubCollection(String uid) =>
      _collection.doc(uid).collection('earnings');

  CollectionReference incentivesSubCollection(String uid) =>
      _collection.doc(uid).collection('incentives');

  CollectionReference transactionsSubCollection(String uid) =>
      _collection.doc(uid).collection('transactions');

  CollectionReference ratingsSubCollection(String uid) =>
      _collection.doc(uid).collection('ratings');

  CollectionReference kycDocumentsSubCollection(String uid) =>
      _collection.doc(uid).collection('kyc_documents');

  CollectionReference notificationsSubCollection(String uid) =>
      _collection.doc(uid).collection('notifications');

  CollectionReference ordersSubCollection(String uid) =>
      _collection.doc(uid).collection('orders');

  Future<void> createDeliveryPartner(
      String uid, Map<String, dynamic> data) async {
    try {
      final docRef = _collection.doc(uid);
      await docRef.set(data);

      // Initialize sub-collections under delivery_partners/{uid}/
      await docRef.collection('riders').doc('info').set({
        'name': data['displayName'] ?? '',
        'phone': data['phoneNumber'] ?? '',
        'imageUrl': data['photoUrl'] ?? '',
        'rating': data['rating'] ?? 5.0,
        'isOnline': data['isOnline'] ?? false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('earnings').doc('summary').set({
        'totalEarnings': data['totalEarnings'] ?? 0.0,
        'totalDeliveries': data['totalDeliveries'] ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('incentives').doc('summary').set({
        'todayBonus': 0.0,
        'weeklyBonus': 0.0,
        'targetProgress': 0.0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('transactions').doc('initial').set({
        'type': 'account_creation',
        'amount': 0.0,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('ratings').doc('summary').set({
        'rating': data['rating'] ?? 5.0,
        'totalReviews': 0,
        '5starCount': 0,
        '4starCount': 0,
        '3starCount': 0,
        '2starCount': 0,
        '1starCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('kyc_documents').doc('details').set({
        'kycStatus': data['kycStatus'] ?? 'approved',
        'vehicleType': data['vehicleType'] ?? 'Motorcycle',
        'vehicleNumber': data['vehicleNumber'] ?? '',
        'drivingLicense': data['drivingLicense'] ?? '',
        'aadhaarNumber': data['aadhaarNumber'] ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('notifications').doc('summary').set({
        'unreadCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('orders').doc('summary').set({
        'totalOrders': data['totalDeliveries'] ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create delivery partner in Firestore: $e');
    }
  }

  Future<void> addDeliveryPartner(
      String uid, Map<String, dynamic> data) async {
    try {
      await createDeliveryPartner(uid, data);
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

  Future<DocumentSnapshot?> getDeliveryPartnerByPhone(String phone) async {
    try {
      final cleaned = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
      final withPrefix = cleaned.startsWith('+') ? cleaned : '+91$cleaned';
      final withoutPrefix = cleaned.startsWith('+91')
          ? cleaned.substring(3)
          : (cleaned.startsWith('+') ? cleaned.substring(1) : cleaned);

      final searchNumbers = <String>{
        withPrefix,
        withoutPrefix,
        cleaned,
        phone.trim(),
      };

      for (final pNum in searchNumbers) {
        if (pNum.isEmpty) continue;
        final query =
            await _collection.where('phoneNumber', isEqualTo: pNum).limit(1).get();
        if (query.docs.isNotEmpty) {
          return query.docs.first;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to query delivery partner by phone: $e');
    }
  }

  Future<DocumentSnapshot?> getDeliveryPartnerByEmail(String email) async {
    try {
      final trimmed = email.trim();
      if (trimmed.isEmpty) return null;
      final query =
          await _collection.where('email', isEqualTo: trimmed).limit(1).get();
      if (query.docs.isNotEmpty) {
        return query.docs.first;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to query delivery partner by email: $e');
    }
  }

  Future<void> updateDeliveryPartner(
      String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      final docRef = _collection.doc(uid);
      await docRef.set(data, SetOptions(merge: true));

      // Sync rider sub-collection info
      final Map<String, dynamic> riderUpdates = {};
      if (data.containsKey('displayName')) riderUpdates['name'] = data['displayName'];
      if (data.containsKey('phoneNumber')) riderUpdates['phone'] = data['phoneNumber'];
      if (data.containsKey('photoUrl')) riderUpdates['imageUrl'] = data['photoUrl'];
      if (data.containsKey('rating')) riderUpdates['rating'] = data['rating'];
      if (data.containsKey('isOnline')) riderUpdates['isOnline'] = data['isOnline'];
      if (riderUpdates.isNotEmpty) {
        riderUpdates['updatedAt'] = FieldValue.serverTimestamp();
        await docRef.collection('riders').doc('info').set(riderUpdates, SetOptions(merge: true));
      }

      // Sync earnings sub-collection summary
      final Map<String, dynamic> earningsUpdates = {};
      if (data.containsKey('totalEarnings')) earningsUpdates['totalEarnings'] = data['totalEarnings'];
      if (data.containsKey('totalDeliveries')) earningsUpdates['totalDeliveries'] = data['totalDeliveries'];
      if (earningsUpdates.isNotEmpty) {
        earningsUpdates['updatedAt'] = FieldValue.serverTimestamp();
        await docRef.collection('earnings').doc('summary').set(earningsUpdates, SetOptions(merge: true));
      }

      // Sync ratings sub-collection summary
      if (data.containsKey('rating')) {
        await docRef.collection('ratings').doc('summary').set({
          'rating': data['rating'],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Sync kyc_documents sub-collection details
      final Map<String, dynamic> kycUpdates = {};
      if (data.containsKey('kycStatus')) kycUpdates['kycStatus'] = data['kycStatus'];
      if (data.containsKey('vehicleType')) kycUpdates['vehicleType'] = data['vehicleType'];
      if (data.containsKey('vehicleNumber')) kycUpdates['vehicleNumber'] = data['vehicleNumber'];
      if (data.containsKey('drivingLicense')) kycUpdates['drivingLicense'] = data['drivingLicense'];
      if (data.containsKey('aadhaarNumber')) kycUpdates['aadhaarNumber'] = data['aadhaarNumber'];
      if (kycUpdates.isNotEmpty) {
        kycUpdates['updatedAt'] = FieldValue.serverTimestamp();
        await docRef.collection('kyc_documents').doc('details').set(kycUpdates, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to update delivery partner in Firestore: $e');
    }
  }

  Future<void> updatePassword(String uid, String newPassword) async {
    try {
      await _collection.doc(uid).set({
        'password': newPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update password in Firestore: $e');
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

