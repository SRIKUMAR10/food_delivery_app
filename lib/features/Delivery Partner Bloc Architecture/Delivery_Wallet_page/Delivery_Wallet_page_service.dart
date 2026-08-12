import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Delivery_Wallet_page_state.dart';

abstract class DeliveryWalletPageServiceBase {
  Future<Map<String, dynamic>> fetchWalletData();
  Stream<Map<String, dynamic>> watchWalletData();
  Future<Map<String, dynamic>> withdraw(double amount);
  Future<Map<String, dynamic>> addPaymentMethod(Map<String, dynamic> method);
  Future<List<Map<String, dynamic>>> fetchTransactions(
    DeliveryWalletTransactionFilter filter,
  );
  Stream<List<Map<String, dynamic>>> watchTransactions(
    DeliveryWalletTransactionFilter filter,
  );
}

class DeliveryWalletPageService implements DeliveryWalletPageServiceBase {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DeliveryWalletPageService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Map<String, dynamic>> fetchWalletData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final partnerDoc = await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .get();

        if (partnerDoc.exists) {
          return await _mapWalletData(partnerDoc);
        }
      }
    } catch (_) {}

    return {};
  }

  @override
  Stream<Map<String, dynamic>> watchWalletData() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value({});
    }
    return _firestore
        .collection('delivery_partners')
        .doc(uid)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return <String, dynamic>{};
      return await _mapWalletData(doc);
    });
  }

  Future<Map<String, dynamic>> _mapWalletData(
    DocumentSnapshot<Map<String, dynamic>> partnerDoc,
  ) async {
    final data = partnerDoc.data() ?? {};
    final totalEarnings = (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;

    final pendingQuery = await _firestore
        .collection('delivery_partners')
        .doc(partnerDoc.id)
        .collection('transactions')
        .where('status', isEqualTo: 'pending')
        .get();

    final pendingWithdrawal = pendingQuery.docs.fold<double>(
      0.0,
      (sum, doc) =>
          sum + ((doc.data()['amount'] as num?)?.toDouble() ?? 0.0).abs(),
    );

    return {
      'walletBalance': totalEarnings,
      'pendingWithdrawal': pendingWithdrawal,
      'totalEarnings': totalEarnings,
      'todayEarnings': 0.0,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> withdraw(double amount) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final docRef = _firestore.collection('delivery_partners').doc(uid);
        await _firestore.runTransaction((transaction) async {
          final snap = await transaction.get(docRef);
          if (!snap.exists) throw Exception('Account not found');
          final balance =
              (snap.data()?['totalEarnings'] as num?)?.toDouble() ?? 0.0;
          if (balance < amount) throw Exception('Insufficient balance');

          transaction.update(docRef, {
            'totalEarnings': balance - amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          transaction.set(docRef.collection('transactions').doc(), {
            'type': 'withdrawal',
            'amount': -amount,
            'description': 'Wallet withdrawal',
            'status': 'processing',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
        return {'success': true};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
    return {'success': false, 'error': 'Authentication required to withdraw.'};
  }

  @override
  Future<Map<String, dynamic>> addPaymentMethod(
      Map<String, dynamic> method) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('payment_methods')
            .add({
          ...method,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return {'success': true, 'id': 'pm_added'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
    return {'success': false, 'error': 'Authentication required to add payment method.'};
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTransactions(
    DeliveryWalletTransactionFilter filter,
  ) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final query = _buildTransactionsQuery(uid, filter);
        final snapshot = await query.limit(50).get();
        return snapshot.docs.map(_mapTransactionDoc).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Stream<List<Map<String, dynamic>>> watchTransactions(
    DeliveryWalletTransactionFilter filter,
  ) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }
    return _buildTransactionsQuery(uid, filter)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapTransactionDoc).toList());
  }

  Query<Map<String, dynamic>> _buildTransactionsQuery(
    String uid,
    DeliveryWalletTransactionFilter filter,
  ) {
    var query = _firestore
        .collection('delivery_partners')
        .doc(uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true);

    if (filter != DeliveryWalletTransactionFilter.all) {
      final status = filter == DeliveryWalletTransactionFilter.income
          ? 'delivery_earning'
          : filter == DeliveryWalletTransactionFilter.withdrawals
              ? 'withdrawal'
              : filter == DeliveryWalletTransactionFilter.bonuses
                  ? 'bonus'
                  : null;
      if (status != null) {
        query = query.where('type', isEqualTo: status);
      }
    }
    return query;
  }

  Map<String, dynamic> _mapTransactionDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return {
      'id': doc.id,
      'type': data['type'] ?? 'payment',
      'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
      'description': data['description'] ?? '',
      'status': data['status'] ?? 'completed',
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? '',
    };
  }
}
