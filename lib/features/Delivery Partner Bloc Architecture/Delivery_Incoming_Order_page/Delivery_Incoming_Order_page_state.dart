import 'package:equatable/equatable.dart';

enum IncomingOrderStatus { initial, loading, loaded, accepted, declined, expired }

class DeliveryIncomingOrderState extends Equatable {
  final IncomingOrderStatus status;
  final int remainingSeconds;
  final String orderId;
  final String storeName;
  final String storeAddress;
  final double storeLatitude;
  final double storeLongitude;
  final String customerName;
  final String customerAddress;
  final double customerLatitude;
  final double customerLongitude;
  final double driverLatitude;
  final double driverLongitude;
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
    this.storeLatitude = 11.4485,
    this.storeLongitude = 77.6835,
    this.customerName = '',
    this.customerAddress = '',
    this.customerLatitude = 11.4580,
    this.customerLongitude = 77.6980,
    this.driverLatitude = 11.4485,
    this.driverLongitude = 77.6835,
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
    double? storeLatitude,
    double? storeLongitude,
    String? customerName,
    String? customerAddress,
    double? customerLatitude,
    double? customerLongitude,
    double? driverLatitude,
    double? driverLongitude,
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
      storeLatitude: storeLatitude ?? this.storeLatitude,
      storeLongitude: storeLongitude ?? this.storeLongitude,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
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
        storeLatitude,
        storeLongitude,
        customerName,
        customerAddress,
        customerLatitude,
        customerLongitude,
        driverLatitude,
        driverLongitude,
        orderAmount,
        distanceKm,
        etaMins,
        paymentMethod,
        localeCode,
        errorMessage,
      ];
}
