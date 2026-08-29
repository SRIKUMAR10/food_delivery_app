import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/core/models/seller_pos_printer_model.dart';
import 'package:food_delivery_app/core/models/seller_delivery_surge_model.dart';
import 'package:food_delivery_app/core/models/seller_staff_model.dart';
import 'package:food_delivery_app/core/models/seller_ledger_model.dart';
import 'package:food_delivery_app/core/models/seller_performance_model.dart';

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

  CollectionReference performanceSubCollection(String uid) =>
      _firestore.collection('sellers').doc(uid).collection('performance');

  CollectionReference staffMembersSubCollection(String uid) =>
      _firestore.collection('sellers').doc(uid).collection('staff_members');

  CollectionReference ledgerSubCollection(String uid) =>
      _firestore.collection('sellers').doc(uid).collection('ledger');

  DocumentReference posPrinterDoc(String uid) =>
      settingsSubCollection(uid).doc('pos_printer');

  DocumentReference deliverySurgeDoc(String uid) =>
      settingsSubCollection(uid).doc('delivery_surge');

  DocumentReference performanceSummaryDoc(String uid) =>
      performanceSubCollection(uid).doc('analytics_summary');

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

  // ── Performance & Analytics Subcollection ──
  Stream<SellerPerformanceSummaryModel> watchPerformanceSummary(String uid) {
    return performanceSummaryDoc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return SellerPerformanceSummaryModel.fromMap(
            snapshot.data() as Map<String, dynamic>);
      }
      return const SellerPerformanceSummaryModel();
    });
  }

  Future<SellerPerformanceSummaryModel> getPerformanceSummary(String uid) async {
    try {
      final doc = await performanceSummaryDoc(uid).get();
      if (doc.exists && doc.data() != null) {
        return SellerPerformanceSummaryModel.fromMap(
            doc.data() as Map<String, dynamic>);
      }
      return const SellerPerformanceSummaryModel();
    } catch (e) {
      throw Exception('Failed to get seller performance summary: $e');
    }
  }

  Future<void> updatePerformanceSummary(
      String uid, Map<String, dynamic> data) async {
    try {
      final sanitized = Map<String, dynamic>.from(data);
      sanitized['updatedAt'] = FieldValue.serverTimestamp();
      await performanceSummaryDoc(uid).set(sanitized, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update seller performance summary: $e');
    }
  }

  // ── POS Printer Settings Subcollection ──
  Stream<PosPrinterSettingsModel> watchPosPrinterSettings(String uid) {
    return posPrinterDoc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return PosPrinterSettingsModel.fromMap(
            snapshot.data() as Map<String, dynamic>);
      }
      return const PosPrinterSettingsModel();
    });
  }

  Future<void> updatePosPrinterSettings(
      String uid, Map<String, dynamic> data) async {
    try {
      final sanitized = Map<String, dynamic>.from(data);
      sanitized['updatedAt'] = FieldValue.serverTimestamp();
      await posPrinterDoc(uid).set(sanitized, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update POS printer settings: $e');
    }
  }

  // ── Delivery Surge Settings Subcollection ──
  Stream<DeliverySurgeSettingsModel> watchDeliverySurgeSettings(String uid) {
    return deliverySurgeDoc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return DeliverySurgeSettingsModel.fromMap(
            snapshot.data() as Map<String, dynamic>);
      }
      return const DeliverySurgeSettingsModel();
    });
  }

  Future<void> updateDeliverySurgeSettings(
      String uid, Map<String, dynamic> data) async {
    try {
      final sanitized = Map<String, dynamic>.from(data);
      sanitized['updatedAt'] = FieldValue.serverTimestamp();
      await deliverySurgeDoc(uid).set(sanitized, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update delivery surge settings: $e');
    }
  }

  // ── Staff Members Subcollection ──
  Stream<List<SellerStaffModel>> watchStaffMembers(String uid) {
    return staffMembersSubCollection(uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SellerStaffModel.fromMap(
              doc.data() as Map<String, dynamic>,
              id: doc.id))
          .toList();
    });
  }

  Future<void> addOrUpdateStaffMember(
      String uid, SellerStaffModel staff) async {
    try {
      final docId = staff.staffId.isNotEmpty
          ? staff.staffId
          : staffMembersSubCollection(uid).doc().id;
      await staffMembersSubCollection(uid)
          .doc(docId)
          .set(staff.copyWith(staffId: docId).toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add/update staff member: $e');
    }
  }

  Future<void> deleteStaffMember(String uid, String staffId) async {
    try {
      await staffMembersSubCollection(uid).doc(staffId).delete();
    } catch (e) {
      throw Exception('Failed to delete staff member: $e');
    }
  }

  // ── Financial Ledger Subcollection ──
  Stream<List<SellerLedgerTransactionModel>> watchLedgerTransactions(
      String uid) {
    return ledgerSubCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SellerLedgerTransactionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              id: doc.id))
          .toList();
    });
  }

  Future<void> addLedgerEntry(
      String uid, SellerLedgerTransactionModel entry) async {
    try {
      final docId = entry.transactionId.isNotEmpty
          ? entry.transactionId
          : ledgerSubCollection(uid).doc().id;
      await ledgerSubCollection(uid)
          .doc(docId)
          .set(entry.copyWith(transactionId: docId).toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add ledger entry: $e');
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

      await settingsSubCollection(uid).doc('business_hours').set({
        'isOpen': true,
        'isEmergencyClosed': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await posPrinterDoc(uid).set({
        'isAutoPrintEnabled': true,
        'printerType': 'bluetooth',
        'printerPaperSize': '80mm',
        'printKotCopies': 2,
        'printCustomerReceipt': true,
        'fssaiLicenseOnBill': true,
        'gstNumberOnBill': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await deliverySurgeDoc(uid).set({
        'isSurgeActive': false,
        'surgeReason': 'manual',
        'surgeDeliveryMultiplier': 1.0,
        'extraPrepTimeMinutes': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await performanceSummaryDoc(uid).set({
        'todayRevenue': 0.0,
        'todayOrdersCount': 0,
        'todayCompletedCount': 0,
        'todayCancelledCount': 0,
        'thisWeekRevenue': 0.0,
        'thisMonthRevenue': 0.0,
        'thisYearRevenue': 0.0,
        'averageOrderValue': 0.0,
        'averagePrepTimeMinutes': 20,
        'customerRetentionRate': 0.0,
        'totalReviewsCount': 0,
        'averageStoreRating': 5.0,
        'popularHours': {},
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
      final subcollections = [
        'settings',
        'kyc_documents',
        'performance',
        'staff_members',
        'ledger',
        'menu_preferences',
      ];

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
