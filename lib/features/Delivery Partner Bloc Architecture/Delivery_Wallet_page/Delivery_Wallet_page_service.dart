import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Delivery_Wallet_page_state.dart';

abstract class DeliveryWalletPageServiceBase {
  Future<Map<String, dynamic>> fetchWalletData();
  Stream<Map<String, dynamic>> watchWalletData();
  Future<Map<String, dynamic>> withdraw(double amount);
  Future<Map<String, dynamic>> submitCash({
    required double amount,
    required String method,
  });
  Future<List<Map<String, dynamic>>> fetchReconciliationHistory();
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
    final walletBalance = (data['walletBalance'] as num?)?.toDouble() ??
        (data['totalEarnings'] as num?)?.toDouble() ??
        0.0;
    final totalEarnings = (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
    final bonusEarnings = (data['bonusEarnings'] as num?)?.toDouble() ?? 0.0;
    final incentiveEarnings =
        (data['incentiveEarnings'] as num?)?.toDouble() ?? 0.0;
    final codAdjustment = (data['codAdjustment'] as num?)?.toDouble() ?? 0.0;
    final cashCollected = (data['cashCollected'] as num?)?.toDouble() ?? 0.0;
    final cashInHand = (data['cashInHand'] as num?)?.toDouble() ?? 0.0;
    final cashSubmitted = (data['cashSubmitted'] as num?)?.toDouble() ?? 0.0;
    final availableBalance = (data['availableBalance'] as num?)?.toDouble() ??
        (walletBalance > 100.0 ? walletBalance - 100.0 : 0.0);
    final withdrawableAmount =
        (data['withdrawableAmount'] as num?)?.toDouble() ?? availableBalance;

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
      'walletBalance': walletBalance,
      'availableBalance': availableBalance,
      'pendingBalance': pendingWithdrawal,
      'pendingWithdrawal': pendingWithdrawal,
      'withdrawableAmount': withdrawableAmount,
      'codAdjustment': codAdjustment,
      'cashCollected': cashCollected,
      'cashInHand': cashInHand,
      'cashSubmitted': cashSubmitted,
      'reconciliationStatus': data['reconciliationStatus'] ?? 'balanced',
      'totalEarnings': totalEarnings,
      'bonusEarnings': bonusEarnings,
      'incentiveEarnings': incentiveEarnings,
      'todayEarnings': (data['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      'totalWithdrawn': (data['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
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
          final data = snap.data() ?? {};
          final balance = (data['walletBalance'] as num?)?.toDouble() ??
              (data['totalEarnings'] as num?)?.toDouble() ??
              0.0;
          if (balance < amount) throw Exception('Insufficient balance');

          final newBalance = balance - amount;
          final newAvailable = (newBalance > 100.0) ? newBalance - 100.0 : 0.0;
          final totalWithdrawn =
              ((data['totalWithdrawn'] as num?)?.toDouble() ?? 0.0) + amount;

          transaction.update(docRef, {
            'walletBalance': newBalance,
            'availableBalance': newAvailable,
            'withdrawableAmount': newAvailable,
            'totalWithdrawn': totalWithdrawn,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          transaction.set(docRef.collection('transactions').doc(), {
            'type': 'withdrawal',
            'amount': -amount,
            'title': 'Wallet Withdrawal',
            'description': 'Withdrawal to registered bank account',
            'status': 'processing',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
        return {
          'success': true,
          'walletBalance': 0.0,
          'transaction': {
            'id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
            'type': 'withdrawal',
            'title': 'Wallet Withdrawal',
            'amount': -amount,
            'status': 'processing',
            'date': DateTime.now().toIso8601String(),
          }
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
    return {'success': false, 'error': 'Authentication required to withdraw.'};
  }

  @override
  Future<Map<String, dynamic>> submitCash({
    required double amount,
    required String method,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final docRef = _firestore.collection('delivery_partners').doc(uid);
        return await _firestore.runTransaction((transaction) async {
          final snap = await transaction.get(docRef);
          if (!snap.exists) throw Exception('Account not found');
          final data = snap.data() ?? {};
          final currentCashInHand =
              (data['cashInHand'] as num?)?.toDouble() ?? 0.0;
          final currentCashSubmitted =
              (data['cashSubmitted'] as num?)?.toDouble() ?? 0.0;
          if (amount > currentCashInHand) {
            throw Exception('Amount exceeds cash in hand');
          }

          final remaining = currentCashInHand - amount;
          final newSubmitted = currentCashSubmitted + amount;
          final status =
              remaining <= 0 ? 'balanced' : 'pending_submission';

          transaction.update(docRef, {
            'cashInHand': remaining,
            'cashSubmitted': newSubmitted,
            'reconciliationStatus': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          transaction.set(docRef.collection('transactions').doc(), {
            'type': 'cash_submission',
            'amount': amount,
            'title': 'COD Cash Deposit',
            'description': 'COD deposit via $method',
            'status': 'submitted',
            'method': method,
            'createdAt': FieldValue.serverTimestamp(),
          });
          transaction.set(docRef.collection('reconciliations').doc(), {
            'type': 'cash_submission',
            'amount': amount,
            'method': method,
            'status': status,
            'createdAt': FieldValue.serverTimestamp(),
          });

          return {
            'success': true,
            'cashInHand': remaining,
            'cashSubmitted': newSubmitted,
            'reconciliationStatus': status,
            'amount': amount,
            'method': method,
          };
        });
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
    return {'success': false, 'error': 'Authentication required.'};
  }

  @override
  Future<List<Map<String, dynamic>>> fetchReconciliationHistory() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final snap = await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('reconciliations')
            .orderBy('createdAt', descending: true)
            .limit(30)
            .get();
        return snap.docs.map((d) {
          final data = d.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now();
          return {
            'id': d.id,
            'method': data['method'] ?? '',
            'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
            'status': data['status'] ?? 'submitted',
            'date': createdAt.toIso8601String(),
            'description': data['description'] ?? '',
          };
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<Map<String, dynamic>> addPaymentMethod(
      Map<String, dynamic> method) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final docRef = await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('payment_methods')
            .add({
          ...method,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return {'success': true, 'id': docRef.id, ...method};
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
      final typeString = switch (filter) {
        DeliveryWalletTransactionFilter.income => 'delivery_earning',
        DeliveryWalletTransactionFilter.withdrawals => 'withdrawal',
        DeliveryWalletTransactionFilter.bonuses => 'bonus',
        DeliveryWalletTransactionFilter.incentives => 'incentive',
        DeliveryWalletTransactionFilter.penalties => 'penalty',
        DeliveryWalletTransactionFilter.adjustments => 'cod_adjustment',
        _ => null,
      };
      if (typeString != null) {
        query = query.where('type', isEqualTo: typeString);
      }
    }
    return query;
  }

  Map<String, dynamic> _mapTransactionDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final createdAtDate = (data['createdAt'] as Timestamp?)?.toDate() ??
        (data['date'] is String ? DateTime.tryParse(data['date']) : null) ??
        DateTime.now();
    return {
      'id': data['id'] ?? doc.id,
      'type': data['type'] ?? 'delivery_earning',
      'title': data['title'] ?? data['description'] ?? 'Delivery Transaction',
      'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
      'description': data['description'] ?? data['title'] ?? '',
      'status': data['status'] ?? 'completed',
      'orderId': data['orderId'],
      'date': createdAtDate.toIso8601String(),
      'createdAt': createdAtDate.toIso8601String(),
    };
  }
}
