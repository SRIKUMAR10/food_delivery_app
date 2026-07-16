import 'package:equatable/equatable.dart';

abstract class SellerAnalyticsEvent extends Equatable {
  const SellerAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSellerAnalytics extends SellerAnalyticsEvent {
  final String sellerId;
  final String timeRange;

  const LoadSellerAnalytics({required this.sellerId, this.timeRange = 'Weekly'});

  @override
  List<Object?> get props => [sellerId, timeRange];
}
