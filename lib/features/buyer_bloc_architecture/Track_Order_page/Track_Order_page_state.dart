import 'package:equatable/equatable.dart';

abstract class TrackOrderState extends Equatable {
  const TrackOrderState();

  @override
  List<Object?> get props => [];
}

class TrackOrderInitial extends TrackOrderState {}

class TrackOrderLoading extends TrackOrderState {}

class TrackOrderLoaded extends TrackOrderState {
  final String orderId;
  final String estimatedDelivery;
  final List<TrackingStep> trackingSteps;
  final DeliveryPartner deliveryPartner;
  final SellerInfo? sellerInfo;

  const TrackOrderLoaded({
    required this.orderId,
    required this.estimatedDelivery,
    required this.trackingSteps,
    required this.deliveryPartner,
    this.sellerInfo,
  });

  @override
  List<Object?> get props => [orderId, estimatedDelivery, trackingSteps, deliveryPartner, sellerInfo];
}

class TrackOrderError extends TrackOrderState {
  final String message;
  const TrackOrderError(this.message);

  @override
  List<Object?> get props => [message];
}

class TrackingLoading extends TrackOrderState {}

class LocationUpdated extends TrackOrderState {
  final double lat;
  final double lng;

  const LocationUpdated({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}


class TrackingStep extends Equatable {
  final String title;
  final String? time;
  final TrackingStatus status;

  const TrackingStep({
    required this.title,
    this.time,
    required this.status,
  });

  @override
  List<Object?> get props => [title, time, status];
}

enum TrackingStatus { completed, current, upcoming, future }

class DeliveryPartner extends Equatable {
  final String name;
  final String role;
  final String imageUrl;
  final String phone;

  const DeliveryPartner({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, role, imageUrl, phone];
}

class SellerInfo extends Equatable {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String phone;

  const SellerInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.phone,
  });

  @override
  List<Object?> get props => [id, name, address, imageUrl, phone];
}
