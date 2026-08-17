import 'package:equatable/equatable.dart';

enum OrderDetailsStatus { initial, loading, success, error }

enum PickupFlowStep {
  assigned,
  goingToRestaurant,
  arrivedAtRestaurant,
  pickedUp,
}

enum OtpVerificationStatus {
  initial,
  verifying,
  success,
  invalid,
}

enum CodCollectionStatus { initial, collecting, success, failed }

class OrderItemDetail extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final bool isVerified;
  final String notes;

  const OrderItemDetail({
    this.id = '',
    this.name = '',
    this.quantity = 0,
    this.price = 0.0,
    this.isVerified = false,
    this.notes = '',
  });

  OrderItemDetail copyWith({
    String? id,
    String? name,
    int? quantity,
    double? price,
    bool? isVerified,
    String? notes,
  }) {
    return OrderItemDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      isVerified: isVerified ?? this.isVerified,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, name, quantity, price, isVerified, notes];
}

class OrderModel extends Equatable {
  final String id;
  final String restaurantName;
  final String customerName;
  final String pickupAddress;
  final String dropoffAddress;
  final double earnings;
  final double distance;
  final String status; // 'Pending', 'ASSIGNED', 'GOING_TO_RESTAURANT', 'ARRIVED_AT_RESTAURANT', 'PICKED_UP', 'OutForDelivery', 'Completed'
  final String customerPhone;
  final String merchantPhone;
  final double orderValue;
  final List<OrderItemDetail> items;

  // Rich Order Information
  final String orderDate;
  final String orderTime;
  final int itemsCount;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;

  // Rich Restaurant Information
  final String sellerId;
  final double restaurantLatitude;
  final double restaurantLongitude;
  final String pickupInstructions;

  // Rich Customer Information
  final String customerId;
  final double customerLatitude;
  final double customerLongitude;
  final String deliveryInstructions;

  // Pickup Verification
  final String pickupOtp;
  final bool isOtpVerified;
  final String pickupStatus; // 'ASSIGNED', 'GOING_TO_RESTAURANT', 'ARRIVED_AT_RESTAURANT', 'PICKED_UP'

  // COD Cash Collection
  final double codAmount;
  final bool isCodCollected;
  final double collectedAmount;
  final String codReconciliationStatus;

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
    this.orderDate = '',
    this.orderTime = '',
    this.itemsCount = 0,
    this.totalAmount = 0.0,
    this.paymentMethod = 'Cash on Delivery',
    this.paymentStatus = 'Pending',
    this.sellerId = '',
    this.restaurantLatitude = 0.0,
    this.restaurantLongitude = 0.0,
    this.pickupInstructions = 'Collect sealed bag from front counter.',
    this.customerId = '',
    this.customerLatitude = 0.0,
    this.customerLongitude = 0.0,
    this.deliveryInstructions = 'Leave at doorstep and ring bell.',
    this.pickupOtp = '',
    this.isOtpVerified = false,
    this.pickupStatus = 'ASSIGNED',
    this.codAmount = 0.0,
    this.isCodCollected = false,
    this.collectedAmount = 0.0,
    this.codReconciliationStatus = '',
  });

  bool get isCOD {
    final normalized = paymentMethod.trim().toUpperCase();
    return normalized == 'COD' || normalized == 'CASH ON DELIVERY';
  }

  double get codAmountToCollect => codAmount > 0 ? codAmount : totalAmount;

  PickupFlowStep get currentPickupStep {
    final clean = (pickupStatus.isNotEmpty ? pickupStatus : status)
        .toUpperCase()
        .replaceAll(' ', '_');
    if (clean.contains('PICKED') || clean.contains('OUT_FOR_DELIVERY') || clean.contains('OUTFORDELIVERY') || clean.contains('DELIVERED') || clean.contains('COMPLETED')) {
      return PickupFlowStep.pickedUp;
    } else if (clean.contains('ARRIVED') || clean.contains('REACHED_PICKUP') || clean.contains('READY_FOR_PICKUP')) {
      return PickupFlowStep.arrivedAtRestaurant;
    } else if (clean.contains('GOING') || clean.contains('ON_THE_WAY') || clean.contains('STARTED_PICKUP')) {
      return PickupFlowStep.goingToRestaurant;
    }
    return PickupFlowStep.assigned;
  }

  bool get areAllItemsVerified {
    if (items.isEmpty) return true;
    return items.every((item) => item.isVerified);
  }

  int get verifiedItemsCount {
    return items.where((item) => item.isVerified).length;
  }

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
    String? orderDate,
    String? orderTime,
    int? itemsCount,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? sellerId,
    double? restaurantLatitude,
    double? restaurantLongitude,
    String? pickupInstructions,
    String? customerId,
    double? customerLatitude,
    double? customerLongitude,
    String? deliveryInstructions,
    String? pickupOtp,
    bool? isOtpVerified,
    String? pickupStatus,
    double? codAmount,
    bool? isCodCollected,
    double? collectedAmount,
    String? codReconciliationStatus,
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
      orderDate: orderDate ?? this.orderDate,
      orderTime: orderTime ?? this.orderTime,
      itemsCount: itemsCount ?? this.itemsCount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      sellerId: sellerId ?? this.sellerId,
      restaurantLatitude: restaurantLatitude ?? this.restaurantLatitude,
      restaurantLongitude: restaurantLongitude ?? this.restaurantLongitude,
      pickupInstructions: pickupInstructions ?? this.pickupInstructions,
      customerId: customerId ?? this.customerId,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      pickupOtp: pickupOtp ?? this.pickupOtp,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      pickupStatus: pickupStatus ?? this.pickupStatus,
      codAmount: codAmount ?? this.codAmount,
      isCodCollected: isCodCollected ?? this.isCodCollected,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      codReconciliationStatus:
          codReconciliationStatus ?? this.codReconciliationStatus,
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
        orderDate,
        orderTime,
        itemsCount,
        totalAmount,
        paymentMethod,
        paymentStatus,
        sellerId,
        restaurantLatitude,
        restaurantLongitude,
        pickupInstructions,
        customerId,
        customerLatitude,
        customerLongitude,
        deliveryInstructions,
        pickupOtp,
        isOtpVerified,
        pickupStatus,
        codAmount,
        isCodCollected,
        collectedAmount,
        codReconciliationStatus,
      ];
}

