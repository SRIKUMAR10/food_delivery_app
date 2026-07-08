import 'package:equatable/equatable.dart';

enum DeliveryStatus {
  orderAccepted,
  paymentReceived,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered
}

class RiderDetails extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String imageUrl;

  const RiderDetails({
    required this.id,
    required this.name,
    required this.phone,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, phone, imageUrl];
}

abstract class OutForDeliveryPageState extends Equatable {
  const OutForDeliveryPageState();

  @override
  List<Object?> get props => [];
}

class OutForDeliveryPageInitial extends OutForDeliveryPageState {}

class OutForDeliveryPageLoading extends OutForDeliveryPageState {}

class OutForDeliveryPageLoaded extends OutForDeliveryPageState {
  final String orderId;
  final RiderDetails rider;
  final DeliveryStatus currentStatus;
  final String estimatedTime;
  final String distance;
  // LatLng coordinates can be added here if needed

  const OutForDeliveryPageLoaded({
    required this.orderId,
    required this.rider,
    required this.currentStatus,
    required this.estimatedTime,
    required this.distance,
  });

  @override
  List<Object?> get props => [
        orderId,
        rider,
        currentStatus,
        estimatedTime,
        distance,
      ];
}

class OutForDeliveryPageError extends OutForDeliveryPageState {
  final String message;

  const OutForDeliveryPageError({required this.message});

  @override
  List<Object?> get props => [message];
}
