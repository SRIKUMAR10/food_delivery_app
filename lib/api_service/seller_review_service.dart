import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SellerReviewService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerReviewService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchRatingsAndReviews() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      final reviews = snapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        DateTime date;
        if (createdAt is Timestamp) {
          date = createdAt.toDate();
        } else if (createdAt is String) {
          date = DateTime.tryParse(createdAt) ?? DateTime.now();
        } else {
          date = DateTime.now();
        }

        return <String, dynamic>{
          'id': doc.id,
          'authorName': data['customerName'] as String? ?? 'Unknown',
          'authorAvatarUrl': data['customerAvatarUrl'] as String? ?? '',
          'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
          'content': data['content'] as String? ?? '',
          'date': date.toIso8601String(),
        };
      }).toList();

      double overallRating = 0;
      if (reviews.isNotEmpty) {
        final sum = reviews.fold<double>(
            0, (total, r) => total + (r['rating'] as double));
        overallRating = (sum / reviews.length);
        overallRating = double.parse(overallRating.toStringAsFixed(1));
      }

      return {
        'overallRating': overallRating,
        'totalReviews': reviews.length,
        'reviews': reviews,
      };
    } catch (e) {
      throw Exception('Failed to fetch ratings: $e');
    }
  }
}
