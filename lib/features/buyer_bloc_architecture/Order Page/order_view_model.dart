import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../Cart Page/cart_models.dart';

class OrderViewModel extends Equatable {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime date;
  final List<CartItem> items;
  final String paymentMethod;
  final String paymentStatus;
  final String sellerId;
  final String? riderId;
  final String? deliveryAddress;
  final String? customerPhone;
  final String? customerName;
  final double? codAmount;
  final bool? isCodCollected;
  final double? discountAmount;
  final String? couponCode;
  final double? subtotal;
  final double? deliveryFee;
  final double? taxAmount;
  final double? platformFee;
  final String? sellerName;
  final String? cancellationReason;
  final DateTime? acceptedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  const OrderViewModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.date,
    required this.items,
    this.paymentMethod = 'COD',
    this.paymentStatus = 'Pending',
    this.sellerId = '',
    this.riderId,
    this.deliveryAddress,
    this.customerPhone,
    this.customerName,
    this.codAmount,
    this.isCodCollected,
    this.discountAmount,
    this.couponCode,
    this.subtotal,
    this.deliveryFee,
    this.taxAmount,
    this.platformFee,
    this.sellerName,
    this.cancellationReason,
    this.acceptedAt,
    this.preparingAt,
    this.readyAt,
    this.outForDeliveryAt,
    this.deliveredAt,
    this.cancelledAt,
  });

  /// The primary image for the order (takes the first item's image, or null).
  String? get primaryImage {
    if (items.isEmpty) return null;
    return items.first.image;
  }

  /// The title for the order (e.g. 'Burger and 2 other items')
  String get displayTitle {
    if (items.isEmpty) return 'Empty Order';
    if (items.length == 1) return items.first.name;
    return '${items.first.name} and ${items.length - 1} other items';
  }

  /// Formatted date string (e.g. 'Aug 15, 2026 • 06:30 PM')
  String get formattedDate {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  /// Check if the order is currently ongoing
  bool get isOngoing {
    final s = status.toLowerCase();
    return s != 'delivered' && s != 'cancelled' && s != 'rejected';
  }

  /// Check if the order is completed/delivered
  bool get isDelivered => status.toLowerCase() == 'delivered';

  /// Check if the order is cancelled or rejected
  bool get isCancelled {
    final s = status.toLowerCase();
    return s == 'cancelled' || s == 'rejected';
  }

  /// Check if the order can still be cancelled by the buyer (e.g. before food is prepared)
  bool get canCancel {
    final s = status.toLowerCase();
    return s == 'new' || s == 'accepted' || s == 'pending';
  }

  /// Short Order ID for clean display
  String get shortId {
    if (id.length <= 8) return id.toUpperCase();
    return id.substring(0, 8).toUpperCase();
  }

  /// Human-readable payment status string (e.g. 'Paid via Razorpay', 'COD - Pay ₹450').
  String get paymentDisplayString {
    final method = paymentMethod.toLowerCase();
    if (method == 'razorpay') return 'Paid via Razorpay';
    if (method == 'cod') {
      final amt = codAmount ?? totalAmount;
      return 'COD - Pay ₹${amt.toStringAsFixed(0)}';
    }
    if (method == 'wallet') return 'Paid via Wallet';
    final isPaid = paymentStatus.toLowerCase() == 'paid';
    return isPaid ? 'Paid' : paymentMethod;
  }

  /// Total number of items in the order.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        id,
        status,
        totalAmount,
        date,
        items,
        paymentMethod,
        paymentStatus,
        sellerId,
        riderId,
        deliveryAddress,
        customerPhone,
        customerName,
        codAmount,
        isCodCollected,
        discountAmount,
        couponCode,
        subtotal,
        deliveryFee,
        taxAmount,
        platformFee,
        sellerName,
        cancellationReason,
        acceptedAt,
        preparingAt,
        readyAt,
        outForDeliveryAt,
        deliveredAt,
        cancelledAt,
      ];
}

