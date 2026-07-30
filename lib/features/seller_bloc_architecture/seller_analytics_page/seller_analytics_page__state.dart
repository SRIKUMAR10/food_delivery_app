import 'package:equatable/equatable.dart';
import '../../../../core/models/analytics_data_model.dart';

abstract class SellerAnalyticsState extends Equatable {
  const SellerAnalyticsState();
  
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends SellerAnalyticsState {}

class AnalyticsLoading extends SellerAnalyticsState {}

class AnalyticsLoaded extends SellerAnalyticsState {
  final AnalyticsDataModel data;
  final String selectedTimeRange;
  final FavoritesAnalytics? favorites;
  final RatingAnalytics? ratingAnalytics;

  const AnalyticsLoaded({
    required this.data,
    required this.selectedTimeRange,
    this.favorites,
    this.ratingAnalytics,
  });

  @override
  List<Object?> get props => [data, selectedTimeRange, favorites, ratingAnalytics];
}

class AnalyticsEmpty extends SellerAnalyticsState {
  final String selectedTimeRange;

  const AnalyticsEmpty({required this.selectedTimeRange});

  @override
  List<Object?> get props => [selectedTimeRange];
}

class AnalyticsError extends SellerAnalyticsState {
  final String message;

  const AnalyticsError({required this.message});

  @override
  List<Object?> get props => [message];
}
