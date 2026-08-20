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
  final double rating;
  final String vehicleType;
  final String vehicleNumber;

  const RiderDetails({
    required this.id,
    required this.name,
    required this.phone,
    required this.imageUrl,
    this.rating = 0.0,
    this.vehicleType = 'two_wheeler',
    this.vehicleNumber = '',
  });

  @override
  List<Object?> get props => [id, name, phone, imageUrl, rating, vehicleType, vehicleNumber];
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
  final double? distanceKm;
  final double? driverSpeed;
  final String? expectedDeliveryTime;
  final double progressRatio;
  final bool isArrivingSoon;
  final bool isRaining;
  final String? weatherAlert;
  final bool isMapExpanded;
  final double? riderLat;
  final double? riderLng;
  final double riderHeading;
  final double? sellerLat;
  final double? sellerLng;
  final String sellerName;
  final String? sellerPhone;
  final String? sellerAddress;
  final double? customerLat;
  final double? customerLng;
  final String customerName;
  final String? customerPhone;
  final String? customerId;
  final String? customerNotes;
  final String deliveryAddress;
  final double? totalAmount;

  const OutForDeliveryPageLoaded({
    required this.orderId,
    required this.rider,
    required this.currentStatus,
    required this.estimatedTime,
    required this.distance,
    this.distanceKm,
    this.driverSpeed,
    this.expectedDeliveryTime,
    this.progressRatio = 0.0,
    this.isArrivingSoon = false,
    this.isRaining = false,
    this.weatherAlert,
    this.isMapExpanded = false,
    this.riderLat,
    this.riderLng,
    this.riderHeading = 0.0,
    this.sellerLat,
    this.sellerLng,
    this.sellerName = 'My Kitchen',
    this.sellerPhone,
    this.sellerAddress,
    this.customerLat,
    this.customerLng,
    this.customerName = 'Customer',
    this.customerPhone,
    this.customerId,
    this.customerNotes,
    this.deliveryAddress = '',
    this.totalAmount,
  });

  OutForDeliveryPageLoaded copyWith({
    String? orderId,
    RiderDetails? rider,
    DeliveryStatus? currentStatus,
    String? estimatedTime,
    String? distance,
    double? distanceKm,
    double? driverSpeed,
    String? expectedDeliveryTime,
    double? progressRatio,
    bool? isArrivingSoon,
    bool? isRaining,
    String? weatherAlert,
    bool? isMapExpanded,
    double? riderLat,
    double? riderLng,
    double riderHeading = 0.0,
    double? sellerLat,
    double? sellerLng,
    String? sellerName,
    String? sellerPhone,
    String? sellerAddress,
    double? customerLat,
    double? customerLng,
    String? customerName,
    String? customerPhone,
    String? customerId,
    String? customerNotes,
    String? deliveryAddress,
    double? totalAmount,
  }) {
    return OutForDeliveryPageLoaded(
      orderId: orderId ?? this.orderId,
      rider: rider ?? this.rider,
      currentStatus: currentStatus ?? this.currentStatus,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      distance: distance ?? this.distance,
      distanceKm: distanceKm ?? this.distanceKm,
      driverSpeed: driverSpeed ?? this.driverSpeed,
      expectedDeliveryTime: expectedDeliveryTime ?? this.expectedDeliveryTime,
      progressRatio: progressRatio ?? this.progressRatio,
      isArrivingSoon: isArrivingSoon ?? this.isArrivingSoon,
      isRaining: isRaining ?? this.isRaining,
      weatherAlert: weatherAlert ?? this.weatherAlert,
      isMapExpanded: isMapExpanded ?? this.isMapExpanded,
      riderLat: riderLat ?? this.riderLat,
      riderLng: riderLng ?? this.riderLng,
      riderHeading: riderHeading != 0.0 ? riderHeading : this.riderHeading,
      sellerLat: sellerLat ?? this.sellerLat,
      sellerLng: sellerLng ?? this.sellerLng,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      customerLat: customerLat ?? this.customerLat,
      customerLng: customerLng ?? this.customerLng,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerId: customerId ?? this.customerId,
      customerNotes: customerNotes ?? this.customerNotes,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        rider,
        currentStatus,
        estimatedTime,
        distance,
        distanceKm,
        driverSpeed,
        expectedDeliveryTime,
        progressRatio,
        isArrivingSoon,
        isRaining,
        weatherAlert,
        isMapExpanded,
        riderLat,
        riderLng,
        riderHeading,
        sellerLat,
        sellerLng,
        sellerName,
        sellerPhone,
        sellerAddress,
        customerLat,
        customerLng,
        customerName,
        customerPhone,
        customerId,
        customerNotes,
        deliveryAddress,
        totalAmount,
      ];
}

class OutForDeliveryPageError extends OutForDeliveryPageState {
  final String message;

  const OutForDeliveryPageError({required this.message});

  @override
  List<Object?> get props => [message];
}
