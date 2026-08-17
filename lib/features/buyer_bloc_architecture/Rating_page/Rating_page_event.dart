import 'package:equatable/equatable.dart';

abstract class RatingPageEvent extends Equatable {
  const RatingPageEvent();

  @override
  List<Object?> get props => [];
}

class RatingChanged extends RatingPageEvent {
  final double rating;

  const RatingChanged(this.rating);

  @override
  List<Object?> get props => [rating];
}

class LoadRating extends RatingPageEvent {
  final String foodId;

  const LoadRating({required this.foodId});

  @override
  List<Object?> get props => [foodId];
}

class SubmitRating extends RatingPageEvent {
  final String foodId;
  final String foodName;
  final double rating;
  final String reviewText;

  const SubmitRating({
    required this.foodId,
    this.foodName = '',
    required this.rating,
    this.reviewText = '',
  });

  @override
  List<Object?> get props => [foodId, foodName, rating, reviewText];
}
