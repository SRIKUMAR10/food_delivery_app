import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/services/auth_service.dart';

class DetailsRepository {
  final FirebaseFirestore _firestore;
  final IAuthService _authService;

  DetailsRepository({
    FirebaseFirestore? firestore,
    IAuthService? authService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? FirebaseAuthService();

  bool get isUserLoggedIn => _authService.currentUserId != null;
  String? get currentUserId => _authService.currentUserId;

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
