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
        .collection('buyer_user')
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
        .collection('buyer_user')
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
    required String productName,
  }) async {
    // The seller notification + aggregate rating recalculation is delegated to
    // the `onReviewCreated` Cloud Function to keep a single authoritative path.
    await firestore.collection('reviews').add({
      'sellerId': sellerId,
      'productId': productId,
      'productName': productName,
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
        .map((snapshot) => snapshot.docs
            .map((doc) => _normalizeProductReview(doc.id, doc.data()))
            .toList());
  }

  @override
  Stream<Map<String, dynamic>> watchProductRatingSummary(String productId) {
    return firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .snapshots()
        .map((snapshot) {
      final ratings = snapshot.docs
          .map((doc) => _toDouble(doc.data()['rating']))
          .toList();

      var five = 0;
      var four = 0;
      var three = 0;
      var two = 0;
      var one = 0;
      for (final rating in ratings) {
        final star = rating.round().clamp(1, 5);
        switch (star) {
          case 5:
            five++;
            break;
          case 4:
            four++;
            break;
          case 3:
            three++;
            break;
          case 2:
            two++;
            break;
          case 1:
            one++;
            break;
        }
      }

      final total = ratings.length;
      final overall = total == 0
          ? 0.0
          : double.parse(
              (ratings.fold<double>(0, (a, b) => a + b) / total).toStringAsFixed(1));

      return {
        'overallRating': overall,
        'totalReviews': total,
        'fiveStar': five,
        'fourStar': four,
        'threeStar': three,
        'twoStar': two,
        'oneStar': one,
      };
    });
  }

  @override
  Future<void> submitSellerReply({
    required String productId,
    required String reviewId,
    required String replyText,
    required String authorName,
  }) async {
    await firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .doc(reviewId)
        .set({
      'sellerReply': replyText,
      'sellerRepliedAt': FieldValue.serverTimestamp(),
      'sellerReplyAuthor': authorName,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> reportReview({
    required String productId,
    required String reviewId,
    required String reason,
    String? details,
    required String reporterId,
  }) async {
    final batch = firestore.batch();

    batch.set(firestore.collection('review_reports').doc(), {
      'reviewId': reviewId,
      'productId': productId,
      'reason': reason,
      'details': details ?? '',
      'reporterId': reporterId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(
        firestore
            .collection('products')
            .doc(productId)
            .collection('reviews')
            .doc(reviewId),
        {
          'isReported': true,
          'reportReason': reason,
          'reportStatus': 'pending',
          'reportedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));

    await batch.commit();
  }

  Map<String, dynamic> _normalizeProductReview(
      String id, Map<String, dynamic> data) {
    final timestamp = data['timestamp'] ?? data['createdAt'];
    return <String, dynamic>{
      ...data,
      'reviewerId': id,
      'createdAt': _toIsoString(timestamp),
      'sellerReply': data['sellerReply'],
      'sellerRepliedAt': _toIsoString(data['sellerRepliedAt']),
      'sellerReplyAuthor': data['sellerReplyAuthor'],
      'isReported': data['isReported'] ?? false,
      'reportReason': data['reportReason'],
      'reportStatus': data['reportStatus'],
      'reportedAt': _toIsoString(data['reportedAt']),
    };
  }

  String? _toIsoString(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    if (value is String) return value;
    return null;
  }

  double _toDouble(dynamic value) => (value as num?)?.toDouble() ?? 0.0;
}
