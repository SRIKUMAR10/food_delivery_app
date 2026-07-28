import 'package:flutter_bloc/flutter_bloc.dart';
import 'overall_rating_page__event.dart';
import 'overall_rating_page__state.dart';
import '../../../api_service/seller_review_service.dart';

class OverallRatingBloc extends Bloc<OverallRatingEvent, OverallRatingState> {
  final SellerReviewService service;

  OverallRatingBloc({required this.service}) : super(OverallRatingInitial()) {
    on<LoadOverallRatingEvent>(_onLoadOverallRating);
    on<RefreshOverallRatingEvent>(_onRefreshOverallRating);
  }

  Future<void> _onLoadOverallRating(
      LoadOverallRatingEvent event, Emitter<OverallRatingState> emit) async {
    emit(OverallRatingLoading());
    try {
      final data = await service.fetchRatingsAndReviews();
      final reviewsData = data['reviews'] as List<dynamic>? ?? [];

      emit(OverallRatingLoaded(
        overallRating: (data['overallRating'] ?? 0).toDouble(),
        totalReviews: data['totalReviews'] ?? 0,
        reviews: reviewsData.map((e) => ReviewModel(
          id: e['id'] as String? ?? '',
          authorName: e['authorName'] as String? ?? 'Unknown',
          authorAvatarUrl: e['authorAvatarUrl'] as String? ?? '',
          rating: (e['rating'] ?? 0).toDouble(),
          content: e['content'] as String? ?? '',
          date: DateTime.parse(e['date'] as String),
        )).toList(),
      ));
    } catch (e) {
      emit(OverallRatingError(e.toString()));
    }
  }

  Future<void> _onRefreshOverallRating(
      RefreshOverallRatingEvent event, Emitter<OverallRatingState> emit) async {
    add(LoadOverallRatingEvent());
  }
}
