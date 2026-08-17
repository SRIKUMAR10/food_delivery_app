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
      'createdAt': FieldValue.serverTimestamp(),
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
      'createdAt': FieldValue.serverTimestamp(),
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
    if (productId.trim().isEmpty) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
    return firestore
        .collection('products')
        .doc(productId.trim())
        .collection('reviews')
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => _normalizeProductReview(doc.id, doc.data()))
          .toList();
      reviews.sort((a, b) {
        final aTime = _parseDateTime(a['createdAt'] ?? a['timestamp']);
        final bTime = _parseDateTime(b['createdAt'] ?? b['timestamp']);
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
      return reviews;
    }).handleError((_) {
      return <Map<String, dynamic>>[];
    });
  }

  @override
  Stream<Map<String, dynamic>> watchProductRatingSummary(String productId) {
    if (productId.trim().isEmpty) {
      return Stream.value({
        'overallRating': 0.0,
        'totalReviews': 0,
        'fiveStar': 0,
        'fourStar': 0,
        'threeStar': 0,
        'twoStar': 0,
        'oneStar': 0,
      });
    }
    return firestore
        .collection('products')
        .doc(productId.trim())
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
    }).handleError((_) {
      return {
        'overallRating': 0.0,
        'totalReviews': 0,
        'fiveStar': 0,
        'fourStar': 0,
        'threeStar': 0,
        'twoStar': 0,
        'oneStar': 0,
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

  @override
  Future<void> submitPartnerRating({
    required String customerId,
    required String customerName,
    String? customerAvatarUrl,
    required String partnerId,
    String? partnerName,
    required String orderId,
    required double rating,
    required String reviewText,
    List<String>? tags,
  }) async {
    final clampedRating = rating.clamp(1.0, 5.0);
    final batch = firestore.batch();

    // 1. Store under buyer's delivery rating history
    final buyerRatingRef = firestore
        .collection('buyer_user')
        .doc(customerId)
        .collection('partner_ratings')
        .doc(orderId.isNotEmpty ? orderId : partnerId);

    batch.set(buyerRatingRef, {
      'partnerId': partnerId,
      'partnerName': partnerName ?? '',
      'orderId': orderId,
      'rating': clampedRating,
      'reviewText': reviewText,
      'tags': tags ?? [],
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Store in delivery_partners/{partnerId}/reviews subcollection
    final reviewDocId = orderId.isNotEmpty ? orderId : firestore.collection('temp').doc().id;
    final partnerReviewRef = firestore
        .collection('delivery_partners')
        .doc(partnerId)
        .collection('reviews')
        .doc(reviewDocId);

    batch.set(partnerReviewRef, {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'customerAvatarUrl': customerAvatarUrl ?? '',
      'partnerId': partnerId,
      'partnerName': partnerName ?? '',
      'rating': clampedRating,
      'reviewText': reviewText,
      'content': reviewText,
      'tags': tags ?? [],
      'createdAt': FieldValue.serverTimestamp(),
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();

    // 3. Recalculate average rating & summary for delivery partner
    try {
      final reviewsSnap = await firestore
          .collection('delivery_partners')
          .doc(partnerId)
          .collection('reviews')
          .get();

      if (reviewsSnap.docs.isNotEmpty) {
        double sum = 0;
        int five = 0, four = 0, three = 0, two = 0, one = 0;

        for (final doc in reviewsSnap.docs) {
          final r = (doc.data()['rating'] as num?)?.toDouble() ?? 5.0;
          sum += r;
          final star = r.round().clamp(1, 5);
          if (star == 5) five++;
          else if (star == 4) four++;
          else if (star == 3) three++;
          else if (star == 2) two++;
          else one++;
        }

        final count = reviewsSnap.docs.length;
        final avg = double.parse((sum / count).toStringAsFixed(1));

        await firestore.collection('delivery_partners').doc(partnerId).set({
          'rating': avg,
          'averageRating': avg,
          'totalReviews': count,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await firestore
            .collection('delivery_partners')
            .doc(partnerId)
            .collection('ratings')
            .doc('summary')
            .set({
          'rating': avg,
          'totalReviews': count,
          '5starCount': five,
          '4starCount': four,
          '3starCount': three,
          '2starCount': two,
          '1starCount': one,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  @override
  Stream<double?> getPartnerRatingStream({
    required String customerId,
    required String partnerId,
    required String orderId,
  }) {
    final docKey = orderId.isNotEmpty ? orderId : partnerId;
    return firestore
        .collection('buyer_user')
        .doc(customerId)
        .collection('partner_ratings')
        .doc(docKey)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      return (data['rating'] as num?)?.toDouble();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchPartnerReviews(String partnerId) {
    if (partnerId.trim().isEmpty) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
    return firestore
        .collection('delivery_partners')
        .doc(partnerId.trim())
        .collection('reviews')
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => _normalizePartnerReview(doc.id, doc.data()))
          .toList();
      reviews.sort((a, b) {
        final aTime = _parseDateTime(a['createdAt'] ?? a['timestamp']);
        final bTime = _parseDateTime(b['createdAt'] ?? b['timestamp']);
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
      return reviews;
    }).handleError((_) {
      return <Map<String, dynamic>>[];
    });
  }

  @override
  Stream<Map<String, dynamic>> watchPartnerRatingSummary(String partnerId) {
    if (partnerId.trim().isEmpty) {
      return Stream.value({
        'overallRating': 5.0,
        'totalReviews': 0,
        'fiveStar': 0,
        'fourStar': 0,
        'threeStar': 0,
        'twoStar': 0,
        'oneStar': 0,
      });
    }
    return firestore
        .collection('delivery_partners')
        .doc(partnerId.trim())
        .collection('reviews')
        .snapshots()
        .map((snapshot) {
      final ratings = snapshot.docs
          .map((doc) => _toDouble(doc.data()['rating']))
          .toList();

      var five = 0, four = 0, three = 0, two = 0, one = 0;
      for (final rating in ratings) {
        final star = rating.round().clamp(1, 5);
        switch (star) {
          case 5: five++; break;
          case 4: four++; break;
          case 3: three++; break;
          case 2: two++; break;
          case 1: one++; break;
        }
      }

      final total = ratings.length;
      final overall = total == 0
          ? 5.0
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
    }).handleError((_) {
      return {
        'overallRating': 5.0,
        'totalReviews': 0,
        'fiveStar': 0,
        'fourStar': 0,
        'threeStar': 0,
        'twoStar': 0,
        'oneStar': 0,
      };
    });
  }

  Map<String, dynamic> _normalizePartnerReview(
      String id, Map<String, dynamic> data) {
    final timestamp = data['createdAt'] ?? data['timestamp'];
    return <String, dynamic>{
      ...data,
      'reviewId': id,
      'createdAt': _toIsoString(timestamp),
      'rating': (data['rating'] as num?)?.toDouble() ?? 5.0,
      'reviewText': data['reviewText'] ?? data['content'] ?? '',
      'customerName': data['customerName'] ?? 'Customer',
      'orderId': data['orderId'] ?? '',
      'tags': (data['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    };
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

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
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

