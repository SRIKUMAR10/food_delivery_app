import 'package:equatable/equatable.dart';

abstract class RatingPageState extends Equatable {
  final double rating;
  const RatingPageState({this.rating = 5.0});

  @override
  List<Object?> get props => [rating];
}

class RatingInitial extends RatingPageState {
  const RatingInitial({super.rating});
}

class RatingLoaded extends RatingPageState {
  final String reviewText;
  
  const RatingLoaded({
    required double rating, 
    this.reviewText = '',
  }) : super(rating: rating);

  @override
  List<Object?> get props => [rating, reviewText];
}

class RatingUpdated extends RatingPageState {
  const RatingUpdated({super.rating});
}

class RatingLoading extends RatingPageState {
  const RatingLoading({super.rating});
}

class RatingSuccess extends RatingPageState {
  const RatingSuccess({super.rating});
}

class RatingError extends RatingPageState {
  final String message;

  const RatingError({required this.message, super.rating});

  @override
  List<Object?> get props => [rating, message];
}
