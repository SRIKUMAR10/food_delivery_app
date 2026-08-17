import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/i_rating_repository.dart';
import '../../../repositories/firebase_rating_repository.dart';

enum RatingStatus { initial, loading, loaded, error, submittingDispute, disputeSuccess }

// ─────────────────────────────────────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────────────────────────────────────

abstract class RatingEvent extends Equatable {
  const RatingEvent();

  @override
  List<Object?> get props => [];
}

class RatingFetchRequested extends RatingEvent {
  final String partnerId;
  const RatingFetchRequested(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}

class RatingFilterSelected extends RatingEvent {
  final int? starFilter; // null = all, 1..5
  const RatingFilterSelected(this.starFilter);

  @override
  List<Object?> get props => [starFilter];
}

class RatingDisputeSubmitted extends RatingEvent {
  final String reviewId;
  final String reason;
  const RatingDisputeSubmitted({required this.reviewId, required this.reason});

  @override
  List<Object?> get props => [reviewId, reason];
}

class RatingRefreshed extends RatingEvent {
  final String partnerId;
  const RatingRefreshed(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}

class _RatingStreamUpdated extends RatingEvent {
  final List<Map<String, dynamic>> reviews;
  final double averageRating;
  final int totalReviews;

  const _RatingStreamUpdated({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  List<Object?> get props => [reviews, averageRating, totalReviews];
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

class RatingState extends Equatable {
  final RatingStatus status;
  final List<Map<String, dynamic>> reviews;
  final List<Map<String, dynamic>> filteredReviews;
  final double averageRating;
  final int totalReviews;
  final int totalDeliveries;
  final int? starFilter;
  final Map<int, int> starDistribution;
  final List<String> compliments;
  final String? errorMessage;
  final String? disputeSuccessMessage;

  const RatingState({
    this.status = RatingStatus.initial,
    this.reviews = const [],
    this.filteredReviews = const [],
    this.averageRating = 5.0,
    this.totalReviews = 0,
    this.totalDeliveries = 0,
    this.starFilter,
    this.starDistribution = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
    this.compliments = const [],
    this.errorMessage,
    this.disputeSuccessMessage,
  });

  RatingState copyWith({
    RatingStatus? status,
    List<Map<String, dynamic>>? reviews,
    List<Map<String, dynamic>>? filteredReviews,
    double? averageRating,
    int? totalReviews,
    int? totalDeliveries,
    int? starFilter,
    bool clearStarFilter = false,
    Map<int, int>? starDistribution,
    List<String>? compliments,
    String? errorMessage,
    String? disputeSuccessMessage,
  }) {
    return RatingState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      filteredReviews: filteredReviews ?? this.filteredReviews,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      starFilter: clearStarFilter ? null : (starFilter ?? this.starFilter),
      starDistribution: starDistribution ?? this.starDistribution,
      compliments: compliments ?? this.compliments,
      errorMessage: errorMessage,
      disputeSuccessMessage: disputeSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reviews,
        filteredReviews,
        averageRating,
        totalReviews,
        totalDeliveries,
        starFilter,
        starDistribution,
        compliments,
        errorMessage,
        disputeSuccessMessage,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────────────────────────────

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final IRatingRepository _ratingRepository;
  StreamSubscription? _ratingSub;

  RatingBloc({
    IRatingRepository? ratingRepository,
  })  : _ratingRepository = ratingRepository ?? FirebaseRatingRepository(),
        super(const RatingState()) {
    on<RatingFetchRequested>(_onFetchRequested);
    on<RatingFilterSelected>(_onFilterSelected);
    on<RatingDisputeSubmitted>(_onDisputeSubmitted);
    on<RatingRefreshed>(_onRefreshed);
    on<_RatingStreamUpdated>(_onStreamUpdated);
  }

  Future<void> _onFetchRequested(
    RatingFetchRequested event,
    Emitter<RatingState> emit,
  ) async {
    emit(state.copyWith(status: RatingStatus.loading, errorMessage: null));
    try {
      _ratingSub?.cancel();
      _ratingSub = _ratingRepository.watchPartnerReviews(event.partnerId).listen(
        (items) {
          final mapped = items.map((r) => {
            'id': r['id'] ?? '',
            'userName': r['customerName'] ?? r['userName'] ?? 'Customer',
            'userAvatar': r['customerAvatarUrl'] ?? r['userAvatar'],
            'rating': (r['rating'] as num?)?.toDouble() ?? 5.0,
            'review': r['reviewText'] ?? r['review'] ?? '',
            'createdAt': r['createdAt'],
            'orderId': r['orderId'] ?? '',
            'tags': r['tags'] ?? <String>[],
          }).toList();

          double avg = 5.0;
          if (mapped.isNotEmpty) {
            final sum = mapped.fold<double>(0.0, (acc, curr) => acc + ((curr['rating'] as num?)?.toDouble() ?? 5.0));
            avg = sum / mapped.length;
          }

          if (!isClosed) {
            add(_RatingStreamUpdated(
              reviews: mapped,
              averageRating: avg,
              totalReviews: mapped.length,
            ));
          }
        },
        onError: (err) {
          if (!isClosed) {
            emit(state.copyWith(status: RatingStatus.error, errorMessage: err.toString()));
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(status: RatingStatus.error, errorMessage: e.toString()));
    }
  }

  void _onFilterSelected(
    RatingFilterSelected event,
    Emitter<RatingState> emit,
  ) {
    final filter = event.starFilter;
    List<Map<String, dynamic>> filtered;
    if (filter == null) {
      filtered = state.reviews;
    } else {
      filtered = state.reviews.where((r) {
        final val = (r['rating'] as num?)?.round() ?? 5;
        return val == filter;
      }).toList();
    }
    emit(state.copyWith(
      starFilter: filter,
      clearStarFilter: filter == null,
      filteredReviews: filtered,
    ));
  }

  void _onStreamUpdated(
    _RatingStreamUpdated event,
    Emitter<RatingState> emit,
  ) {
    final dist = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    final compList = <String>{};

    for (final r in event.reviews) {
      final ratingVal = (r['rating'] as num?)?.round() ?? 5;
      final clamped = ratingVal.clamp(1, 5);
      dist[clamped] = (dist[clamped] ?? 0) + 1;

      if (r['tags'] is List) {
        for (final tag in (r['tags'] as List)) {
          if (tag is String && tag.isNotEmpty) compList.add(tag);
        }
      }
    }

    List<Map<String, dynamic>> filtered;
    if (state.starFilter == null) {
      filtered = event.reviews;
    } else {
      filtered = event.reviews.where((r) {
        final val = (r['rating'] as num?)?.round() ?? 5;
        return val == state.starFilter;
      }).toList();
    }

    emit(state.copyWith(
      status: RatingStatus.loaded,
      reviews: event.reviews,
      filteredReviews: filtered,
      averageRating: event.averageRating,
      totalReviews: event.totalReviews,
      starDistribution: dist,
      compliments: compList.toList(),
    ));
  }

  Future<void> _onDisputeSubmitted(
    RatingDisputeSubmitted event,
    Emitter<RatingState> emit,
  ) async {
    emit(state.copyWith(status: RatingStatus.submittingDispute));
    try {
      // In production, records dispute in support / ratings collection
      await Future.delayed(const Duration(milliseconds: 600));
      emit(state.copyWith(
        status: RatingStatus.disputeSuccess,
        disputeSuccessMessage: 'Dispute submitted for review.',
      ));
    } catch (e) {
      emit(state.copyWith(status: RatingStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshed(
    RatingRefreshed event,
    Emitter<RatingState> emit,
  ) async {
    add(RatingFetchRequested(event.partnerId));
  }

  @override
  Future<void> close() {
    _ratingSub?.cancel();
    return super.close();
  }
}

/// Standardized Feature-Architecture Alias for RatingBloc
typedef DeliveryRatingBloc = RatingBloc;
