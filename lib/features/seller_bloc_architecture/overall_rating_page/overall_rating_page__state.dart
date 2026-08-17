import 'package:equatable/equatable.dart';

/// A single customer review with full seller-reply and reporting metadata.
class ReviewModel extends Equatable {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final double rating;
  final String content;
  final DateTime date;

  final String sellerId;
  final String productId;
  final String productName;
  final String customerId;

  final String? sellerReply;
  final DateTime? sellerRepliedAt;
  final String? sellerReplyAuthor;

  final bool isReported;
  final String? reportReason;
  final String? reportDetails;
  final String? reportStatus;
  final DateTime? reportedAt;

  const ReviewModel({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.rating,
    required this.content,
    required this.date,
    this.sellerId = '',
    this.productId = '',
    this.productName = '',
    this.customerId = '',
    this.sellerReply,
    this.sellerRepliedAt,
    this.sellerReplyAuthor,
    this.isReported = false,
    this.reportReason,
    this.reportDetails,
    this.reportStatus,
    this.reportedAt,
  });

  bool get hasSellerReply =>
      sellerReply != null && sellerReply!.trim().isNotEmpty;

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String? ?? '',
      authorName: map['authorName'] as String? ??
          map['customerName'] as String? ??
          'Unknown',
      authorAvatarUrl: map['authorAvatarUrl'] as String? ??
          map['customerAvatarUrl'] as String? ??
          '',
      rating: _toDouble(map['rating']),
      content: map['content'] as String? ?? '',
      date: _parseDate(map['date'] ?? map['createdAt']) ?? DateTime.now(),
      sellerId: map['sellerId'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      sellerReply: map['sellerReply'] as String?,
      sellerRepliedAt: _parseDate(map['sellerRepliedAt']),
      sellerReplyAuthor: map['sellerReplyAuthor'] as String?,
      isReported: map['isReported'] as bool? ?? false,
      reportReason: map['reportReason'] as String?,
      reportDetails: map['reportDetails'] as String?,
      reportStatus: map['reportStatus'] as String?,
      reportedAt: _parseDate(map['reportedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'rating': rating,
      'content': content,
      'date': date.toIso8601String(),
      'sellerId': sellerId,
      'productId': productId,
      'productName': productName,
      'customerId': customerId,
      'sellerReply': sellerReply,
      'sellerRepliedAt': sellerRepliedAt?.toIso8601String(),
      'sellerReplyAuthor': sellerReplyAuthor,
      'isReported': isReported,
      'reportReason': reportReason,
      'reportDetails': reportDetails,
      'reportStatus': reportStatus,
      'reportedAt': reportedAt?.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? authorName,
    String? authorAvatarUrl,
    double? rating,
    String? content,
    DateTime? date,
    String? sellerId,
    String? productId,
    String? productName,
    String? customerId,
    String? sellerReply,
    DateTime? sellerRepliedAt,
    String? sellerReplyAuthor,
    bool? isReported,
    String? reportReason,
    String? reportDetails,
    String? reportStatus,
    DateTime? reportedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      date: date ?? this.date,
      sellerId: sellerId ?? this.sellerId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      customerId: customerId ?? this.customerId,
      sellerReply: sellerReply ?? this.sellerReply,
      sellerRepliedAt: sellerRepliedAt ?? this.sellerRepliedAt,
      sellerReplyAuthor: sellerReplyAuthor ?? this.sellerReplyAuthor,
      isReported: isReported ?? this.isReported,
      reportReason: reportReason ?? this.reportReason,
      reportDetails: reportDetails ?? this.reportDetails,
      reportStatus: reportStatus ?? this.reportStatus,
      reportedAt: reportedAt ?? this.reportedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorName,
        authorAvatarUrl,
        rating,
        content,
        date,
        sellerId,
        productId,
        productName,
        customerId,
        sellerReply,
        sellerRepliedAt,
        sellerReplyAuthor,
        isReported,
        reportReason,
        reportDetails,
        reportStatus,
        reportedAt,
      ];
}

double _toDouble(dynamic value) => (value as num?)?.toDouble() ?? 0.0;

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  return null;
}

/// 5★-to-1★ distribution with absolute counts and derived percentages.
class RatingBreakdownModel extends Equatable {
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;

