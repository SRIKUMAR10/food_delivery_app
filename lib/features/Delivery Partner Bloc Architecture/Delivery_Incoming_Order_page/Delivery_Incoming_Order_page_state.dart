import 'package:equatable/equatable.dart';

enum IncomingOrderStatus { initial, loading, loaded, accepted, declined, expired }

class DeliveryIncomingOrderState extends Equatable {
  final IncomingOrderStatus status;
  final int remainingSeconds;
  final String orderId;
  final String storeName;
  final String storeAddress;
  final String customerName;
  final String customerAddress;
  final double orderAmount;
  final String localeCode;
  final String? errorMessage;

  const DeliveryIncomingOrderState({
    this.status = IncomingOrderStatus.initial,
    this.remainingSeconds = 15,
    this.orderId = '#ORD98234',
    this.storeName = 'Green Mart',
    this.storeAddress = '24, Anna Salai, Chennai',
    this.customerName = 'Mike Anderson',
    this.customerAddress = '12, Beach Road, Chennai',
    this.orderAmount = 620.00,
    this.localeCode = 'en',
    this.errorMessage,
  });

  bool get isTimerExpired => remainingSeconds <= 0;

  DeliveryIncomingOrderState copyWith({
    IncomingOrderStatus? status,
    int? remainingSeconds,
    String? orderId,
    String? storeName,
    String? storeAddress,
    String? customerName,
    String? customerAddress,
    double? orderAmount,
    String? localeCode,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeliveryIncomingOrderState(
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      orderId: orderId ?? this.orderId,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      orderAmount: orderAmount ?? this.orderAmount,
      localeCode: localeCode ?? this.localeCode,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        remainingSeconds,
        orderId,
        storeName,
        storeAddress,
        customerName,
        customerAddress,
        orderAmount,
        localeCode,
        errorMessage,
      ];
}
