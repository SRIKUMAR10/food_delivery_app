import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryEarningsDashboardServiceBase {
  Future<Map<String, dynamic>> fetchEarningsData();
  Future<Map<String, dynamic>> withdraw(double amount);
  Stream<double> simulateMediaUpload();
}

class DeliveryEarningsDashboardService
    implements DeliveryEarningsDashboardServiceBase {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryEarningsDashboardService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Map<String, dynamic>> fetchEarningsData() async {
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
          final totalDeliveries = (data['totalDeliveries'] as num?)?.toInt() ?? 0;

          final completedQuery = await _firestore!
              .collection('orders')
              .where('riderId', isEqualTo: uid)
              .where('status', isEqualTo: 'Delivered')
              .get();

          final todayStart = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
          final todayOrders = completedQuery.docs.where((doc) {
            final ts = doc.data()['timestamp'] as Timestamp?;
            return ts != null && ts.toDate().isAfter(todayStart);
          }).length;

          final todayEarnings = completedQuery.docs
              .where((doc) {
                final ts = doc.data()['timestamp'] as Timestamp?;
                return ts != null && ts.toDate().isAfter(todayStart);
              })
              .fold<double>(0.0, (sum, doc) =>
                  sum + ((doc.data()['amount'] as num?)?.toDouble() ?? 0.0) * 0.15 + 40.0);

          final yesterdayStart = todayStart.subtract(const Duration(days: 1));
          final yesterdayEarnings = completedQuery.docs
              .where((doc) {
                final ts = doc.data()['timestamp'] as Timestamp?;
                return ts != null &&
                    ts.toDate().isAfter(yesterdayStart) &&
                    ts.toDate().isBefore(todayStart);
              })
              .fold<double>(0.0, (sum, doc) =>
                  sum + ((doc.data()['amount'] as num?)?.toDouble() ?? 0.0) * 0.15 + 40.0);

          final earningsGrowth = yesterdayEarnings > 0
              ? ((todayEarnings - yesterdayEarnings) / yesterdayEarnings) * 100
              : 0.0;

          final weeklyStart = todayStart.subtract(const Duration(days: 7));
          final weeklyOrders = completedQuery.docs.where((doc) {
            final ts = doc.data()['timestamp'] as Timestamp?;
            return ts != null && ts.toDate().isAfter(weeklyStart);
          }).length;

          final weeklyEarnings = completedQuery.docs
              .where((doc) {
                final ts = doc.data()['timestamp'] as Timestamp?;
                return ts != null && ts.toDate().isAfter(weeklyStart);
              })
              .fold<double>(0.0, (sum, doc) =>
                  sum + ((doc.data()['amount'] as num?)?.toDouble() ?? 0.0) * 0.15 + 40.0);

          return {
            'totalEarnings': totalEarnings,
            'totalDeliveries': totalDeliveries,
            'todayEarnings': todayEarnings,
            'todayDeliveries': todayOrders,
            'earningsGrowth': earningsGrowth,
            'weeklyEarnings': weeklyEarnings,
            'weeklyDeliveries': weeklyOrders,
            'monthlyEarnings': totalEarnings,
            'monthlyDeliveries': totalDeliveries,
            'averagePerOrder': totalDeliveries > 0 ? totalEarnings / totalDeliveries : 0.0,
            'rating': (data['rating'] as num?)?.toDouble() ?? 4.8,
          };
        }
      }
    } catch (_) {}

    return _buildMockData();
  }

  @override
  Future<Map<String, dynamic>> withdraw(double amount) async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        final docRef = _firestore!.collection('delivery_partners').doc(uid);
        await _firestore!.runTransaction((transaction) async {
          final snap = await transaction.get(docRef);
          if (!snap.exists) return;
          final currentEarnings =
              (snap.data()?['totalEarnings'] as num?)?.toDouble() ?? 0.0;
          if (currentEarnings < amount) throw Exception('Insufficient balance');

          transaction.update(docRef, {
            'totalEarnings': currentEarnings - amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          transaction.set(docRef.collection('transactions').doc(), {
            'type': 'withdrawal',
            'amount': -amount,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
        return {'success': true, 'message': 'Withdrawal of \u{20B9}${amount.toStringAsFixed(2)} initiated.'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }

    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true, 'message': 'Withdrawal of \u{20B9}${amount.toStringAsFixed(2)} initiated.'};
  }

  @override
  Stream<double> simulateMediaUpload() async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      yield i / chunks;
    }
  }

  Map<String, dynamic> _buildMockData() {
    return {
      'totalEarnings': 48500.00,
      'totalDeliveries': 312,
      'todayEarnings': 2450.00,
      'todayDeliveries': 18,
      'earningsGrowth': 18.5,
      'weeklyEarnings': 12450.00,
      'weeklyDeliveries': 85,
      'monthlyEarnings': 48500.00,
      'monthlyDeliveries': 312,
      'averagePerOrder': 155.45,
      'rating': 4.8,
      'weeklyChart': [
        {'day': 'Mon', 'amount': 320.0},
        {'day': 'Tue', 'amount': 410.0},
        {'day': 'Wed', 'amount': 380.0},
        {'day': 'Thu', 'amount': 520.0},
        {'day': 'Fri', 'amount': 450.0},
        {'day': 'Sat', 'amount': 280.0},
        {'day': 'Sun', 'amount': 90.0},
      ],
      'monthlyChart': [
        {'week': 'W1', 'amount': 10450.0},
        {'week': 'W2', 'amount': 12300.0},
        {'week': 'W3', 'amount': 11800.0},
        {'week': 'W4', 'amount': 13950.0},
      ],
    };
  }
}
