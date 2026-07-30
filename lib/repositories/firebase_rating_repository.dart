import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/repositories/i_rating_repository.dart';

class FirebaseRatingRepository implements IRatingRepository {
  final FirebaseFirestore firestore;

  FirebaseRatingRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<double?> getUserRatingStream(String userId, String foodId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('ratings')
        .doc(foodId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      return (data['rating'] as num?)?.toDouble();
    });
  }

  @override
  Future<void> submitRating({
    required String userId,
    required String foodId,
    required double rating,
    required String reviewText,
    required String reviewerName,
    String? reviewerAvatarUrl,
  }) async {
    final batch = firestore.batch();

    final ratingsRef = firestore
        .collection('users')
        .doc(userId)
        .collection('ratings')
        .doc(foodId);

    batch.set(ratingsRef, {
      'rating': rating,
      'reviewText': reviewText,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final productReviewsRef = firestore
        .collection('products')
        .doc(foodId)
        .collection('reviews')
        .doc(userId);

    batch.set(productReviewsRef, {
      'reviewerName': reviewerName,
      'customerAvatarUrl': reviewerAvatarUrl ?? '',
      'rating': rating,
      'reviewText': reviewText,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  @override
  Future<void> addSellerReview({
    required String sellerId,
    required String productId,
    required String customerId,
    required String customerName,
    required String customerAvatarUrl,
    required double rating,
    required String content,
  }) async {
    await firestore.collection('reviews').add({
      'sellerId': sellerId,
      'productId': productId,
      'customerId': customerId,
      'customerName': customerName,
      'customerAvatarUrl': customerAvatarUrl,
      'rating': rating,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String?> getProductSellerId(String foodId) async {
    final doc = await firestore.collection('products').doc(foodId).get();
    return doc.data()?['sellerId'] as String?;
  }

  @override
  Stream<List<Map<String, dynamic>>> watchProductReviews(String productId) {
    return firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['reviewerId'] = doc.id;
              return data;
            }).toList());
  }
}
