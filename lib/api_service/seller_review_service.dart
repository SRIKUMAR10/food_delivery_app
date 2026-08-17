import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerReviewService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerReviewService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Real-time reactive stream of the seller's reviews + aggregated ratings.
  /// Emits a fresh snapshot on every review create/update/delete.
  Stream<Map<String, dynamic>> watchRatingsAndReviews({String? sellerId}) {
    final effectiveSellerId = sellerId ?? _auth.currentUser?.uid;
    if (effectiveSellerId == null || effectiveSellerId.isEmpty) {
      return Stream.error(Exception('User not logged in'));
    }

    return _firestore
        .collection('reviews')
        .where('sellerId', isEqualTo: effectiveSellerId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs.map(_mapReview).toList()
        ..sort(_sortReviewsDesc);
      return _aggregate(reviews);
    });
  }

  /// One-shot fetch (backwards compatible with older callers).
  Future<Map<String, dynamic>> fetchRatingsAndReviews() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _firestore
            .collection('reviews')
            .where('sellerId', isEqualTo: sellerId)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (_) {
        snapshot = await _firestore
            .collection('reviews')
            .where('sellerId', isEqualTo: sellerId)
            .get();
      }

      final reviews = snapshot.docs.map(_mapReview).toList()
        ..sort(_sortReviewsDesc);
      return _aggregate(reviews);
    } catch (e) {
      throw Exception('Failed to fetch ratings: $e');
    }
  }

  /// Posts (or edits) the official seller reply on a review and notifies the
  /// customer in real time. Does NOT expose any review-deletion capability.
  Future<void> submitSellerReply({
    required String reviewId,
    required String replyText,
    required String authorName,
    required String customerId,
    String? productName,
  }) async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    final resolvedAuthor =
        authorName.isNotEmpty ? authorName : await _resolveSellerName(sellerId);

    final reviewRef = _firestore.collection('reviews').doc(reviewId);
    final reviewSnap = await reviewRef.get();
    final reviewData = reviewSnap.data();
    final productId =
        (reviewData?['productId'] as String?)?.trim().isNotEmpty == true
            ? reviewData!['productId'] as String
            : '';

    final batch = _firestore.batch();
    batch.update(reviewRef, {
      'sellerReply': replyText,
      'sellerRepliedAt': FieldValue.serverTimestamp(),
      'sellerReplyAuthor': resolvedAuthor,
    });

    // Mirror the reply onto the product-scoped review so the buyer's
    // product review list reflects the store response in real time.
    if (productId.isNotEmpty && customerId.isNotEmpty) {
      final productReviewRef = _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc(customerId);
      batch.set(productReviewRef, {
        'sellerReply': replyText,
        'sellerRepliedAt': FieldValue.serverTimestamp(),
        'sellerReplyAuthor': resolvedAuthor,
      }, SetOptions(merge: true));
    }

    await batch.commit();

    await _notifyCustomer(
      customerId: customerId,
      title: 'Restaurant Replied to Your Review',
      titleTa: 'உங்கள் மதிப்பாய்வுக்கு உணவகம் பதிலளித்துள்ளது',
      body: 'Your review on ${productName ?? 'your order'} received a reply from the restaurant.',
      bodyTa: '${productName ?? 'உங்கள் ஆர்டர்'} குறித்த உங்கள் மதிப்பாய்வுக்கு உணவகத்திலிருந்து பதில் வந்துள்ளது.',
      type: 'review_reply',
      reviewId: reviewId,
      productName: productName,
    );
  }

  /// Flags an inappropriate review, creating a `review_reports` record and
  /// marking the review as reported (pending moderation).
  Future<void> reportInappropriateReview({
    required String reviewId,
    required String reason,
    String? details,
    String reporterId = '',
    String sellerId = '',
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    final effectiveReporter = reporterId.isNotEmpty ? reporterId : uid;

    var effectiveSeller = sellerId;
    if (effectiveSeller.isEmpty) {
      final reviewSnap =
          await _firestore.collection('reviews').doc(reviewId).get();
      effectiveSeller = reviewSnap.data()?['sellerId'] as String? ?? '';
    }

    final batch = _firestore.batch();

    batch.set(_firestore.collection('review_reports').doc(), {
      'reviewId': reviewId,
      'reason': reason,
      'details': details ?? '',
      'reporterId': effectiveReporter,
      'sellerId': effectiveSeller,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('reviews').doc(reviewId), {
      'isReported': true,
      'reportReason': reason,
      'reportDetails': details ?? '',
      'reportStatus': 'pending',
      'reportedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Map<String, dynamic> _mapReview(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final createdAt = data['createdAt'];
    final date = _parseDate(createdAt) ?? DateTime.now();

    return <String, dynamic>{
      'id': doc.id,
      'authorName': data['customerName'] as String? ?? 'Unknown',
      'authorAvatarUrl': data['customerAvatarUrl'] as String? ?? '',
      'rating': _toDouble(data['rating']),
      'content': data['content'] as String? ?? '',
      'date': date.toIso8601String(),
      'sellerId': data['sellerId'] as String? ?? '',
      'productId': data['productId'] as String? ?? '',
      'productName': data['productName'] as String? ?? '',
      'customerId': data['customerId'] as String? ?? '',
      'sellerReply': data['sellerReply'] as String?,
      'sellerRepliedAt': _parseDate(data['sellerRepliedAt'])?.toIso8601String(),
      'sellerReplyAuthor': data['sellerReplyAuthor'] as String?,
      'isReported': data['isReported'] as bool? ?? false,
      'reportReason': data['reportReason'] as String?,
      'reportDetails': data['reportDetails'] as String?,
      'reportStatus': data['reportStatus'] as String?,
      'reportedAt': _parseDate(data['reportedAt'])?.toIso8601String(),
    };
  }

  int _sortReviewsDesc(Map<String, dynamic> a, Map<String, dynamic> b) {
    final dateA = DateTime.tryParse(a['date'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final dateB = DateTime.tryParse(b['date'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return dateB.compareTo(dateA);
  }

  Map<String, dynamic> _aggregate(List<Map<String, dynamic>> reviews) {
    double overallRating = 0;
    if (reviews.isNotEmpty) {
      final sum =
          reviews.fold<double>(0, (total, r) => total + _toDouble(r['rating']));
      overallRating = double.parse((sum / reviews.length).toStringAsFixed(1));
    }

    return {
      'overallRating': overallRating,
      'totalReviews': reviews.length,
      'reviews': reviews,
    };
  }

  Future<String> _resolveSellerName(String sellerId) async {
    try {
      final snap = await _firestore.collection('sellers').doc(sellerId).get();
      final data = snap.data();
      final name = data?['storeName'] ??
          data?['name'] ??
          data?['displayName'] ??
          data?['restaurantName'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
    } catch (_) {}
    return 'Restaurant';
  }

  Future<void> _notifyCustomer({
    required String customerId,
    required String title,
    required String titleTa,
    required String body,
    required String bodyTa,
    required String type,
    String? reviewId,
    String? productName,
  }) async {
    if (customerId.isEmpty) return;
    await _firestore
        .collection('buyer_user')
        .doc(customerId)
        .collection('notifications')
        .add({
      'title': title,
      'titleTa': titleTa,
      'body': body,
      'bodyTa': bodyTa,
      'type': type,
      'reviewId': reviewId ?? '',
      'productName': productName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  double _toDouble(dynamic value) => (value as num?)?.toDouble() ?? 0.0;

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }
}
