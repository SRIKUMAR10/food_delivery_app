import 'package:flutter_bloc/flutter_bloc.dart';
import 'overall_rating_page__event.dart';
import 'overall_rating_page__state.dart';

// Service abstracting API calls
abstract class OverallRatingService {
  Future<Map<String, dynamic>> fetchRatingsAndReviews();
}

class MockOverallRatingService implements OverallRatingService {
  @override
  Future<Map<String, dynamic>> fetchRatingsAndReviews() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'overallRating': 4.8,
      'totalReviews': 124,
      'reviews': [
        {
          'id': '1',
          'authorName': 'John Doe',
          'authorAvatarUrl': '',
          'rating': 5.0,
          'content': 'Great quality and fast delivery!',
          'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': '2',
          'authorName': 'Jane Smith',
          'authorAvatarUrl': '',
          'rating': 4.0,
          'content': 'Good products, but delivery was a bit late.',
          'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        },
      ],
    };
  }
}

// Repository abstracting data access
abstract class OverallRatingRepository {
  Future<OverallRatingLoaded> getOverallRatingData();
}

class OverallRatingRepositoryImpl implements OverallRatingRepository {
  final OverallRatingService service;

  OverallRatingRepositoryImpl(this.service);

  @override
  Future<OverallRatingLoaded> getOverallRatingData() async {
    try {
      final data = await service.fetchRatingsAndReviews();
      final List<dynamic> reviewsData = data['reviews'] ?? [];
      
      return OverallRatingLoaded(
        overallRating: (data['overallRating'] ?? 0).toDouble(),
        totalReviews: data['totalReviews'] ?? 0,
        reviews: reviewsData.map((e) => ReviewModel(
          id: e['id'],
          authorName: e['authorName'],
          authorAvatarUrl: e['authorAvatarUrl'],
          rating: (e['rating'] ?? 0).toDouble(),
          content: e['content'],
          date: DateTime.parse(e['date']),
        )).toList(),
      );
    } catch (e) {
      throw Exception('Failed to fetch rating data: $e');
    }
  }
}

class OverallRatingBloc extends Bloc<OverallRatingEvent, OverallRatingState> {
  final OverallRatingRepository repository;

  OverallRatingBloc({required this.repository}) : super(OverallRatingInitial()) {
    on<LoadOverallRatingEvent>(_onLoadOverallRating);
    on<RefreshOverallRatingEvent>(_onRefreshOverallRating);
  }

  Future<void> _onLoadOverallRating(
      LoadOverallRatingEvent event, Emitter<OverallRatingState> emit) async {
    emit(OverallRatingLoading());
    try {
      final data = await repository.getOverallRatingData();
      emit(data);
    } catch (e) {
      emit(OverallRatingError(e.toString()));
    }
  }

  Future<void> _onRefreshOverallRating(
      RefreshOverallRatingEvent event, Emitter<OverallRatingState> emit) async {
    add(LoadOverallRatingEvent());
  }
}
