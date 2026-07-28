import 'package:equatable/equatable.dart';

abstract class TrackOrderEvent extends Equatable {
  const TrackOrderEvent();

  @override
  List<Object> get props => [];
}

class LoadTrackOrderDetails extends TrackOrderEvent {
  final String orderId;
  final DateTime orderDate;

  const LoadTrackOrderDetails({required this.orderId, required this.orderDate});

  @override
  List<Object> get props => [orderId, orderDate];
}

class RefreshTrackOrder extends TrackOrderEvent {
  final String orderId;
  final DateTime orderDate;
  const RefreshTrackOrder({required this.orderId, required this.orderDate});

  @override
  List<Object> get props => [orderId, orderDate];
}

class StartTracking extends TrackOrderEvent {
  final String orderId;
  const StartTracking({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class UpdateDriverLocation extends TrackOrderEvent {
  final double lat;
  final double lng;

  const UpdateDriverLocation({required this.lat, required this.lng});

  @override
  List<Object> get props => [lat, lng];
}