class DeliveryOrderDetailsPageState extends Equatable {
  final OrderDetailsStatus status;
  final OrderModel? order;
  final String? errorMessage;
  final Set<int> verifiedItemIndices;
  final String enteredOtp;
  final OtpVerificationStatus otpStatus;
  final String selectedLanguage; // 'en' or 'ta'
  final CodCollectionStatus codCollectionStatus;
  final double codReceivedAmount;
  final double codChangeAmount;
  final String? codCollectionMessage;

  const DeliveryOrderDetailsPageState({
    this.status = OrderDetailsStatus.initial,
    this.order,
    this.errorMessage,
    this.verifiedItemIndices = const {},
    this.enteredOtp = '',
    this.otpStatus = OtpVerificationStatus.initial,
    this.selectedLanguage = 'en',
    this.codCollectionStatus = CodCollectionStatus.initial,
    this.codReceivedAmount = 0.0,
    this.codChangeAmount = 0.0,
    this.codCollectionMessage,
  });

  DeliveryOrderDetailsPageState copyWith({
    OrderDetailsStatus? status,
    OrderModel? order,
    String? errorMessage,
    bool clearError = false,
    Set<int>? verifiedItemIndices,
    String? enteredOtp,
    OtpVerificationStatus? otpStatus,
    String? selectedLanguage,
    CodCollectionStatus? codCollectionStatus,
    double? codReceivedAmount,
    double? codChangeAmount,
    String? codCollectionMessage,
    bool clearCodCollectionMessage = false,
  }) {
    return DeliveryOrderDetailsPageState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      verifiedItemIndices: verifiedItemIndices ?? this.verifiedItemIndices,
      enteredOtp: enteredOtp ?? this.enteredOtp,
      otpStatus: otpStatus ?? this.otpStatus,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      codCollectionStatus: codCollectionStatus ?? this.codCollectionStatus,
      codReceivedAmount: codReceivedAmount ?? this.codReceivedAmount,
      codChangeAmount: codChangeAmount ?? this.codChangeAmount,
      codCollectionMessage: clearCodCollectionMessage
          ? null
          : (codCollectionMessage ?? this.codCollectionMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        order,
        errorMessage,
        verifiedItemIndices,
        enteredOtp,
        otpStatus,
        selectedLanguage,
        codCollectionStatus,
        codReceivedAmount,
        codChangeAmount,
        codCollectionMessage,
      ];
}
