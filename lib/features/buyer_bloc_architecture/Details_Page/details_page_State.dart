import 'package:equatable/equatable.dart';

enum RatingStatus { initial, submitting, success, failure }

class DetailsState extends Equatable {
  final int quantity;
  final double currentRating;
  final RatingStatus ratingStatus;
  final String? ratingMessage;

  const DetailsState({
    this.quantity = 1,
    this.currentRating = 4.5, // Default rating
    this.ratingStatus = RatingStatus.initial,
    this.ratingMessage,
  });

  DetailsState copyWith({
    int? quantity,
    double? currentRating,
    RatingStatus? ratingStatus,
    String? ratingMessage,
  }) {
    return DetailsState(
      quantity: quantity ?? this.quantity,
      currentRating: currentRating ?? this.currentRating,
      ratingStatus: ratingStatus ?? this.ratingStatus,
      ratingMessage: ratingMessage ?? this.ratingMessage,
    );
  }

  @override
  List<Object?> get props => [quantity, currentRating, ratingStatus, ratingMessage];
}
