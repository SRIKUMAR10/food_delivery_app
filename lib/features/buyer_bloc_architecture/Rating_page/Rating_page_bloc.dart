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
    on<SubmitPartnerRatingEvent>(_onSubmitPartnerRating);
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

      // 1. Submit Product Rating
      await _ratingRepository.submitRating(
        userId: userId,
        foodId: event.foodId,
        rating: event.rating,
        reviewText: event.reviewText,
        reviewerName: _authService.currentUserDisplayName ?? 'Anonymous User',
        reviewerAvatarUrl: _authService.currentUserPhotoUrl,
      );

      // 2. Submit Seller Review
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

      // 3. Submit Delivery Partner Rating if provided
      if (event.partnerId != null && event.partnerId!.isNotEmpty) {
        final pRating = event.partnerRating ?? event.rating;
        final pReview = event.partnerReviewText ?? event.reviewText;
        await _ratingRepository.submitPartnerRating(
          customerId: userId,
          customerName: _authService.currentUserDisplayName ?? 'Anonymous User',
          customerAvatarUrl: _authService.currentUserPhotoUrl,
          partnerId: event.partnerId!,
          partnerName: event.partnerName,
          orderId: event.orderId ?? '',
          rating: pRating,
          reviewText: pReview,
          tags: event.partnerTags,
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

  Future<void> _onSubmitPartnerRating(
    SubmitPartnerRatingEvent event,
    Emitter<RatingPageState> emit,
  ) async {
    emit(RatingLoading(rating: event.rating));

    try {
      if (event.rating == 0) {
        throw Exception("Please provide a valid rating greater than 0.");
      }

      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception("User not logged in.");
      }

      await _ratingRepository.submitPartnerRating(
        customerId: userId,
        customerName: _authService.currentUserDisplayName ?? 'Anonymous User',
        customerAvatarUrl: _authService.currentUserPhotoUrl,
        partnerId: event.partnerId,
        partnerName: event.partnerName,
        orderId: event.orderId,
        rating: event.rating,
        reviewText: event.reviewText,
        tags: event.tags,
      );

      emit(RatingSuccess(rating: event.rating));
    } catch (e) {
      emit(RatingError(
        message: e.toString().replaceAll("Exception: ", ""),
        rating: event.rating,
      ));
    }
  }
}
