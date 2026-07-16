import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DetailsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  bool get isUserLoggedIn => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<double> getUserRatingStream(String userId, String foodId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('ratings')
        .doc(foodId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return (data['rating'] as num?)?.toDouble() ?? 4.5;
      }
      return 4.5;
    });
  }

  Future<void> submitRating(String userId, String foodId, double rating) async {
    final cartDocRef = _firestore
        .collection('orders')
        .doc(userId)
        .collection('transactions')
        .doc(foodId)
        .collection('cart')
        .doc(userId);

    await cartDocRef.set(
      {
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<double> getAverageProductRatingStream(String foodId) {
    return _firestore
        .collection('products')
        .doc(foodId)
        .collection('reviews')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        total += (data['rating'] as num?)?.toDouble() ?? 0.0;
      }
      return total / snapshot.docs.length;
    });
  }
}
