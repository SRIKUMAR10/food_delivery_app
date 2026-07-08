import 'package:equatable/equatable.dart';

abstract class SellerAnalyticsEvent extends Equatable {
  const SellerAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSellerAnalytics extends SellerAnalyticsEvent {
  final String timeRange;

  const LoadSellerAnalytics({this.timeRange = 'This Week'});

  @override
  List<Object?> get props => [timeRange];
}
