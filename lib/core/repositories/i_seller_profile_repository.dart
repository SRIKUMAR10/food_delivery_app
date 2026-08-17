abstract interface class ISellerProfileRepository {
  Future<Map<String, dynamic>> loadProfile(String sellerId);
  Stream<Map<String, dynamic>> watchProfile(String sellerId);
  Future<void> updateProfile(String sellerId, Map<String, dynamic> data);
  Future<String> uploadProfileImage({
    required String sellerId,
    required String fileName,
    required List<int> imageBytes,
  });
  Future<String> uploadCoverImage({
    required String sellerId,
    required String fileName,
    required List<int> imageBytes,
  });
  Future<void> updateOperationalStatus(
    String sellerId, {
    bool? isOpen,
    bool? isAcceptingOrders,
    bool? isOnline,
  });
}

