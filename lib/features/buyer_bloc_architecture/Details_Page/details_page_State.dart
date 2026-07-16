import 'package:equatable/equatable.dart';

enum RatingStatus { initial, submitting, success, failure }

class DetailsState extends Equatable {
  final int quantity;
  final double currentRating;
  final double averageRating;
  final RatingStatus ratingStatus;
  final String? ratingMessage;

  const DetailsState({
    this.quantity = 1,
    this.currentRating = 4.5, // Default rating
    this.averageRating = 0.0,
    this.ratingStatus = RatingStatus.initial,
    this.ratingMessage,
  });

  DetailsState copyWith({
    int? quantity,
    double? currentRating,
    double? averageRating,
    RatingStatus? ratingStatus,
    String? ratingMessage,
  }) {
    return DetailsState(
      quantity: quantity ?? this.quantity,
      currentRating: currentRating ?? this.currentRating,
      averageRating: averageRating ?? this.averageRating,
      ratingStatus: ratingStatus ?? this.ratingStatus,
      ratingMessage: ratingMessage ?? this.ratingMessage,
    );
  }

  @override
  List<Object?> get props => [quantity, currentRating, averageRating, ratingStatus, ratingMessage];
}
