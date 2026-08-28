import 'package:cloud_firestore/cloud_firestore.dart';

class UserCollection {
  final CollectionReference _buyerUserCollection = FirebaseFirestore.instance
      .collection('buyer_user');

  /// Primary getter for buyer_user collection
  CollectionReference get buyerUserCollection => _buyerUserCollection;
  DocumentReference userDoc(String uid) => _buyerUserCollection.doc(uid);

  CollectionReference cartSubCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('cart');

  CollectionReference ordersSubCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('orders');

  CollectionReference ratingsSubCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('ratings');

  CollectionReference favoritesSubCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('favorites');

  CollectionReference addressesSubCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('addresses');

  CollectionReference transactionsSubCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('transactions');

  CollectionReference notificationsSubCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('notifications');

  CollectionReference supportTicketsSubCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('support_tickets');

  Future<void> createBuyerUser(String uid, Map<String, dynamic> userData) async {
    try {
      final docRef = _buyerUserCollection.doc(uid);
      await docRef.set(userData, SetOptions(merge: true));

      // Auto-initialize 8 buyer sub-collections under buyer_user/{uid}/
      await docRef.collection('cart').doc('summary').set({
        'itemCount': 0,
        'totalAmount': 0.0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('orders').doc('summary').set({
        'totalOrders': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('ratings').doc('summary').set({
        'rating': 5.0,
        'totalReviews': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('favorites').doc('summary').set({
        'favoriteCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('addresses').doc('default').set({
        'isDefault': true,
        'addressType': 'Home',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('transactions').doc('initial').set({
        'type': 'account_creation',
        'amount': 0.0,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('notifications').doc('summary').set({
        'unreadCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await docRef.collection('support_tickets').doc('summary').set({
        'openTickets': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create buyer user with subcollections in Firestore: $e');
    }
  }

  Future<void> addUser(String uid, Map<String, dynamic> userData) async {
    try {
      await createBuyerUser(uid, userData);
    } catch (e) {
      throw Exception('Failed to add user to buyer_user collection in Firestore: $e');
    }
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    try {
      return await _buyerUserCollection.doc(uid).get();
    } catch (e) {
      throw Exception('Failed to get user from buyer_user collection in Firestore: $e');
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    try {
      final docRef = _buyerUserCollection.doc(uid);
      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        final initialData = <String, dynamic>{
          'uid': uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          ...userData,
        };
        await createBuyerUser(uid, initialData);
      } else {
        await docRef.set(userData, SetOptions(merge: true));
      }
    } catch (e) {
      if (e.toString().contains('not-found') ||
          e.toString().contains('No document to update')) {
        try {
          final initialData = <String, dynamic>{
            'uid': uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            ...userData,
          };
          await createBuyerUser(uid, initialData);
          return;
        } catch (fallbackErr) {
          throw Exception(
              'Failed to update user in buyer_user collection in Firestore: $fallbackErr');
        }
      }
      throw Exception('Failed to update user in buyer_user collection in Firestore: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _buyerUserCollection.doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user from buyer_user collection in Firestore: $e');
    }
  }

  Stream<QuerySnapshot> getUsersStream() {
    return _buyerUserCollection.snapshots();
  }

  /// Checks if a mobile number exists specifically inside the buyer_user collection in Firestore
  Future<bool> isPhoneInBuyerCollection(String mobileNumber) async {
    try {
      final digitsOnly = mobileNumber.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.isEmpty) return false;

      final formattedPhone = '+91 $digitsOnly';
      final rawWithPrefix = '+91$digitsOnly';

      // Query by phone field matching any of the common formats
      final querySnapshot = await _buyerUserCollection
          .where('phone', whereIn: [mobileNumber.trim(), formattedPhone, rawWithPrefix, digitsOnly])
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      // If index or Firestore query fails, fallback safely
      return false;
    }
  }

  // ── Subcollection Helpers ───────────────────────────────────────────────

  /// Ratings subcollection: buyer_user/{uid}/ratings
  CollectionReference ratingsCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('ratings');

  /// Transactions subcollection: buyer_user/{uid}/transactions
  CollectionReference transactionsCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('transactions');

  /// Favorites subcollection: buyer_user/{uid}/favorites
  CollectionReference favoritesCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('favorites');

  /// Cart subcollection: buyer_user/{uid}/cart
  CollectionReference cartCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('cart');

  /// Orders subcollection: buyer_user/{uid}/orders
  CollectionReference ordersCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('orders');

  /// Addresses subcollection: buyer_user/{uid}/addresses
  CollectionReference addressesCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('addresses');

  /// Support tickets subcollection: buyer_user/{uid}/support_tickets
  CollectionReference supportTicketsCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('support_tickets');

  /// Feedback subcollection: buyer_user/{uid}/feedback
  CollectionReference feedbackCollection(String uid) =>
      _buyerUserCollection.doc(uid).collection('feedback');

  /// Merges a secondary fragmented buyer user document and all 8 subcollections
  /// into the primary canonical UID document in Firestore.
  Future<void> mergeBuyerDocuments(String primaryUid, String secondaryUid) async {
    if (primaryUid == secondaryUid || secondaryUid.isEmpty || primaryUid.isEmpty) {
      return;
    }

    try {
      final subcollections = [
        'cart',
        'orders',
        'ratings',
        'favorites',
        'addresses',
        'transactions',
        'notifications',
        'support_tickets',
        'feedback',
      ];

      for (final subColl in subcollections) {
        final secSubRef = _buyerUserCollection.doc(secondaryUid).collection(subColl);
        final priSubRef = _buyerUserCollection.doc(primaryUid).collection(subColl);
        final snap = await secSubRef.get();
        for (final doc in snap.docs) {
          await priSubRef.doc(doc.id).set(doc.data() as Map<String, dynamic>, SetOptions(merge: true));
          await doc.reference.delete();
        }
      }

      final secDoc = await _buyerUserCollection.doc(secondaryUid).get();
      if (secDoc.exists) {
        final secData = Map<String, dynamic>.from(secDoc.data() as Map? ?? {});
        secData['uid'] = primaryUid;
        secData['updatedAt'] = FieldValue.serverTimestamp();
        await _buyerUserCollection.doc(primaryUid).set(secData, SetOptions(merge: true));
        await _buyerUserCollection.doc(secondaryUid).delete();
      }
    } catch (e) {
      // Safely handle merge errors
    }
  }
}

