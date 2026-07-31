import 'package:equatable/equatable.dart';

enum PickupConfirmationStatus { initial, loading, success, deliveryStarted, error }

class PickupConfirmationModel extends Equatable {
  final String orderId;
  final String pickupLocationName;
  final String pickupAddress;
  final String pickupContactName;
  final String pickupContactPhone;
  final String pickupInstructions;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String pickupTime;
  final String paymentType;
  final double orderAmount;
  final double walletBalance;

  const PickupConfirmationModel({
    required this.orderId,
    required this.pickupLocationName,
    required this.pickupAddress,
    required this.pickupContactName,
    required this.pickupContactPhone,
    required this.pickupInstructions,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.pickupTime,
    required this.paymentType,
    required this.orderAmount,
    required this.walletBalance,
  });

  PickupConfirmationModel copyWith({
    String? orderId,
    String? pickupLocationName,
    String? pickupAddress,
    String? pickupContactName,
    String? pickupContactPhone,
    String? pickupInstructions,
    String? customerName,
    String? customerAddress,
    String? customerPhone,
    String? pickupTime,
    String? paymentType,
    double? orderAmount,
    double? walletBalance,
  }) {
    return PickupConfirmationModel(
      orderId: orderId ?? this.orderId,
      pickupLocationName: pickupLocationName ?? this.pickupLocationName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupContactName: pickupContactName ?? this.pickupContactName,
      pickupContactPhone: pickupContactPhone ?? this.pickupContactPhone,
      pickupInstructions: pickupInstructions ?? this.pickupInstructions,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      pickupTime: pickupTime ?? this.pickupTime,
      paymentType: paymentType ?? this.paymentType,
      orderAmount: orderAmount ?? this.orderAmount,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        pickupLocationName,
        pickupAddress,
        pickupContactName,
        pickupContactPhone,
        pickupInstructions,
        customerName,
        customerAddress,
        customerPhone,
        pickupTime,
        paymentType,
        orderAmount,
        walletBalance,
      ];
}

class DeliveryPickupConfirmationPageState extends Equatable {
  final PickupConfirmationStatus status;
  final PickupConfirmationModel? model;
  final String? errorMessage;
  final String localeCode;

  const DeliveryPickupConfirmationPageState({
    this.status = PickupConfirmationStatus.initial,
    this.model,
    this.errorMessage,
    this.localeCode = 'en',
  });

  DeliveryPickupConfirmationPageState copyWith({
    PickupConfirmationStatus? status,
    PickupConfirmationModel? model,
    String? errorMessage,
    bool clearError = false,
    String? localeCode,
  }) {
    return DeliveryPickupConfirmationPageState(
      status: status ?? this.status,
      model: model ?? this.model,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  List<Object?> get props => [status, model, errorMessage, localeCode];
}
