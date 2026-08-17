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
}