  const RatingBreakdownModel({
    this.fiveStar = 0,
    this.fourStar = 0,
    this.threeStar = 0,
    this.twoStar = 0,
    this.oneStar = 0,
  });

  factory RatingBreakdownModel.fromReviews(List<ReviewModel> reviews) {
    var five = 0;
    var four = 0;
    var three = 0;
    var two = 0;
    var one = 0;
    for (final review in reviews) {
      final star = review.rating.round().clamp(1, 5);
      switch (star) {
        case 5:
          five++;
          break;
        case 4:
          four++;
          break;
        case 3:
          three++;
          break;
        case 2:
          two++;
          break;
        case 1:
          one++;
          break;
      }
    }
    return RatingBreakdownModel(
      fiveStar: five,
      fourStar: four,
      threeStar: three,
      twoStar: two,
      oneStar: one,
    );
  }

  int get total => fiveStar + fourStar + threeStar + twoStar + oneStar;

  int countForStar(int star) {
    switch (star) {
      case 5:
        return fiveStar;
      case 4:
        return fourStar;
      case 3:
        return threeStar;
      case 2:
        return twoStar;
      case 1:
        return oneStar;
      default:
        return 0;
    }
  }

  double percentForStar(int star) {
    if (total == 0) return 0;
    return (countForStar(star) / total) * 100;
  }

  @override
  List<Object?> get props => [fiveStar, fourStar, threeStar, twoStar, oneStar];
}

abstract class OverallRatingState extends Equatable {
  const OverallRatingState();

  @override
  List<Object?> get props => [];
}

class OverallRatingInitial extends OverallRatingState {}

class OverallRatingLoading extends OverallRatingState {}

class OverallRatingLoaded extends OverallRatingState {
  final double overallRating;
  final int totalReviews;
  final RatingBreakdownModel breakdown;
  final List<ReviewModel> allReviews;
  final List<ReviewModel> filteredReviews;
  final int? selectedStarFilter;
  final String activeTabFilter;
  final bool isSubmittingReply;
  final bool isReportingReview;
  final String? actionMessage;

  const OverallRatingLoaded({
    required this.overallRating,
    required this.totalReviews,
    required this.breakdown,
    required this.allReviews,
    required this.filteredReviews,
    this.selectedStarFilter,
    this.activeTabFilter = 'all',
    this.isSubmittingReply = false,
    this.isReportingReview = false,
    this.actionMessage,
  });

  OverallRatingLoaded copyWith({
    double? overallRating,
    int? totalReviews,
    RatingBreakdownModel? breakdown,
    List<ReviewModel>? allReviews,
    List<ReviewModel>? filteredReviews,
    int? selectedStarFilter,
    bool clearStarFilter = false,
    String? activeTabFilter,
    bool? isSubmittingReply,
    bool? isReportingReview,
    String? actionMessage,
    bool clearActionMessage = false,
  }) {
    return OverallRatingLoaded(
      overallRating: overallRating ?? this.overallRating,
      totalReviews: totalReviews ?? this.totalReviews,
      breakdown: breakdown ?? this.breakdown,
      allReviews: allReviews ?? this.allReviews,
      filteredReviews: filteredReviews ?? this.filteredReviews,
      selectedStarFilter: clearStarFilter
          ? null
          : (selectedStarFilter ?? this.selectedStarFilter),
      activeTabFilter: activeTabFilter ?? this.activeTabFilter,
      isSubmittingReply: isSubmittingReply ?? this.isSubmittingReply,
      isReportingReview: isReportingReview ?? this.isReportingReview,
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
    );
  }

  @override
  List<Object?> get props => [
        overallRating,
        totalReviews,
        breakdown,
        allReviews,
        filteredReviews,
        selectedStarFilter,
        activeTabFilter,
        isSubmittingReply,
        isReportingReview,
        actionMessage,
      ];
}

class OverallRatingError extends OverallRatingState {
  final String message;

  const OverallRatingError(this.message);

  @override
  List<Object> get props => [message];
}
