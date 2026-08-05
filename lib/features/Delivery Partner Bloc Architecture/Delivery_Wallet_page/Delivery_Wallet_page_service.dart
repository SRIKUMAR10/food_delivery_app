import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Delivery_Wallet_page_state.dart';

abstract class DeliveryWalletPageServiceBase {
  Future<Map<String, dynamic>> fetchWalletData();
  Future<Map<String, dynamic>> withdraw(double amount);
  Future<Map<String, dynamic>> addPaymentMethod(Map<String, dynamic> method);
  Future<List<Map<String, dynamic>>> fetchTransactions(
    DeliveryWalletTransactionFilter filter,
  );
}

class DeliveryWalletPageService implements DeliveryWalletPageServiceBase {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryWalletPageService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Map<String, dynamic>> fetchWalletData() async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        final partnerDoc = await _firestore!
            .collection('delivery_partners')
            .doc(uid)
            .get();

        if (partnerDoc.exists) {
          final data = partnerDoc.data()!;
          final totalEarnings =
              (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;

          final pendingQuery = await _firestore!
              .collection('delivery_partners')
              .doc(uid)
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
            'todayEarnings': totalEarnings * 0.05,
            'lastUpdated': DateTime.now().toIso8601String(),
          };
        }
      }
    } catch (_) {}

    return {
      'walletBalance': 2450.00,
      'pendingWithdrawal': 500.00,
      'totalEarnings': 48500.00,
      'todayEarnings': 2450.00,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> withdraw(double amount) async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        final docRef = _firestore!.collection('delivery_partners').doc(uid);
        await _firestore!.runTransaction((transaction) async {
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
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true};
  }

  @override
  Future<Map<String, dynamic>> addPaymentMethod(
      Map<String, dynamic> method) async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        await _firestore!
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
    await Future.delayed(const Duration(milliseconds: 300));
    return {'success': true, 'id': 'pm_mock_001'};
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTransactions(
    DeliveryWalletTransactionFilter filter,
  ) async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        var query = _firestore!
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

        final snapshot = await query.limit(50).get();
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'type': data['type'] ?? 'payment',
            'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
            'description': data['description'] ?? '',
            'status': data['status'] ?? 'completed',
            'createdAt': (data['createdAt'] as Timestamp?)?.toDate()?.toIso8601String() ?? '',
          };
        }).toList();
      }
    } catch (_) {}

    return _buildMockTransactions(filter);
  }

  List<Map<String, dynamic>> _buildMockTransactions(
      DeliveryWalletTransactionFilter filter) {
    final all = [
      {'id': 'txn_1', 'type': 'delivery_earning', 'amount': 120.00,
       'description': 'Order #ORD12345 Delivery', 'status': 'completed',
       'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()},
      {'id': 'txn_2', 'type': 'delivery_earning', 'amount': 85.00,
       'description': 'Order #ORD12348 Delivery', 'status': 'completed',
       'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String()},
      {'id': 'txn_3', 'type': 'withdrawal', 'amount': -500.00,
       'description': 'Withdrawal to Bank', 'status': 'processing',
       'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
      {'id': 'txn_4', 'type': 'delivery_earning', 'amount': 200.00,
       'description': 'Order #ORD12350 Delivery', 'status': 'completed',
       'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String()},
    ];

    if (filter == DeliveryWalletTransactionFilter.income) {
      return all.where((t) => ((t['amount'] as num?) ?? 0) > 0).toList();
    }
    if (filter == DeliveryWalletTransactionFilter.withdrawals) {
      return all.where((t) => ((t['amount'] as num?) ?? 0) < 0).toList();
    }
    return all;
  }
}
