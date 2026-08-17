import 'package:flutter_bloc/flutter_bloc.dart';
import 'Rating_page_event.dart';
import 'Rating_page_state.dart';
import '../../../core/repositories/i_rating_repository.dart';
import '../../../core/services/i_auth_service.dart';

class RatingPageBloc extends Bloc<RatingPageEvent, RatingPageState> {
  final IRatingRepository _ratingRepository;
  final IAuthService _authService;

  RatingPageBloc({
    required IRatingRepository ratingRepository,
    required IAuthService authService,
  })  : _ratingRepository = ratingRepository,
        _authService = authService,
        super(const RatingInitial()) {
    on<RatingChanged>(_onRatingChanged);
    on<SubmitRating>(_onSubmitRating);
    on<LoadRating>(_onLoadRating);
  }

  Future<void> _onLoadRating(LoadRating event, Emitter<RatingPageState> emit) async {
    final user = _authService.currentUserId;
    if (user == null) return;

    await emit.forEach<double?>(
      _ratingRepository.getUserRatingStream(user, event.foodId),
      onData: (rating) {
        if (rating != null) {
          return RatingLoaded(rating: rating, reviewText: '');
        }
        return const RatingInitial();
      },
      onError: (_, __) => state,
    );
  }

  void _onRatingChanged(RatingChanged event, Emitter<RatingPageState> emit) {
    emit(RatingUpdated(rating: event.rating));
  }

  Future<void> _onSubmitRating(SubmitRating event, Emitter<RatingPageState> emit) async {
    emit(RatingLoading(rating: event.rating));
    
    try {
      if (event.rating == 0) {
        throw Exception("Please provide a valid rating greater than 0.");
      }

      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception("User not logged in.");
      }

      await _ratingRepository.submitRating(
        userId: userId,
        foodId: event.foodId,
        rating: event.rating,
        reviewText: event.reviewText,
        reviewerName: _authService.currentUserDisplayName ?? 'Anonymous User',
        reviewerAvatarUrl: _authService.currentUserPhotoUrl,
      );

      final sellerId = await _ratingRepository.getProductSellerId(event.foodId);
      if (sellerId != null && sellerId.isNotEmpty) {
        await _ratingRepository.addSellerReview(
          sellerId: sellerId,
          productId: event.foodId,
          productName: event.foodName,
          customerId: userId,
          customerName: _authService.currentUserDisplayName ?? 'Anonymous User',
          customerAvatarUrl: _authService.currentUserPhotoUrl ?? '',
          rating: event.rating,
          content: event.reviewText,
        );
      }

      emit(RatingSuccess(rating: event.rating));
    } catch (e) {
      emit(RatingError(
        message: e.toString().replaceAll("Exception: ", ""), 
        rating: event.rating,
      ));
    }
  }
}
