import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

abstract class DeliveryEarningsDashboardServiceBase {
  Future<Map<String, dynamic>> fetchEarningsData();
  Stream<Map<String, dynamic>> watchEarningsData();
  Future<Map<String, dynamic>> withdraw(double amount);
  Future<Map<String, dynamic>> submitCash({
    required double amount,
    required String method,
  });
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
      final fs = _firestore;
      if (uid != null && fs != null) {
        final partnerDoc = await fs
            .collection('delivery_partners')
            .doc(uid)
            .get();

        if (partnerDoc.exists) {
          final q1Docs = await fs
              .collection('orders')
              .where('riderId', isEqualTo: uid)
              .where('status', isEqualTo: 'Delivered')
              .get()
              .then((q) => q.docs)
              .catchError((_) => <QueryDocumentSnapshot<Map<String, dynamic>>>[]);

          final q2Docs = await fs
              .collection('orders')
              .where('deliveryPartnerId', isEqualTo: uid)
              .where('status', isEqualTo: 'Delivered')
              .get()
              .then((q) => q.docs)
              .catchError((_) => <QueryDocumentSnapshot<Map<String, dynamic>>>[]);

          final docMap = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
          for (final doc in q1Docs) {
            docMap[doc.id] = doc;
          }
          for (final doc in q2Docs) {
            docMap[doc.id] = doc;
          }

          return _mapEarningsData(partnerDoc, docMap.values.toList());
        }
      }
    } catch (_) {}

    return {};
  }

  @override
  Stream<Map<String, dynamic>> watchEarningsData() {
    final uid = _auth?.currentUser?.uid;
    final fs = _firestore;
    if (uid == null || fs == null) {
      return Stream.value({});
    }
    final partnerStream = fs
        .collection('delivery_partners')
        .doc(uid)
        .snapshots();

    final riderOrdersStream = fs
        .collection('orders')
        .where('riderId', isEqualTo: uid)
        .where('status', isEqualTo: 'Delivered')
        .snapshots();

    final partnerOrdersStream = fs
        .collection('orders')
        .where('deliveryPartnerId', isEqualTo: uid)
        .where('status', isEqualTo: 'Delivered')
        .snapshots();

    return Rx.combineLatest3<
        DocumentSnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>,
        Map<String, dynamic>>(
      partnerStream,
      riderOrdersStream,
      partnerOrdersStream,
      (partnerDoc, q1, q2) {
        final docMap = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
        for (final doc in q1.docs) {
          docMap[doc.id] = doc;
        }
        for (final doc in q2.docs) {
          docMap[doc.id] = doc;
        }
        return _mapEarningsData(partnerDoc, docMap.values.toList());
      },
    );
  }

  double _orderEarnings(Map<String, dynamic> data) {
    final deliveryFee = (data['deliveryFee'] as num?)?.toDouble();
    if (deliveryFee != null && deliveryFee > 0) return deliveryFee;
    final deliveryCharge = (data['deliveryCharge'] as num?)?.toDouble();
    if (deliveryCharge != null && deliveryCharge > 0) return deliveryCharge;
    return (data['amount'] as num?)?.toDouble() ?? 0.0;
  }

  Map<String, dynamic> _orderBreakdown(Map<String, dynamic> data) {
    final orderEarnings = _orderEarnings(data);
    double? _num(String key) => (data[key] as num?)?.toDouble();

    final baseFare = _num('baseFare');
    final distanceFare = _num('distanceFare');
    final surgeFare = _num('surgeFare');
    final incentive = _num('incentiveAmount') ?? _num('incentive');
    final bonus = _num('bonusAmount') ?? _num('bonus');
    final tips = _num('tipsAmount') ?? _num('tipAmount') ?? _num('tips');
    final cancellation = _num('cancellationCompensation');

    final hasBreakdown =
        baseFare != null ||
        distanceFare != null ||
        surgeFare != null ||
        incentive != null ||
        bonus != null ||
        tips != null ||
        cancellation != null;

    final resolvedBase = hasBreakdown ? (baseFare ?? 0.0) : orderEarnings;
    final resolvedTotal = _num('totalPartnerEarnings') ??
        (hasBreakdown
            ? resolvedBase +
                (distanceFare ?? 0.0) +
                (surgeFare ?? 0.0) +
                (incentive ?? 0.0) +
                (bonus ?? 0.0) +
                (tips ?? 0.0) +
                (cancellation ?? 0.0)
            : orderEarnings);

    return {
      'baseFare': resolvedBase,
      'distanceFare': distanceFare ?? 0.0,
      'surgeFare': surgeFare ?? 0.0,
      'incentive': incentive ?? 0.0,
      'bonus': bonus ?? 0.0,
      'tips': tips ?? 0.0,
      'cancellationCompensation': cancellation ?? 0.0,
      'totalEarnings': resolvedTotal,
    };
  }

  Map<String, dynamic> _mapEarningsData(
    DocumentSnapshot<Map<String, dynamic>> partnerDoc,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> completedDocs,
  ) {
    final data = partnerDoc.exists ? partnerDoc.data() ?? {} : {};
    final totalEarnings = (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
    final totalDeliveries = (data['totalDeliveries'] as num?)?.toInt() ?? 0;

    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final todayOrders = completedDocs.where((doc) {
      final ts = doc.data()['timestamp'] as Timestamp?;
      return ts != null && ts.toDate().isAfter(todayStart);
    }).length;

    final todayEarnings = completedDocs
        .where((doc) {
          final ts = doc.data()['timestamp'] as Timestamp?;
          return ts != null && ts.toDate().isAfter(todayStart);
        })
        .fold<double>(0.0, (sum, doc) => sum + _orderEarnings(doc.data()));

    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final yesterdayEarnings = completedDocs
        .where((doc) {
          final ts = doc.data()['timestamp'] as Timestamp?;
          return ts != null &&
              ts.toDate().isAfter(yesterdayStart) &&
              ts.toDate().isBefore(todayStart);
        })
        .fold<double>(0.0, (sum, doc) => sum + _orderEarnings(doc.data()));

    final earningsGrowth = yesterdayEarnings > 0
        ? ((todayEarnings - yesterdayEarnings) / yesterdayEarnings) * 100
        : 0.0;

    final weeklyStart = todayStart.subtract(const Duration(days: 7));
    final weeklyOrders = completedDocs.where((doc) {
      final ts = doc.data()['timestamp'] as Timestamp?;
      return ts != null && ts.toDate().isAfter(weeklyStart);
    }).length;

    final weeklyEarnings = completedDocs
        .where((doc) {
          final ts = doc.data()['timestamp'] as Timestamp?;
          return ts != null && ts.toDate().isAfter(weeklyStart);
        })
        .fold<double>(0.0, (sum, doc) => sum + _orderEarnings(doc.data()));

    final monthStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      1,
    );
    final monthOrders = completedDocs.where((doc) {
      final ts = doc.data()['timestamp'] as Timestamp?;
      return ts != null && ts.toDate().isAfter(monthStart);
    }).length;

    final monthEarnings = completedDocs
        .where((doc) {
          final ts = doc.data()['timestamp'] as Timestamp?;
          return ts != null && ts.toDate().isAfter(monthStart);
        })
        .fold<double>(0.0, (sum, doc) => sum + _orderEarnings(doc.data()));

    final sortedDocs = [...completedDocs]..sort((a, b) {
        final ta = (a.data()['timestamp'] as Timestamp?)?.toDate();
        final tb = (b.data()['timestamp'] as Timestamp?)?.toDate();
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });

    final detailedEarnings = sortedDocs.take(100).map((doc) {
      final docData = doc.data();
      final breakdown = _orderBreakdown(docData);
      final orderTimestamp = (docData['timestamp'] as Timestamp?)?.toDate();
      return {
        'orderId': doc.id,
        'customerName': docData['customerName'] ?? '',
        'timestamp': (orderTimestamp ?? DateTime.now()).toIso8601String(),
        'paymentMethod': docData['paymentMethod'] ?? '',
        'isCOD': (docData['paymentMethod'] as String? ?? '').toUpperCase() == 'COD',
        ...breakdown,
      };
    }).toList();

    return {
      'totalEarnings': totalEarnings,
      'totalDeliveries': totalDeliveries,
      'todayEarnings': todayEarnings,
      'todayDeliveries': todayOrders,
      'earningsGrowth': earningsGrowth,
      'weeklyEarnings': weeklyEarnings,
      'weeklyDeliveries': weeklyOrders,
      'monthlyEarnings': monthEarnings,
      'monthlyDeliveries': monthOrders,
      'averagePerOrder': totalDeliveries > 0 ? totalEarnings / totalDeliveries : 0.0,
      'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
      'pendingEarnings': (data['pendingEarnings'] as num?)?.toDouble() ?? 0.0,
      'cashInHand': (data['cashInHand'] as num?)?.toDouble() ?? 0.0,
      'cashCollected': (data['cashCollected'] as num?)?.toDouble() ?? 0.0,
      'cashSubmitted': (data['cashSubmitted'] as num?)?.toDouble() ?? 0.0,
      'reconciliationStatus': data['reconciliationStatus'] ?? 'balanced',
      'detailedEarnings': detailedEarnings,
    };
  }

  @override
  Future<Map<String, dynamic>> withdraw(double amount) async {
    try {
      final uid = _auth?.currentUser?.uid;
      final fs = _firestore;
      if (uid != null && fs != null) {
        final docRef = fs.collection('delivery_partners').doc(uid);
        await fs.runTransaction((transaction) async {
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

    return {'success': false, 'message': 'Authentication required to withdraw.'};
  }

  @override
  Future<Map<String, dynamic>> submitCash({
    required double amount,
    required String method,
  }) async {
    try {
      final uid = _auth?.currentUser?.uid;
      final fs = _firestore;
      if (uid != null && fs != null) {
        final docRef = fs.collection('delivery_partners').doc(uid);
        return await fs.runTransaction((transaction) async {
          final snap = await transaction.get(docRef);
          if (!snap.exists) throw Exception('Account not found');
          final currentCashInHand =
              (snap.data()?['cashInHand'] as num?)?.toDouble() ?? 0.0;
          final currentCashSubmitted =
              (snap.data()?['cashSubmitted'] as num?)?.toDouble() ?? 0.0;
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
            'method': method,
            'amount': amount,
            'description': 'Cash submitted via $method',
            'status': 'submitted',
            'createdAt': FieldValue.serverTimestamp(),
          });

          return {
            'success': true,
            'cashInHand': remaining,
            'cashSubmitted': newSubmitted,
            'reconciliationStatus': status,
            'message':
                'Cash of \u{20B9}${amount.toStringAsFixed(2)} submitted via $method.',
          };
        });
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }

    return {'success': false, 'message': 'Authentication required to submit cash.'};
  }

  @override
  Stream<double> simulateMediaUpload() async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      yield i / chunks;
    }
  }
}
