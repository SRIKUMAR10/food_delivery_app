import 'package:equatable/equatable.dart';

enum OrderDetailsStatus { initial, loading, success, error }

class OrderModel extends Equatable {
  final String id;
  final String restaurantName;
  final String customerName;
  final String pickupAddress;
  final String dropoffAddress;
  final double earnings;
  final double distance;
  final String status; // 'Pending', 'Reached Pickup', 'Started Delivery', 'Completed'
  final String customerPhone;
  final String merchantPhone;
  final double orderValue;
  final List<OrderItemDetail> items;

  const OrderModel({
    required this.id,
    this.restaurantName = '',
    this.customerName = '',
    this.pickupAddress = '',
    this.dropoffAddress = '',
    this.earnings = 0.0,
    this.distance = 0.0,
    this.status = 'Pending',
    this.customerPhone = '',
    this.merchantPhone = '',
    this.orderValue = 0.0,
    this.items = const [],
  });

  OrderModel copyWith({
    String? id,
    String? restaurantName,
    String? customerName,
    String? pickupAddress,
    String? dropoffAddress,
    double? earnings,
    double? distance,
    String? status,
    String? customerPhone,
    String? merchantPhone,
    double? orderValue,
    List<OrderItemDetail>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      restaurantName: restaurantName ?? this.restaurantName,
      customerName: customerName ?? this.customerName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      earnings: earnings ?? this.earnings,
      distance: distance ?? this.distance,
      status: status ?? this.status,
      customerPhone: customerPhone ?? this.customerPhone,
      merchantPhone: merchantPhone ?? this.merchantPhone,
      orderValue: orderValue ?? this.orderValue,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        restaurantName,
        customerName,
        pickupAddress,
        dropoffAddress,
        earnings,
        distance,
        status,
        customerPhone,
        merchantPhone,
        orderValue,
        items,
      ];
}

class OrderItemDetail extends Equatable {
  final String name;
  final int quantity;
  final double price;

  const OrderItemDetail({
    this.name = '',
    this.quantity = 0,
    this.price = 0.0,
  });

  @override
  List<Object?> get props => [name, quantity, price];
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
