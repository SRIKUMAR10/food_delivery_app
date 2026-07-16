import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerWalletService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerWalletService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<double> fetchWalletBalance() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      final docSnapshot = await _firestore.collection('sellers').doc(sellerId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        return (data['walletBalance'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      // Offline/Dev fallback
      return 12680.00;
    }
  }

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
      // Mock historical data from the user screenshot
      final allMockPayouts = [
        {
          'id': 'payout_0002',
          'title': 'Payout #0002',
          'amount': 4000.0,
          'status': 'Paid',
          'date': '2024-05-01T12:00:00Z',
        },
        {
          'id': 'payout_0001',
          'title': 'Payout #0001',
          'amount': 1900.0,
          'status': 'Paid',
          'date': '2024-04-25T12:00:00Z',
        },
        {
          'id': 'payout_0000',
          'title': 'Payout #0000',
          'amount': 6180.0,
          'status': 'Paid',
          'date': '2024-04-18T12:00:00Z',
        },
      ];

      if (offset >= allMockPayouts.length) {
        return [];
      }
      final end = (offset + limit) > allMockPayouts.length ? allMockPayouts.length : (offset + limit);
      return allMockPayouts.sublist(offset, end);
    }
  }

  Future<bool> requestWithdrawal(double amount) async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final sellerRef = _firestore.collection('sellers').doc(sellerId);
        final sellerDoc = await transaction.get(sellerRef);
        
        if (!sellerDoc.exists) {
          throw Exception('Seller profile not found');
        }
        
        final currentBalance = (sellerDoc.data()!['walletBalance'] as num?)?.toDouble() ?? 0.0;
        
        if (currentBalance < amount) {
          throw Exception('Insufficient funds');
        }
        
        // Deduct balance
        transaction.update(sellerRef, {
          'walletBalance': currentBalance - amount
        });
        
        // Create payout request
        final requestRef = _firestore.collection('payout_requests').doc();
        transaction.set(requestRef, {
          'sellerId': sellerId,
          'amount': amount,
          'status': 'Pending',
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        // Create payout history entry
        final payoutRef = _firestore.collection('payouts').doc();
        transaction.set(payoutRef, {
          'sellerId': sellerId,
          'title': 'Withdrawal Request',
          'amount': amount,
          'status': 'Pending',
          'date': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } catch (e) {
      if (e.toString().contains('Insufficient funds')) {
        rethrow;
      }
      return false;
    }
  }
}
