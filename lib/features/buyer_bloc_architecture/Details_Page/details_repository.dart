import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/repositories/i_rating_repository.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../repositories/firebase_rating_repository.dart';

class DetailsRepository {
  final IRatingRepository _ratingRepository;
  final IAuthService _authService;

  DetailsRepository({
    IRatingRepository? ratingRepository,
    FirebaseFirestore? firestore,
    IAuthService? authService,
  })  : _ratingRepository =
            ratingRepository ?? FirebaseRatingRepository(firestore: firestore),
        _authService = authService ?? FirebaseAuthService();

  bool get isUserLoggedIn => _authService.currentUserId != null;
  String? get currentUserId => _authService.currentUserId;

  Stream<double> getUserRatingStream(String userId, String foodId) {
    return _ratingRepository
        .getUserRatingStream(userId, foodId)
        .map((rating) => rating ?? 0.0);
  }

  Future<void> submitRating(String userId, String foodId, double rating) async {
    if (foodId.trim().isEmpty || userId.trim().isEmpty) return;
    await _ratingRepository.submitRating(
      userId: userId,
      foodId: foodId,
      rating: rating,
      reviewText: '',
      reviewerName: '',
    );
  }

  Stream<double> getAverageProductRatingStream(String foodId) {
    if (foodId.trim().isEmpty) return Stream.value(0.0);
    return _ratingRepository
        .watchProductRatingSummary(foodId)
        .map((summary) => (summary['overallRating'] as num?)?.toDouble() ?? 0.0);
  }
}