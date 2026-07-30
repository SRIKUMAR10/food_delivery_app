abstract interface class ISellerProfileRepository {
  Future<Map<String, dynamic>> loadProfile(String sellerId);
  Future<void> updateProfile(String sellerId, Map<String, dynamic> data);
  Future<String> uploadProfileImage({
    required String sellerId,
    required String fileName,
    required List<int> imageBytes,
  });
}
