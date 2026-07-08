import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final double rating;
  final String content;
  final DateTime date;

  const ReviewModel({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.rating,
    required this.content,
    required this.date,
  });

  @override
  List<Object?> get props => [id, authorName, authorAvatarUrl, rating, content, date];
}

abstract class OverallRatingState extends Equatable {
  const OverallRatingState();
  
  @override
  List<Object> get props => [];
}

class OverallRatingInitial extends OverallRatingState {}

class OverallRatingLoading extends OverallRatingState {}

class OverallRatingLoaded extends OverallRatingState {
  final double overallRating;
  final int totalReviews;
  final List<ReviewModel> reviews;

  const OverallRatingLoaded({
    required this.overallRating,
    required this.totalReviews,
    required this.reviews,
  });

  @override
  List<Object> get props => [overallRating, totalReviews, reviews];
}

class OverallRatingError extends OverallRatingState {
  final String message;

  const OverallRatingError(this.message);

  @override
  List<Object> get props => [message];
}
