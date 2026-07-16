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

  const AnalyticsLoaded({required this.data, required this.selectedTimeRange});

  @override
  List<Object?> get props => [data, selectedTimeRange];
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
