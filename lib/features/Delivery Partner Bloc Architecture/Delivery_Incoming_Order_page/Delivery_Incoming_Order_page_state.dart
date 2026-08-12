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
  final double distanceKm;
  final int etaMins;
  final String paymentMethod;
  final String localeCode;
  final String? errorMessage;

  const DeliveryIncomingOrderState({
    this.status = IncomingOrderStatus.initial,
    this.remainingSeconds = 15,
    this.orderId = '',
    this.storeName = '',
    this.storeAddress = '',
    this.customerName = '',
    this.customerAddress = '',
    this.orderAmount = 0.0,
    this.distanceKm = 0.0,
    this.etaMins = 0,
    this.paymentMethod = '',
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
    double? distanceKm,
    int? etaMins,
    String? paymentMethod,
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
      distanceKm: distanceKm ?? this.distanceKm,
      etaMins: etaMins ?? this.etaMins,
      paymentMethod: paymentMethod ?? this.paymentMethod,
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
        distanceKm,
        etaMins,
        paymentMethod,
        localeCode,
        errorMessage,
      ];
}
