abstract interface class IRatingRepository {
  Stream<double?> getUserRatingStream(String userId, String foodId);
  Future<void> submitRating({
    required String userId,
    required String foodId,
    required double rating,
    required String reviewText,
    required String reviewerName,
    String? reviewerAvatarUrl,
  });
  Future<void> addSellerReview({
    required String sellerId,
    required String productId,
    required String customerId,
    required String customerName,
    required String customerAvatarUrl,
    required double rating,
    required String content,
    required String productName,
  });
  Future<String?> getProductSellerId(String foodId);
  Stream<List<Map<String, dynamic>>> watchProductReviews(String productId);

  /// Real-time 5★-to-1★ breakdown + aggregate rating for a product.
  Stream<Map<String, dynamic>> watchProductRatingSummary(String productId);

  /// Official seller reply posted on a product-scoped review.
  Future<void> submitSellerReply({
    required String productId,
    required String reviewId,
    required String replyText,
    required String authorName,
  });

  /// Flags an inappropriate product review.
  Future<void> reportReview({
    required String productId,
    required String reviewId,
    required String reason,
    String? details,
    required String reporterId,
  });

  /// Submit customer rating and review for a delivery partner linked to an order.
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
  });

  /// Stream a customer's specific rating for a delivery partner on an order.
  Stream<double?> getPartnerRatingStream({
    required String customerId,
    required String partnerId,
    required String orderId,
  });

  /// Real-time stream of delivery partner reviews.
  Stream<List<Map<String, dynamic>>> watchPartnerReviews(String partnerId);

  /// Real-time 5★-to-1★ breakdown + aggregate rating for a delivery partner.
  Stream<Map<String, dynamic>> watchPartnerRatingSummary(String partnerId);
}

