import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerPayoutHistoryService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerPayoutHistoryService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchPayoutHistory({required int offset, required int limit}) async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      final snapshot = await _firestore
          .collection('payouts')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('date', descending: true)
          .get();

      // Client-side pagination due to simple implementation
      final allPayouts = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Payout',
          'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
          'status': data['status'] ?? 'Unknown',
          'date': (data['date'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        };
      }).toList();

      if (offset >= allPayouts.length) {
        return [];
      }
      final end = (offset + limit) > allPayouts.length ? allPayouts.length : (offset + limit);
      return allPayouts.sublist(offset, end);
    } catch (e) {
      return [];
    }
  }
}
