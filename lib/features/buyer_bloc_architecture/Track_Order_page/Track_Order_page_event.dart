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
  final String riderId;
  const StartTracking({required this.riderId});

  @override
  List<Object> get props => [riderId];
}

class UpdateDriverLocation extends TrackOrderEvent {
  final double lat;
  final double lng;

  const UpdateDriverLocation({required this.lat, required this.lng});

  @override
  List<Object> get props => [lat, lng];
}

class OrderStatusUpdated extends TrackOrderEvent {
  final String orderId;
  final DateTime orderDate;
  final Map<String, dynamic>? orderData;

  const OrderStatusUpdated({
    required this.orderId,
    required this.orderDate,
    this.orderData,
  });

  @override
  List<Object> get props => [orderId, orderDate, orderData ?? const {}];
}

class CancelOrderEvent extends TrackOrderEvent {
  final String orderId;
  final String? reason;

  const CancelOrderEvent(this.orderId, {this.reason});

  @override
  List<Object> get props => [orderId, reason ?? ''];
}

class ToggleMapFullScreen extends TrackOrderEvent {
  const ToggleMapFullScreen();

  @override
  List<Object> get props => [];
}
