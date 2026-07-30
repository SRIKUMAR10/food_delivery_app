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
  });
  Future<String?> getProductSellerId(String foodId);
  Stream<List<Map<String, dynamic>>> watchProductReviews(String productId);
}

