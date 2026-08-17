import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'order_status.dart';
import 'order_item_model.dart';

class OrderModel extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String sellerId;
  final String? riderId;
  final String? deliveryPartnerId;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String? deliveryPartnerStatus;
  final String? pickupStatus;
  final OrderStatus status;
  final double amount;
  final DateTime timestamp;
  final List<OrderItemModel>? items;
  final String? deliveryAddress;
  final String? customerPhone;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final double? codAmount;
  final bool? isCodCollected;
  final double? collectedAmount;
  final DateTime? codCollectedAt;
  final DateTime? codSubmittedAt;
  final String? codReconciliationStatus;
  final double? baseFare;
  final double? distanceFare;
  final double? surgeFare;
  final double? incentiveAmount;
  final double? bonusAmount;
  final double? tipsAmount;
  final double? cancellationCompensation;
  final double? totalPartnerEarnings;
  final double? subtotal;
  final double? deliveryFee;
  final double? taxAmount;
  final double? discountAmount;
  final String? couponCode;
  final double? platformFee;
  final String? sellerName;
  final String? cancellationReason;
  final double? driverLat;
  final double? driverLng;
  final DateTime? updatedAt;
  final DateTime? assignedAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? goingToRestaurantAt;
  final DateTime? arrivedAtStoreAt;
  final DateTime? pickedUpAt;
  final DateTime? outForDeliveryAt;
  final DateTime? arrivedAtCustomerAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? deliveryOtp;
  final List<Map<String, dynamic>>? statusHistory;
  final String? proofOfDeliveryUrl;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.sellerId,
    this.riderId,
    this.deliveryPartnerId,
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    this.deliveryPartnerStatus,
    this.pickupStatus,
    required this.status,
    required this.amount,
    required this.timestamp,
    this.items,
    this.deliveryAddress,
    this.customerPhone,
    this.paymentMethod,
    this.paymentStatus,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.codAmount,
    this.isCodCollected,
    this.collectedAmount,
    this.codCollectedAt,
    this.codSubmittedAt,
    this.codReconciliationStatus,
    this.baseFare,
    this.distanceFare,
    this.surgeFare,
    this.incentiveAmount,
    this.bonusAmount,
    this.tipsAmount,
    this.cancellationCompensation,
    this.totalPartnerEarnings,
    this.subtotal,
    this.deliveryFee,
    this.taxAmount,
    this.discountAmount,
    this.couponCode,
    this.platformFee,
    this.sellerName,
    this.cancellationReason,
    this.driverLat,
    this.driverLng,
    this.updatedAt,
    this.assignedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.preparingAt,
    this.readyAt,
    this.goingToRestaurantAt,
    this.arrivedAtStoreAt,
    this.pickedUpAt,
    this.outForDeliveryAt,
    this.arrivedAtCustomerAt,
    this.deliveredAt,
    this.cancelledAt,
    this.deliveryOtp,
    this.statusHistory,
    this.proofOfDeliveryUrl,
  });

  DeliveryFlowStatus get deliveryFlowState {
    final statusStr = deliveryPartnerStatus ?? pickupStatus ?? status.value;
    return DeliveryFlowStatus.fromString(statusStr);
  }

  bool get isPaid =>
      (paymentStatus ?? '').toLowerCase() == 'paid' ||
      (paymentMethod ?? '').toLowerCase() == 'wallet';

  bool get isCOD => (paymentMethod ?? '').toUpperCase() == 'COD';

  /// Amount of cash actually collected from the customer for a COD order.
  double get codAmountToCollect => codAmount ?? amount;

  /// Total partner earnings computed from the itemized fare breakdown,
  /// falling back to the stored aggregate when the breakdown is absent.
  double get partnerEarningsTotal {
    final stored = totalPartnerEarnings;
    if (stored != null) return stored;
    return (baseFare ?? 0) +
        (distanceFare ?? 0) +
        (surgeFare ?? 0) +
        (incentiveAmount ?? 0) +
        (bonusAmount ?? 0) +
        (tipsAmount ?? 0) +
        (cancellationCompensation ?? 0);
  }

  bool get hasEarningsBreakdown =>
      baseFare != null ||
      distanceFare != null ||
      surgeFare != null ||
      incentiveAmount != null ||
      bonusAmount != null ||
      tipsAmount != null ||
      cancellationCompensation != null;

  bool get isCodReconciled =>
      (codReconciliationStatus ?? '').toLowerCase() == 'settled' ||
      (codReconciliationStatus ?? '').toLowerCase() == 'submitted';

  bool get isRazorpay => (paymentMethod ?? '').toLowerCase() == 'razorpay';

  String get paymentDisplayString {
    if (isRazorpay) return 'Paid via Razorpay';
    if (isCOD) {
      final amt = codAmount ?? amount;
      return 'COD - Pay ₹${amt.toStringAsFixed(0)}';
    }
    if ((paymentMethod ?? '').toLowerCase() == 'wallet') return 'Paid via Wallet';
    return paymentMethod ?? 'Paid';
  }

  /// Validates if a transition from current status to [newStatus] is allowed.
  bool canTransitionTo(OrderStatus newStatus) {
    if (status == newStatus) return true;
    switch (status) {
      case OrderStatus.newOrder:
        return newStatus == OrderStatus.accepted ||
            newStatus == OrderStatus.preparing ||
            newStatus == OrderStatus.rejected ||
            newStatus == OrderStatus.cancelled;      case OrderStatus.accepted:
        return newStatus == OrderStatus.preparing ||
            newStatus == OrderStatus.ready ||
            newStatus == OrderStatus.rejected ||
            newStatus == OrderStatus.cancelled;
      case OrderStatus.preparing:
        return newStatus == OrderStatus.ready ||
            newStatus == OrderStatus.cancelled;
      case OrderStatus.ready:
        return newStatus == OrderStatus.pickedUp ||
            newStatus == OrderStatus.outForDelivery ||
            newStatus == OrderStatus.cancelled;
      case OrderStatus.pickedUp:
        return newStatus == OrderStatus.outForDelivery ||
            newStatus == OrderStatus.cancelled;
      case OrderStatus.outForDelivery:
        return newStatus == OrderStatus.delivered ||
            newStatus == OrderStatus.cancelled;
      case OrderStatus.delivered:
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return false; // Terminal states
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel.fromMap(data, doc.id);
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? _ts(String key) =>
        (map[key] as Timestamp?)?.toDate();

    DateTime? _parseTsValue(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      if (value is num) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      }
      return null;
    }

    String extractedCustomerId = '';
    for (final k in ['customerId', 'buyerId', 'userId', 'customer_id', 'buyer_id', 'user_id', 'uid']) {
      final val = map[k];
      if (val is String && val.trim().isNotEmpty) {
        extractedCustomerId = val.trim();
        break;
      }
    }
    if (extractedCustomerId.isEmpty && map['customer'] is Map) {
      final cMap = map['customer'] as Map;
      for (final k in ['id', 'uid', 'customerId', 'buyerId', 'userId']) {
        final val = cMap[k];
        if (val is String && val.trim().isNotEmpty) {
          extractedCustomerId = val.trim();
          break;
        }
      }
    }

    String extractedCustomerName = '';
    for (final k in ['customerName', 'buyerName', 'userName', 'name', 'customer_name', 'buyer_name', 'user_name', 'displayName', 'fullName']) {
      final val = map[k];
      if (val is String && val.trim().isNotEmpty) {
        final candidate = val.trim();
        final lower = candidate.toLowerCase();
        if (lower != 'customer' && lower != 'buyer' && lower != 'unknown' && lower != 'unknown customer' && lower != '?') {
          extractedCustomerName = candidate;
          break;
        }
      }
    }
    if (extractedCustomerName.isEmpty && map['customer'] is Map) {
      final cMap = map['customer'] as Map;
      for (final k in ['name', 'customerName', 'buyerName', 'userName', 'displayName', 'fullName']) {
        final val = cMap[k];
        if (val is String && val.trim().isNotEmpty) {
          final candidate = val.trim();
          final lower = candidate.toLowerCase();
          if (lower != 'customer' && lower != 'buyer' && lower != 'unknown') {
            extractedCustomerName = candidate;
            break;
          }
        }
      }
    }
    if (extractedCustomerName.isEmpty) {
      extractedCustomerName = map['customerName'] as String? ?? 'Customer';
    }

    String extractedCustomerPhone = '';
    for (final k in [
      'customerPhone',
      'phone',
      'phoneNumber',
      'mobile',
      'userPhone',
      'buyerPhone',
      'contactNumber',
      'contact',
      'contactPhone',
      'phone_number',
      'customer_phone',
      'buyer_phone',
    ]) {
      final val = map[k];
      if (val is String && val.trim().isNotEmpty) {
        extractedCustomerPhone = val.trim();
        break;
      }
    }
    if (extractedCustomerPhone.isEmpty && map['customer'] is Map) {
      final cMap = map['customer'] as Map;
      for (final k in ['phone', 'customerPhone', 'phoneNumber', 'mobile', 'userPhone']) {
        final val = cMap[k];
        if (val is String && val.trim().isNotEmpty) {
          extractedCustomerPhone = val.trim();
          break;
        }
      }
    }

    String extractedDeliveryAddress = '';
    for (final k in [
      'deliveryAddress',
      'address',
      'primaryAddress',
      'homeAddress',
      'workAddress',
      'otherAddress',
      'shippingAddress',
      'userAddress',
      'fullAddress',
      'displayAddress',
      'dropOffAddress',
      'delivery_address',
      'customer_address',
    ]) {
      final val = map[k];
      if (val is String && val.trim().isNotEmpty) {
        extractedDeliveryAddress = val.trim();
        break;
      } else if (val is Map) {
        final sub = val['address'] ?? val['fullAddress'] ?? val['street'] ?? val['formattedAddress'] ?? val['displayAddress'];
        if (sub != null && sub.toString().trim().isNotEmpty) {
          extractedDeliveryAddress = sub.toString().trim();
          break;
        }
      }
    }
    if (extractedDeliveryAddress.isEmpty && map['customer'] is Map) {
      final cMap = map['customer'] as Map;
      for (final k in ['address', 'deliveryAddress', 'primaryAddress', 'homeAddress', 'workAddress']) {
        final val = cMap[k];
        if (val is String && val.trim().isNotEmpty) {
          extractedDeliveryAddress = val.trim();
          break;
        }
      }
    }

    final razorpayData = map['razorpayDetails'] is Map ? (map['razorpayDetails'] as Map) : null;
    final codData = map['codDetails'] is Map ? (map['codDetails'] as Map) : null;

    final extractedPaymentStatus = map['paymentStatus'] as String? ??
        (razorpayData != null ? 'Paid' : (map['paymentMethod'] == 'COD' ? 'Pending' : 'Paid'));

    final extractedRazorpayOrderId = map['razorpayOrderId'] as String? ??
        (razorpayData?['orderId'] as String?);
    final extractedRazorpayPaymentId = map['razorpayPaymentId'] as String? ??
        (razorpayData?['paymentId'] as String?);

    final extractedCodAmount = ((codData?['amountToCollect'] ?? map['codAmount']) as num?)?.toDouble();
    final extractedIsCodCollected = (codData?['isCollected'] ?? map['isCodCollected']) as bool?;
    final extractedCollectedAmount = ((codData?['collectedAmount'] ?? map['collectedAmount']) as num?)?.toDouble();
    final extractedCodCollectedAt = _ts('codCollectedAt') ?? (codData != null ? _parseTsValue(codData['collectedAt']) : null);
    final extractedCodSubmittedAt = _ts('codSubmittedAt') ?? (codData != null ? _parseTsValue(codData['submittedAt']) : null);
    final extractedCodReconciliationStatus = map['codReconciliationStatus'] as String? ?? codData?['reconciliationStatus'] as String?;

    double? _num(String key) => (map[key] as num?)?.toDouble();
    final extractedBaseFare = _num('baseFare');
    final extractedDistanceFare = _num('distanceFare');
    final extractedSurgeFare = _num('surgeFare');
    final extractedIncentiveAmount = _num('incentiveAmount') ?? _num('incentive');
    final extractedBonusAmount = _num('bonusAmount') ?? _num('bonus');
    final extractedTipsAmount = _num('tipsAmount') ?? _num('tipAmount') ?? _num('tips');
    final extractedCancellationCompensation = _num('cancellationCompensation');
    final extractedTotalPartnerEarnings = _num('totalPartnerEarnings') ?? _num('partnerEarnings');

    final extractedSubtotal = _num('subtotal');
    final extractedDeliveryFee = _num('deliveryFee');
    final extractedTaxAmount = _num('taxAmount');
    final extractedDiscountAmount = _num('discountAmount');
    final extractedPlatformFee = _num('platformFee');
    final extractedDriverLat = _num('driverLat');
    final extractedDriverLng = _num('driverLng');    final extractedCouponCode = map['couponCode'] as String?;
    final extractedSellerName = map['sellerName'] as String?;
    final extractedCancellationReason = map['cancellationReason'] as String?;

    final extractedDeliveryPartnerId = map['deliveryPartnerId'] as String? ?? map['riderId'] as String? ?? map['driverId'] as String?;
    final extractedDeliveryPartnerName = map['deliveryPartnerName'] as String? ?? map['driverName'] as String? ?? map['riderName'] as String?;
    final extractedDeliveryPartnerPhone = map['deliveryPartnerPhone'] as String? ?? map['driverPhone'] as String? ?? map['riderPhone'] as String?;
    final extractedDeliveryPartnerStatus = map['deliveryPartnerStatus'] as String? ?? map['deliveryStatus'] as String?;
    final extractedPickupStatus = map['pickupStatus'] as String?;

    return OrderModel(
      id: documentId,
      customerId: extractedCustomerId,
      customerName: extractedCustomerName,
      sellerId: map['sellerId'] as String? ?? '',
      riderId: extractedDeliveryPartnerId,
      deliveryPartnerId: extractedDeliveryPartnerId,
      deliveryPartnerName: extractedDeliveryPartnerName,
      deliveryPartnerPhone: extractedDeliveryPartnerPhone,
      deliveryPartnerStatus: extractedDeliveryPartnerStatus,
      pickupStatus: extractedPickupStatus,
      status: OrderStatus.fromString(map['status'] as String? ?? 'New'),
      amount: ((map['amount'] as num?)?.toDouble() ?? 0.0).roundToDouble(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: (map['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      deliveryAddress: extractedDeliveryAddress.isNotEmpty ? extractedDeliveryAddress : map['deliveryAddress'] as String?,
      customerPhone: extractedCustomerPhone.isNotEmpty ? extractedCustomerPhone : map['customerPhone'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      paymentStatus: extractedPaymentStatus,
      razorpayOrderId: extractedRazorpayOrderId,
      razorpayPaymentId: extractedRazorpayPaymentId,
      codAmount: extractedCodAmount,
      isCodCollected: extractedIsCodCollected,
      collectedAmount: extractedCollectedAmount,
      codCollectedAt: extractedCodCollectedAt,
      codSubmittedAt: extractedCodSubmittedAt,
      codReconciliationStatus: extractedCodReconciliationStatus,
      baseFare: extractedBaseFare,
      distanceFare: extractedDistanceFare,
      surgeFare: extractedSurgeFare,
      incentiveAmount: extractedIncentiveAmount,
      bonusAmount: extractedBonusAmount,
      tipsAmount: extractedTipsAmount,
      cancellationCompensation: extractedCancellationCompensation,
      totalPartnerEarnings: extractedTotalPartnerEarnings,
      subtotal: extractedSubtotal,
      deliveryFee: extractedDeliveryFee,
      taxAmount: extractedTaxAmount,
      discountAmount: extractedDiscountAmount,
      couponCode: extractedCouponCode,
      platformFee: extractedPlatformFee,
      sellerName: extractedSellerName,
      cancellationReason: extractedCancellationReason,
      driverLat: extractedDriverLat,
      driverLng: extractedDriverLng,
      updatedAt: _ts('updatedAt'),
      assignedAt: _ts('assignedAt'),
      acceptedAt: _ts('acceptedAt'),
      rejectedAt: _ts('rejectedAt'),
      preparingAt: _ts('preparingAt'),
      readyAt: _ts('readyAt'),
      goingToRestaurantAt: _ts('goingToRestaurantAt'),
      arrivedAtStoreAt: _ts('arrivedAtStoreAt') ?? _ts('arrivedAtRestaurantAt'),
      pickedUpAt: _ts('pickedUpAt'),
      outForDeliveryAt: _ts('outForDeliveryAt'),
      arrivedAtCustomerAt: _ts('arrivedAtCustomerAt'),
      deliveredAt: _ts('deliveredAt'),
      cancelledAt: _ts('cancelledAt'),
      deliveryOtp: map['deliveryOtp'] as String? ?? map['otp'] as String?,
      statusHistory: (map['statusHistory'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      proofOfDeliveryUrl: map['proofOfDeliveryUrl'] as String? ?? map['podUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'sellerId': sellerId,
      'riderId': riderId ?? deliveryPartnerId,
      if (deliveryPartnerId != null) 'deliveryPartnerId': deliveryPartnerId,
      if (deliveryPartnerName != null) 'deliveryPartnerName': deliveryPartnerName,
      if (deliveryPartnerPhone != null) 'deliveryPartnerPhone': deliveryPartnerPhone,
      if (deliveryPartnerStatus != null) 'deliveryPartnerStatus': deliveryPartnerStatus,
      if (pickupStatus != null) 'pickupStatus': pickupStatus,
      'status': status.value,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'items': items?.map((e) => e.toMap()).toList(),
      'deliveryAddress': deliveryAddress,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
      if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
      if (codAmount != null) 'codAmount': codAmount,
      if (isCodCollected != null) 'isCodCollected': isCodCollected,
      if (collectedAmount != null) 'collectedAmount': collectedAmount,
      if (codCollectedAt != null) 'codCollectedAt': Timestamp.fromDate(codCollectedAt!),
      if (codSubmittedAt != null) 'codSubmittedAt': Timestamp.fromDate(codSubmittedAt!),
      if (codReconciliationStatus != null) 'codReconciliationStatus': codReconciliationStatus,
      if (baseFare != null) 'baseFare': baseFare,
      if (distanceFare != null) 'distanceFare': distanceFare,
      if (surgeFare != null) 'surgeFare': surgeFare,
      if (incentiveAmount != null) 'incentiveAmount': incentiveAmount,
      if (bonusAmount != null) 'bonusAmount': bonusAmount,
      if (tipsAmount != null) 'tipsAmount': tipsAmount,
      if (cancellationCompensation != null) 'cancellationCompensation': cancellationCompensation,
      if (totalPartnerEarnings != null) 'totalPartnerEarnings': totalPartnerEarnings,
      if (subtotal != null) 'subtotal': subtotal,
      if (deliveryFee != null) 'deliveryFee': deliveryFee,
      if (taxAmount != null) 'taxAmount': taxAmount,
      if (discountAmount != null) 'discountAmount': discountAmount,
      if (couponCode != null) 'couponCode': couponCode,
      if (platformFee != null) 'platformFee': platformFee,
      if (sellerName != null) 'sellerName': sellerName,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (driverLat != null) 'driverLat': driverLat,
      if (driverLng != null) 'driverLng': driverLng,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'preparingAt': preparingAt != null ? Timestamp.fromDate(preparingAt!) : null,
      'readyAt': readyAt != null ? Timestamp.fromDate(readyAt!) : null,
      'goingToRestaurantAt': goingToRestaurantAt != null ? Timestamp.fromDate(goingToRestaurantAt!) : null,
      'arrivedAtStoreAt': arrivedAtStoreAt != null ? Timestamp.fromDate(arrivedAtStoreAt!) : null,
      'pickedUpAt': pickedUpAt != null ? Timestamp.fromDate(pickedUpAt!) : null,
      'outForDeliveryAt': outForDeliveryAt != null ? Timestamp.fromDate(outForDeliveryAt!) : null,
      'arrivedAtCustomerAt': arrivedAtCustomerAt != null ? Timestamp.fromDate(arrivedAtCustomerAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      if (deliveryOtp != null) 'deliveryOtp': deliveryOtp,
      if (statusHistory != null) 'statusHistory': statusHistory,
      if (proofOfDeliveryUrl != null) 'proofOfDeliveryUrl': proofOfDeliveryUrl,
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? sellerId,
    String? riderId,
    String? deliveryPartnerId,
    String? deliveryPartnerName,
    String? deliveryPartnerPhone,
    String? deliveryPartnerStatus,
    String? pickupStatus,
    OrderStatus? status,
    double? amount,
    DateTime? timestamp,
    List<OrderItemModel>? items,
    String? deliveryAddress,
    String? customerPhone,
    String? paymentMethod,
    String? paymentStatus,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    double? codAmount,
    bool? isCodCollected,
    double? collectedAmount,
    DateTime? codCollectedAt,
    DateTime? codSubmittedAt,
    String? codReconciliationStatus,
    double? baseFare,
    double? distanceFare,
    double? surgeFare,
    double? incentiveAmount,
    double? bonusAmount,
    double? tipsAmount,
    double? cancellationCompensation,
    double? totalPartnerEarnings,
    double? subtotal,
    double? deliveryFee,
    double? taxAmount,
    double? discountAmount,
    String? couponCode,
    double? platformFee,
    String? sellerName,
    String? cancellationReason,
    double? driverLat,
    double? driverLng,
    DateTime? updatedAt,
    DateTime? assignedAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? preparingAt,
    DateTime? readyAt,
    DateTime? goingToRestaurantAt,
    DateTime? arrivedAtStoreAt,
    DateTime? pickedUpAt,
    DateTime? outForDeliveryAt,
    DateTime? arrivedAtCustomerAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? deliveryOtp,
    List<Map<String, dynamic>>? statusHistory,
    String? proofOfDeliveryUrl,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      sellerId: sellerId ?? this.sellerId,
      riderId: riderId ?? this.riderId,
      deliveryPartnerId: deliveryPartnerId ?? this.deliveryPartnerId,
      deliveryPartnerName: deliveryPartnerName ?? this.deliveryPartnerName,
      deliveryPartnerPhone: deliveryPartnerPhone ?? this.deliveryPartnerPhone,
      deliveryPartnerStatus: deliveryPartnerStatus ?? this.deliveryPartnerStatus,
      pickupStatus: pickupStatus ?? this.pickupStatus,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      codAmount: codAmount ?? this.codAmount,
      isCodCollected: isCodCollected ?? this.isCodCollected,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      codCollectedAt: codCollectedAt ?? this.codCollectedAt,
      codSubmittedAt: codSubmittedAt ?? this.codSubmittedAt,
      codReconciliationStatus: codReconciliationStatus ?? this.codReconciliationStatus,
      baseFare: baseFare ?? this.baseFare,
      distanceFare: distanceFare ?? this.distanceFare,
      surgeFare: surgeFare ?? this.surgeFare,
      incentiveAmount: incentiveAmount ?? this.incentiveAmount,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      tipsAmount: tipsAmount ?? this.tipsAmount,
      cancellationCompensation: cancellationCompensation ?? this.cancellationCompensation,
      totalPartnerEarnings: totalPartnerEarnings ?? this.totalPartnerEarnings,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      couponCode: couponCode ?? this.couponCode,
      platformFee: platformFee ?? this.platformFee,
      sellerName: sellerName ?? this.sellerName,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      driverLat: driverLat ?? this.driverLat,
      driverLng: driverLng ?? this.driverLng,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedAt: assignedAt ?? this.assignedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      preparingAt: preparingAt ?? this.preparingAt,
      readyAt: readyAt ?? this.readyAt,
      goingToRestaurantAt: goingToRestaurantAt ?? this.goingToRestaurantAt,
      arrivedAtStoreAt: arrivedAtStoreAt ?? this.arrivedAtStoreAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      outForDeliveryAt: outForDeliveryAt ?? this.outForDeliveryAt,
      arrivedAtCustomerAt: arrivedAtCustomerAt ?? this.arrivedAtCustomerAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      statusHistory: statusHistory ?? this.statusHistory,
      proofOfDeliveryUrl: proofOfDeliveryUrl ?? this.proofOfDeliveryUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    customerName,
    sellerId,
    riderId,
    deliveryPartnerId,
    deliveryPartnerName,
    deliveryPartnerPhone,
    deliveryPartnerStatus,
    pickupStatus,
    status,
    amount,
    timestamp,
    items,
    deliveryAddress,
    customerPhone,
    paymentMethod,
    paymentStatus,
    razorpayOrderId,
    razorpayPaymentId,
    codAmount,
    isCodCollected,
    collectedAmount,
    codCollectedAt,
    codSubmittedAt,
    codReconciliationStatus,
    baseFare,
    distanceFare,
    surgeFare,
    incentiveAmount,
    bonusAmount,
    tipsAmount,
    cancellationCompensation,
    totalPartnerEarnings,
    subtotal,
    deliveryFee,
    taxAmount,
    discountAmount,
    couponCode,
    platformFee,
    sellerName,
    cancellationReason,
    driverLat,
    driverLng,
    updatedAt,
    assignedAt,
    acceptedAt,
    rejectedAt,
    preparingAt,
    readyAt,
    goingToRestaurantAt,
    arrivedAtStoreAt,
    pickedUpAt,
    outForDeliveryAt,
    arrivedAtCustomerAt,
    deliveredAt,
    cancelledAt,
    deliveryOtp,
    statusHistory,
    proofOfDeliveryUrl,
  ];
}
