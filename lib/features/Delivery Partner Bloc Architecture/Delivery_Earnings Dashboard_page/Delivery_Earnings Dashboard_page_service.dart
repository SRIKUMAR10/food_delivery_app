import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

abstract class DeliveryEarningsDashboardServiceBase {
  Future<Map<String, dynamic>> fetchEarningsData();
  Stream<Map<String, dynamic>> watchEarningsData();
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
      'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
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
  Stream<double> simulateMediaUpload() async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      yield i / chunks;
    }
  }
}
