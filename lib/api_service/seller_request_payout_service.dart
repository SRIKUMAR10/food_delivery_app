import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerRequestPayoutService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerRequestPayoutService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<double> fetchAvailableBalance() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      final docSnapshot = await _firestore.collection('sellers').doc(sellerId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return (data['walletBalance'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<List<String>> fetchBankAccounts() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      final docSnapshot = await _firestore.collection('sellers').doc(sellerId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final accounts = data['bankAccounts'] as List<dynamic>?;
        if (accounts != null && accounts.isNotEmpty) {
          return accounts.map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> requestPayout({
    required double amount,
    required String bankAccount,
    required String upiId,
  }) async {
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
          'bankAccount': bankAccount,
          'upiId': upiId,
          'status': 'Pending',
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        // Create payout history entry
        final payoutRef = _firestore.collection('payouts').doc();
        transaction.set(payoutRef, {
          'sellerId': sellerId,
          'title': 'Payout Request',
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
