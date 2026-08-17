import 'package:equatable/equatable.dart';
import '../../../core/models/order_status.dart';

abstract class TrackOrderState extends Equatable {
  const TrackOrderState();

  @override
  List<Object?> get props => [];
}

class TrackOrderInitial extends TrackOrderState {}

class TrackOrderLoading extends TrackOrderState {}

class TrackOrderLoaded extends TrackOrderState {
  final String orderId;
  final OrderStatus status;
  final String orderStatusLabel;
  final DateTime orderDate;
  final String estimatedDelivery;
  final int? etaMinutes;
  final List<TrackingStep> trackingSteps;
  final DeliveryPartner deliveryPartner;
  final SellerInfo? sellerInfo;
  final CustomerInfo? customerInfo;
  final double? driverLat;
  final double? driverLng;
  final double? sellerLat;
  final double? sellerLng;
  final double? customerLat;
  final double? customerLng;
  final bool isMapExpanded;
  final List<OrderTrackItem> orderItems;
  final double? subtotal;
  final double? deliveryFee;
  final double? taxAmount;
  final double? discountAmount;
  final double? platformFee;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String? cancellationReason;

  const TrackOrderLoaded({
    required this.orderId,
    required this.status,
    required this.orderDate,
    required this.estimatedDelivery,
    required this.trackingSteps,
    required this.deliveryPartner,
    this.orderStatusLabel = 'Placed',
    this.etaMinutes,
    this.sellerInfo,
    this.customerInfo,
    this.driverLat,
    this.driverLng,
    this.sellerLat,
    this.sellerLng,
    this.customerLat,
    this.customerLng,
    this.isMapExpanded = false,
    this.orderItems = const [],
    this.subtotal,
    this.deliveryFee,
    this.taxAmount,
    this.discountAmount,
    this.platformFee,
    this.totalAmount = 0.0,
    this.paymentMethod = '',
    this.paymentStatus = '',
    this.cancellationReason,
  });

  TrackOrderLoaded copyWith({
    OrderStatus? status,
    String? orderStatusLabel,
    DateTime? orderDate,
    String? estimatedDelivery,
    int? etaMinutes,
    List<TrackingStep>? trackingSteps,
    DeliveryPartner? deliveryPartner,
    SellerInfo? sellerInfo,
    CustomerInfo? customerInfo,
    double? driverLat,
    double? driverLng,
    double? sellerLat,
    double? sellerLng,
    double? customerLat,
    double? customerLng,
    bool? isMapExpanded,
    List<OrderTrackItem>? orderItems,
    double? subtotal,
    double? deliveryFee,
    double? taxAmount,
    double? discountAmount,
    double? platformFee,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? cancellationReason,
  }) {
    return TrackOrderLoaded(
      orderId: orderId,
      status: status ?? this.status,
      orderStatusLabel: orderStatusLabel ?? this.orderStatusLabel,
      orderDate: orderDate ?? this.orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      trackingSteps: trackingSteps ?? this.trackingSteps,
      deliveryPartner: deliveryPartner ?? this.deliveryPartner,
      sellerInfo: sellerInfo ?? this.sellerInfo,
      customerInfo: customerInfo ?? this.customerInfo,
      driverLat: driverLat ?? this.driverLat,
      driverLng: driverLng ?? this.driverLng,
      sellerLat: sellerLat ?? this.sellerLat,
      sellerLng: sellerLng ?? this.sellerLng,
      customerLat: customerLat ?? this.customerLat,
      customerLng: customerLng ?? this.customerLng,
      isMapExpanded: isMapExpanded ?? this.isMapExpanded,
      orderItems: orderItems ?? this.orderItems,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      platformFee: platformFee ?? this.platformFee,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  bool get isCancelled => status == OrderStatus.cancelled || status == OrderStatus.rejected;

  bool get isDelivered => status == OrderStatus.delivered;

  @override
  List<Object?> get props => [
    orderId,
    status,
    orderStatusLabel,
    orderDate,
    estimatedDelivery,
    etaMinutes,
    trackingSteps,
    deliveryPartner,
    sellerInfo,
    customerInfo,
    driverLat,
    driverLng,
    sellerLat,
    sellerLng,
    customerLat,
    customerLng,
    isMapExpanded,
    orderItems,
    subtotal,
    deliveryFee,
    taxAmount,
    discountAmount,
    platformFee,
    totalAmount,
    paymentMethod,
    paymentStatus,
    cancellationReason,
  ];
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

enum TrackingStatus { completed, current, upcoming, future, cancelled }

class DeliveryPartner extends Equatable {
  final String name;
  final String role;
  final String imageUrl;
  final String phone;
  final String vehicleType;
  final String vehicleNumber;
  final double? rating;
  final int? totalDeliveries;
  final bool isAssigned;
  final double? lat;
  final double? lng;

  const DeliveryPartner({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.phone,
    this.vehicleType = '',
    this.vehicleNumber = '',
    this.rating,
    this.totalDeliveries,
    this.isAssigned = false,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [
    name,
    role,
    imageUrl,
    phone,
    vehicleType,
    vehicleNumber,
    rating,
    totalDeliveries,
    isAssigned,
    lat,
    lng,
  ];
}

class SellerInfo extends Equatable {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String phone;
  final double? lat;
  final double? lng;
  final bool isVerified;
  final String? openStatus;
  final String? openingHours;

  const SellerInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.phone,
    this.lat,
    this.lng,
    this.isVerified = false,
    this.openStatus,
    this.openingHours,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    imageUrl,
    phone,
    lat,
    lng,
    isVerified,
    openStatus,
    openingHours,
  ];
}

class CustomerInfo extends Equatable {
  final String name;
  final String phone;
  final String deliveryAddress;
  final String deliveryNotes;
  final double? lat;
  final double? lng;

  const CustomerInfo({
    required this.name,
    required this.phone,
    required this.deliveryAddress,
    this.deliveryNotes = '',
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [name, phone, deliveryAddress, deliveryNotes, lat, lng];
}

class OrderTrackItem extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;

  const OrderTrackItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, quantity, price, imageUrl];
}
