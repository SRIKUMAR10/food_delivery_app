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
  final String? partnerId;
  final String? partnerName;
  final String? orderId;
  final double? partnerRating;
  final String? partnerReviewText;
  final List<String>? partnerTags;

  const SubmitRating({
    required this.foodId,
    this.foodName = '',
    required this.rating,
    this.reviewText = '',
    this.partnerId,
    this.partnerName,
    this.orderId,
    this.partnerRating,
    this.partnerReviewText,
    this.partnerTags,
  });

  @override
  List<Object?> get props => [
        foodId,
        foodName,
        rating,
        reviewText,
        partnerId,
        partnerName,
        orderId,
        partnerRating,
        partnerReviewText,
        partnerTags,
      ];
}

class SubmitPartnerRatingEvent extends RatingPageEvent {
  final String partnerId;
  final String partnerName;
  final String orderId;
  final double rating;
  final String reviewText;
  final List<String> tags;

  const SubmitPartnerRatingEvent({
    required this.partnerId,
    this.partnerName = '',
    required this.orderId,
    required this.rating,
    this.reviewText = '',
    this.tags = const [],
  });

  @override
  List<Object?> get props => [partnerId, partnerName, orderId, rating, reviewText, tags];
}

