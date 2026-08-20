import 'package:equatable/equatable.dart';

abstract class SellerStoreDetailsPageState extends Equatable {
  const SellerStoreDetailsPageState();

  @override
  List<Object> get props => [];
}

class SellerStoreDetailsInitial extends SellerStoreDetailsPageState {}

class SellerStoreDetailsLoading extends SellerStoreDetailsPageState {}

class SellerStoreDetailsLoaded extends SellerStoreDetailsPageState {
  final String restaurantName;
  final String address;
  final String phone;
  final String openingHours;
  final String deliveryTime;
  final String deliveryArea;
  final String? gstNumber;
  final String? fssaiNumber;
  final String? panNumber;
  final bool isOnline;
  final double gstPercentage;
  final double minimumOrderValue;
  final double packagingCharges;
  final String? bankAccountNumber;
  final String? bankName;
  final String? fssaiExpiryDate;
  final bool isTaxIncludedInPrice;
  final String invoicePrefix;
  final bool autoAcceptOrders;
  final int prepBufferTimeMinutes;
  final int maxActiveOrdersLimit;
  final bool allowScheduledOrders;
  final bool allowSpecialInstructions;
  final int cancellationWindowMinutes;

  const SellerStoreDetailsLoaded({
    required this.restaurantName,
    required this.address,
    required this.phone,
    required this.openingHours,
    required this.deliveryTime,
    required this.deliveryArea,
    this.gstNumber,
    this.fssaiNumber,
    this.panNumber,
    required this.isOnline,
    required this.gstPercentage,
    required this.minimumOrderValue,
    required this.packagingCharges,
    this.bankAccountNumber,
    this.bankName,
    this.fssaiExpiryDate,
    this.isTaxIncludedInPrice = true,
    this.invoicePrefix = 'INV-',
    this.autoAcceptOrders = false,
    this.prepBufferTimeMinutes = 15,
    this.maxActiveOrdersLimit = 20,
    this.allowScheduledOrders = true,
    this.allowSpecialInstructions = true,
    this.cancellationWindowMinutes = 2,
  });

  @override
  List<Object> get props => [
    restaurantName,
    address,
    phone,
    openingHours,
    deliveryTime,
    deliveryArea,
    if (gstNumber != null) gstNumber!,
    if (fssaiNumber != null) fssaiNumber!,
    if (panNumber != null) panNumber!,
    isOnline,
    gstPercentage,
    minimumOrderValue,
    packagingCharges,
    if (bankAccountNumber != null) bankAccountNumber!,
    if (bankName != null) bankName!,
    if (fssaiExpiryDate != null) fssaiExpiryDate!,
    isTaxIncludedInPrice,
    invoicePrefix,
    autoAcceptOrders,
    prepBufferTimeMinutes,
    maxActiveOrdersLimit,
    allowScheduledOrders,
    allowSpecialInstructions,
    cancellationWindowMinutes,
  ];
}

class SellerStoreDetailsError extends SellerStoreDetailsPageState {
  final String message;

  const SellerStoreDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
