import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/analytics_data_model.dart';
import 'seller_analytics_page__event.dart';
import 'seller_analytics_page__state.dart';
import 'seller_analytics_repository.dart';

class SellerAnalyticsBloc extends Bloc<SellerAnalyticsEvent, SellerAnalyticsState> {
  final SellerAnalyticsRepository repository;
  StreamSubscription<FavoritesAnalytics>? _favoritesSub;
  StreamSubscription<RatingAnalytics>? _reviewsSub;

  SellerAnalyticsBloc({required this.repository}) : super(AnalyticsInitial()) {
    on<LoadSellerAnalytics>(_onLoadSellerAnalytics);
    on<_FavoritesUpdated>(_onFavoritesUpdated);
    on<_ReviewsUpdated>(_onReviewsUpdated);
  }

  @override
  Future<void> close() {
    _favoritesSub?.cancel();
    _reviewsSub?.cancel();
    return super.close();
  }

  Future<void> _onLoadSellerAnalytics(
    LoadSellerAnalytics event,
    Emitter<SellerAnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final data = await repository.fetchAnalyticsData(event.sellerId, event.timeRange);

      _favoritesSub?.cancel();
      _favoritesSub = repository
          .streamFavoritesAnalytics(event.sellerId)
          .listen((fav) {
        if (!isClosed) add(_FavoritesUpdated(fav));
      });

      _reviewsSub?.cancel();
      _reviewsSub = repository
          .streamRatingAnalytics(event.sellerId)
          .listen((ratings) {
        if (!isClosed) add(_ReviewsUpdated(ratings));
      });

      if (data.isEmpty) {
        emit(AnalyticsEmpty(selectedTimeRange: event.timeRange));
      } else {
        emit(AnalyticsLoaded(
          data: data,
          selectedTimeRange: event.timeRange,
          favorites: _lastFavorites,
          ratingAnalytics: _lastRatingAnalytics,
        ));
      }
    } catch (e) {
      _favoritesSub?.cancel();
      _favoritesSub = null;
      _reviewsSub?.cancel();
      _reviewsSub = null;
      emit(AnalyticsError(message: e.toString()));
    }
  }

  FavoritesAnalytics? _lastFavorites;
  RatingAnalytics? _lastRatingAnalytics;

  void _onFavoritesUpdated(
    _FavoritesUpdated event,
    Emitter<SellerAnalyticsState> emit,
  ) {
    _lastFavorites = event.favorites;
    if (state is AnalyticsLoaded) {
      final loaded = state as AnalyticsLoaded;
      emit(AnalyticsLoaded(
        data: loaded.data,
        selectedTimeRange: loaded.selectedTimeRange,
        favorites: event.favorites,
        ratingAnalytics: loaded.ratingAnalytics,
      ));
    }
  }

  void _onReviewsUpdated(
    _ReviewsUpdated event,
    Emitter<SellerAnalyticsState> emit,
  ) {
    _lastRatingAnalytics = event.ratingAnalytics;
    if (state is AnalyticsLoaded) {
      final loaded = state as AnalyticsLoaded;
      emit(AnalyticsLoaded(
        data: loaded.data,
        selectedTimeRange: loaded.selectedTimeRange,
        favorites: loaded.favorites,
        ratingAnalytics: event.ratingAnalytics,
      ));
    }
  }
}

class _FavoritesUpdated extends SellerAnalyticsEvent {
  final FavoritesAnalytics favorites;
  const _FavoritesUpdated(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

class _ReviewsUpdated extends SellerAnalyticsEvent {
  final RatingAnalytics ratingAnalytics;
  const _ReviewsUpdated(this.ratingAnalytics);

  @override
  List<Object?> get props => [ratingAnalytics];
}
