import 'package:equatable/equatable.dart';

abstract class OverallRatingEvent extends Equatable {
  const OverallRatingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOverallRatingEvent extends OverallRatingEvent {
  final String? sellerId;

  const LoadOverallRatingEvent([this.sellerId]);

  @override
  List<Object?> get props => [sellerId];
}

class RefreshOverallRatingEvent extends OverallRatingEvent {
  final String? sellerId;

  const RefreshOverallRatingEvent([this.sellerId]);

  @override
  List<Object?> get props => [sellerId];
}

class OverallRatingSnapshotUpdated extends OverallRatingEvent {
  final Map<String, dynamic> data;

  const OverallRatingSnapshotUpdated(this.data);

  @override
  List<Object> get props => [data];
}

class OverallRatingLoadFailed extends OverallRatingEvent {
  final String message;

  const OverallRatingLoadFailed(this.message);

  @override
  List<Object> get props => [message];
}

class FilterReviewsByStarEvent extends OverallRatingEvent {
  final int? starRating;

  const FilterReviewsByStarEvent(this.starRating);

  @override
  List<Object?> get props => [starRating];
}

class FilterReviewsByTabEvent extends OverallRatingEvent {
  final String tab;

  const FilterReviewsByTabEvent(this.tab);

  @override
  List<Object> get props => [tab];
}

class SubmitSellerReplyEvent extends OverallRatingEvent {
  final String reviewId;
  final String replyText;
  final String customerId;
  final String? productName;

  const SubmitSellerReplyEvent({
    required this.reviewId,
    required this.replyText,
    required this.customerId,
    this.productName,
  });

  @override
  List<Object?> get props => [reviewId, replyText, customerId, productName];
}

class ReportReviewEvent extends OverallRatingEvent {
  final String reviewId;
  final String reason;
  final String? details;

  const ReportReviewEvent({
    required this.reviewId,
    required this.reason,
    this.details,
  });

  @override
  List<Object?> get props => [reviewId, reason, details];
}

class ClearActionMessageEvent extends OverallRatingEvent {}
