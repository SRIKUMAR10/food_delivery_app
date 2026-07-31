import 'package:equatable/equatable.dart';

enum OrderDetailsStatus { initial, loading, success, error }

class OrderModel extends Equatable {
  final String id;
  final String pickupAddress;
  final String dropoffAddress;
  final double earnings;
  final double distance;
  final String status; // 'Pending', 'Reached Pickup', 'Started Delivery', 'Completed'
  final String customerPhone;
  final String merchantPhone;
  final double orderValue;

  const OrderModel({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.earnings,
    required this.distance,
    required this.status,
    required this.customerPhone,
    required this.merchantPhone,
    required this.orderValue,
  });

  OrderModel copyWith({
    String? id,
    String? pickupAddress,
    String? dropoffAddress,
    double? earnings,
    double? distance,
    String? status,
    String? customerPhone,
    String? merchantPhone,
    double? orderValue,
  }) {
    return OrderModel(
      id: id ?? this.id,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      earnings: earnings ?? this.earnings,
      distance: distance ?? this.distance,
      status: status ?? this.status,
      customerPhone: customerPhone ?? this.customerPhone,
      merchantPhone: merchantPhone ?? this.merchantPhone,
      orderValue: orderValue ?? this.orderValue,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pickupAddress,
        dropoffAddress,
        earnings,
        distance,
        status,
        customerPhone,
        merchantPhone,
        orderValue,
      ];
}

class DeliveryOrderDetailsPageState extends Equatable {
  final OrderDetailsStatus status;
  final OrderModel? order;
  final String? errorMessage;

  const DeliveryOrderDetailsPageState({
    this.status = OrderDetailsStatus.initial,
    this.order,
    this.errorMessage,
  });

  DeliveryOrderDetailsPageState copyWith({
    OrderDetailsStatus? status,
    OrderModel? order,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeliveryOrderDetailsPageState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, order, errorMessage];
}
