import 'dart:typed_data';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_models.dart';

abstract interface class IUserProfileRepository {
  Future<UserProfile?> loadProfile(String userId);
  Future<void> saveProfile(String userId, UserProfile profile);
  Future<String> uploadProfileImage({
    required String userId,
    required String fileName,
    required Uint8List imageBytes,
    required String contentType,
  });
  Future<void> updateProfileImageUrl(String userId, String imageUrl);
  Stream<UserProfile?> watchProfile(String userId);
  Stream<String?> watchProfileImageUrl(String userId);
  Stream<List<Map<String, dynamic>>> watchTransactions(String userId);
}
