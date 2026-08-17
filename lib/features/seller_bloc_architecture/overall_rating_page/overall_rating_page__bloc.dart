import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'overall_rating_page__event.dart';
import 'overall_rating_page__state.dart';
import 'package:food_delivery_app/api_service/seller_review_service.dart';

class OverallRatingBloc extends Bloc<OverallRatingEvent, OverallRatingState> {
  final SellerReviewService service;

  StreamSubscription<Map<String, dynamic>>? _subscription;
  int? _selectedStarFilter;
  String _activeTabFilter = 'all';

  OverallRatingBloc({required this.service}) : super(OverallRatingInitial()) {
    on<LoadOverallRatingEvent>(_onLoadOverallRating);
    on<RefreshOverallRatingEvent>(_onRefreshOverallRating);
    on<OverallRatingSnapshotUpdated>(_onSnapshotUpdated);
    on<OverallRatingLoadFailed>(_onLoadFailed);
    on<FilterReviewsByStarEvent>(_onFilterByStar);
    on<FilterReviewsByTabEvent>(_onFilterByTab);
    on<SubmitSellerReplyEvent>(_onSubmitSellerReply);
    on<ReportReviewEvent>(_onReportReview);
    on<ClearActionMessageEvent>(_onClearActionMessage);
  }

  Future<void> _onLoadOverallRating(
      LoadOverallRatingEvent event, Emitter<OverallRatingState> emit) async {
    await _subscription?.cancel();
    emit(OverallRatingLoading());
    _subscription = service.watchRatingsAndReviews().listen(
          _handleSnapshot,
          onError: _handleError,
        );
  }

  void _onRefreshOverallRating(
      RefreshOverallRatingEvent event, Emitter<OverallRatingState> emit) {
    add(LoadOverallRatingEvent());
  }

  void _handleSnapshot(Map<String, dynamic> data) {
    if (isClosed) return;
    add(OverallRatingSnapshotUpdated(data));
  }

  void _handleError(Object error, [StackTrace? stackTrace]) {
    if (isClosed) return;
    add(OverallRatingLoadFailed(error.toString()));
  }

  void _onSnapshotUpdated(
      OverallRatingSnapshotUpdated event, Emitter<OverallRatingState> emit) {
    emit(_buildLoaded(event.data));
  }

  void _onLoadFailed(
      OverallRatingLoadFailed event, Emitter<OverallRatingState> emit) {
    emit(OverallRatingError(event.message));
  }

  void _onFilterByStar(
      FilterReviewsByStarEvent event, Emitter<OverallRatingState> emit) {
    _selectedStarFilter = event.starRating;
    final current = state;
    if (current is OverallRatingLoaded) {
      emit(_rebuild(current));
    }
  }

  void _onFilterByTab(
      FilterReviewsByTabEvent event, Emitter<OverallRatingState> emit) {
    _activeTabFilter = event.tab;
    final current = state;
    if (current is OverallRatingLoaded) {
      emit(_rebuild(current));
    }
  }

  Future<void> _onSubmitSellerReply(SubmitSellerReplyEvent event,
      Emitter<OverallRatingState> emit) async {
    final current = state;
    if (current is! OverallRatingLoaded) return;

    emit(current.copyWith(isSubmittingReply: true, clearActionMessage: true));
    try {
      await service.submitSellerReply(
        reviewId: event.reviewId,
        replyText: event.replyText,
        authorName: '',
        customerId: event.customerId,
        productName: event.productName,
      );
      final updated = state;
      if (updated is OverallRatingLoaded) {
        emit(updated.copyWith(
          isSubmittingReply: false,
          actionMessage: 'replySubmittedSuccess',
        ));
      }
    } catch (_) {
      final updated = state;
      if (updated is OverallRatingLoaded) {
        emit(updated.copyWith(
          isSubmittingReply: false,
          actionMessage: 'replyFailed',
        ));
      }
    }
  }

  Future<void> _onReportReview(
      ReportReviewEvent event, Emitter<OverallRatingState> emit) async {
    final current = state;
    if (current is! OverallRatingLoaded) return;

    emit(current.copyWith(isReportingReview: true, clearActionMessage: true));
    try {
      await service.reportInappropriateReview(
        reviewId: event.reviewId,
        reason: event.reason,
        details: event.details,
      );
      final updated = state;
      if (updated is OverallRatingLoaded) {
        emit(updated.copyWith(
          isReportingReview: false,
          actionMessage: 'reviewReportedSuccess',
        ));
      }
    } catch (_) {
      final updated = state;
      if (updated is OverallRatingLoaded) {
        emit(updated.copyWith(
          isReportingReview: false,
          actionMessage: 'reportFailed',
        ));
      }
    }
  }

  void _onClearActionMessage(
      ClearActionMessageEvent event, Emitter<OverallRatingState> emit) {
    final current = state;
    if (current is OverallRatingLoaded) {
      emit(current.copyWith(clearActionMessage: true));
    }
  }

  OverallRatingLoaded _buildLoaded(Map<String, dynamic> data) {
    final rawReviews = (data['reviews'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => ReviewModel.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final breakdown = RatingBreakdownModel.fromReviews(rawReviews);
    final overallRating = _toDouble(data['overallRating']);
    final totalReviews =
        (data['totalReviews'] as num?)?.toInt() ?? rawReviews.length;

    return OverallRatingLoaded(
      overallRating: overallRating,
      totalReviews: totalReviews,
      breakdown: breakdown,
      allReviews: rawReviews,
      filteredReviews: _applyFilters(rawReviews),
      selectedStarFilter: _selectedStarFilter,
      activeTabFilter: _activeTabFilter,
    );
  }

  OverallRatingLoaded _rebuild(OverallRatingLoaded current) {
    return current.copyWith(
      filteredReviews: _applyFilters(current.allReviews),
      selectedStarFilter: _selectedStarFilter,
      activeTabFilter: _activeTabFilter,
    );
  }

  List<ReviewModel> _applyFilters(List<ReviewModel> reviews) {
    var result = reviews;
    if (_selectedStarFilter != null) {
      result = result
          .where((r) => r.rating.round().clamp(1, 5) == _selectedStarFilter)
          .toList();
    }
    switch (_activeTabFilter) {
      case 'unreplied':
        result = result.where((r) => !r.hasSellerReply).toList();
        break;
      case 'replied':
        result = result.where((r) => r.hasSellerReply).toList();
        break;
      case 'reported':
        result = result.where((r) => r.isReported).toList();
        break;
      default:
        break;
    }
    return result;
  }

  double _toDouble(dynamic value) => (value as num?)?.toDouble() ?? 0.0;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
