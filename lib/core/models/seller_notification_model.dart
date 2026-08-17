import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Top-level category for a seller notification covering all 12 business operations.
enum SellerNotificationCategory {
  newOrder,
  orderAccepted,
  orderCancelled,
  paymentUpdate,
  deliveryPartnerAssigned,
  pickupNotification,
  customerMessage,
  newReview,
  lowStock,
  outOfStock,
  payoutCompleted,
  promotional,
  system,
  unknown;

  static SellerNotificationCategory fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'new_order':
      case 'order_new':
      case 'neworder':
        return SellerNotificationCategory.newOrder;
      case 'order_accepted':
      case 'orderaccepted':
      case 'accepted':
        return SellerNotificationCategory.orderAccepted;
      case 'order_cancelled':
      case 'ordercancelled':
      case 'cancelled':
        return SellerNotificationCategory.orderCancelled;
      case 'payment_update':
      case 'payment':
      case 'paymentupdate':
      case 'wallet_credit':
        return SellerNotificationCategory.paymentUpdate;
      case 'delivery_partner_assigned':
      case 'delivery_assigned':
      case 'driver_assigned':
      case 'partner_assigned':
        return SellerNotificationCategory.deliveryPartnerAssigned;
      case 'pickup_notification':
      case 'order_picked_up':
      case 'pickup':
      case 'picked_up':
        return SellerNotificationCategory.pickupNotification;
      case 'customer_message':
      case 'chat_message':
      case 'chat':
      case 'message':
        return SellerNotificationCategory.customerMessage;
      case 'new_review':
      case 'review':
      case 'rating':
        return SellerNotificationCategory.newReview;
      case 'low_stock':
      case 'lowstock':
      case 'inventory_low':
        return SellerNotificationCategory.lowStock;
      case 'out_of_stock':
      case 'outofstock':
      case 'inventory_empty':
        return SellerNotificationCategory.outOfStock;
      case 'payout_completed':
      case 'payout_success':
      case 'payout':
        return SellerNotificationCategory.payoutCompleted;
      case 'promotional':
      case 'promo':
      case 'offer':
      case 'campaign':
        return SellerNotificationCategory.promotional;
      case 'system':
        return SellerNotificationCategory.system;
      default:
        return SellerNotificationCategory.unknown;
    }
  }

  String get value {
    switch (this) {
      case SellerNotificationCategory.newOrder:
        return 'new_order';
      case SellerNotificationCategory.orderAccepted:
        return 'order_accepted';
      case SellerNotificationCategory.orderCancelled:
        return 'order_cancelled';
      case SellerNotificationCategory.paymentUpdate:
        return 'payment_update';
      case SellerNotificationCategory.deliveryPartnerAssigned:
        return 'delivery_partner_assigned';
      case SellerNotificationCategory.pickupNotification:
        return 'pickup_notification';
      case SellerNotificationCategory.customerMessage:
        return 'customer_message';
      case SellerNotificationCategory.newReview:
        return 'new_review';
      case SellerNotificationCategory.lowStock:
        return 'low_stock';
      case SellerNotificationCategory.outOfStock:
        return 'out_of_stock';
      case SellerNotificationCategory.payoutCompleted:
        return 'payout_completed';
      case SellerNotificationCategory.promotional:
        return 'promotional';
      case SellerNotificationCategory.system:
        return 'system';
      case SellerNotificationCategory.unknown:
        return 'unknown';
    }
  }
}

/// Action to trigger when the seller taps on the notification.
enum SellerNotificationActionType {
  navigateOrder,
  navigateNewOrders,
  navigateChat,
  navigateReviews,
  navigateInventory,
  navigateWallet,
  navigatePromotions,
  none;

  static SellerNotificationActionType fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'navigate_order':
      case 'order':
      case 'orders':
        return SellerNotificationActionType.navigateOrder;
      case 'navigate_new_orders':
      case 'new_orders':
        return SellerNotificationActionType.navigateNewOrders;
      case 'navigate_chat':
      case 'chat':
        return SellerNotificationActionType.navigateChat;
      case 'navigate_reviews':
      case 'reviews':
      case 'rating':
        return SellerNotificationActionType.navigateReviews;
      case 'navigate_inventory':
      case 'inventory':
      case 'stock':
        return SellerNotificationActionType.navigateInventory;
      case 'navigate_wallet':
      case 'wallet':
      case 'payout':
        return SellerNotificationActionType.navigateWallet;
      case 'navigate_promotions':
      case 'promotions':
      case 'coupons':
        return SellerNotificationActionType.navigatePromotions;
      default:
        return SellerNotificationActionType.none;
    }
  }

  String get value {
    switch (this) {
      case SellerNotificationActionType.navigateOrder:
        return 'navigate_order';
      case SellerNotificationActionType.navigateNewOrders:
        return 'navigate_new_orders';
      case SellerNotificationActionType.navigateChat:
        return 'navigate_chat';
      case SellerNotificationActionType.navigateReviews:
        return 'navigate_reviews';
      case SellerNotificationActionType.navigateInventory:
        return 'navigate_inventory';
      case SellerNotificationActionType.navigateWallet:
        return 'navigate_wallet';
      case SellerNotificationActionType.navigatePromotions:
        return 'navigate_promotions';
      case SellerNotificationActionType.none:
        return 'none';
    }
  }
}

/// Priority tier of the notification.
enum SellerNotificationPriority {
  urgent,
  high,
  medium,
  low;

  static SellerNotificationPriority fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'urgent':
        return SellerNotificationPriority.urgent;
      case 'high':
        return SellerNotificationPriority.high;
      case 'medium':
        return SellerNotificationPriority.medium;
      case 'low':
        return SellerNotificationPriority.low;
      default:
        return SellerNotificationPriority.medium;
    }
  }

  String get value {
    switch (this) {
      case SellerNotificationPriority.urgent:
        return 'urgent';
      case SellerNotificationPriority.high:
        return 'high';
      case SellerNotificationPriority.medium:
        return 'medium';
      case SellerNotificationPriority.low:
        return 'low';
    }
  }
}

/// Immutable model representing a Seller notification document.
class SellerNotificationModel extends Equatable {
  final String id;
  final String sellerId;
  final SellerNotificationCategory category;
  final String? subType;
  final String title;
  final String? titleTa;
  final String body;
  final String? bodyTa;
  final String? orderId;
  final String? productId;
  final String? productName;
  final String? customerName;
  final String? deliveryPartnerName;
  final String? conversationId;
  final String? payoutId;
  final double? amount;
  final int? stockQuantity;
  final double? rating;
  final String? reviewComment;
  final String? imageUrl;
  final String? iconType;
  final SellerNotificationPriority priority;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final SellerNotificationActionType actionType;
  final Map<String, dynamic> actionPayload;

  const SellerNotificationModel({
    required this.id,
    required this.sellerId,
    required this.category,
    this.subType,
    required this.title,
    this.titleTa,
    required this.body,
    this.bodyTa,
    this.orderId,
    this.productId,
    this.productName,
    this.customerName,
    this.deliveryPartnerName,
    this.conversationId,
    this.payoutId,
    this.amount,
    this.stockQuantity,
    this.rating,
    this.reviewComment,
    this.imageUrl,
    this.iconType,
    this.priority = SellerNotificationPriority.medium,
    this.isRead = false,
    this.readAt,
    this.createdAt,
    this.expiresAt,
    this.actionType = SellerNotificationActionType.none,
    this.actionPayload = const <String, dynamic>{},
  });

  bool get isUnread => !isRead;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Returns localized title based on language code ('ta' for Tamil, else English)
  String getLocalizedTitle(String languageCode) {
    if (languageCode.toLowerCase() == 'ta' && titleTa != null && titleTa!.trim().isNotEmpty) {
      return titleTa!;
    }
    return title;
  }

  /// Returns localized body based on language code ('ta' for Tamil, else English)
  String getLocalizedBody(String languageCode) {
    if (languageCode.toLowerCase() == 'ta' && bodyTa != null && bodyTa!.trim().isNotEmpty) {
      return bodyTa!;
    }
    return body;
  }

  factory SellerNotificationModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return SellerNotificationModel(
      id: id,
      sellerId: (map['sellerId'] ?? map['userId'] ?? '').toString(),
      category: SellerNotificationCategory.fromString(
        map['category']?.toString() ?? map['type']?.toString(),
      ),
      subType: map['subType']?.toString(),
      title: map['title']?.toString() ?? '',
      titleTa: map['titleTa']?.toString(),
      body: map['body']?.toString() ?? '',
      bodyTa: map['bodyTa']?.toString(),
      orderId: map['orderId']?.toString(),
      productId: map['productId']?.toString(),
      productName: map['productName']?.toString(),
      customerName: map['customerName']?.toString(),
      deliveryPartnerName: (map['deliveryPartnerName'] ?? map['riderName'])?.toString(),
      conversationId: map['conversationId']?.toString(),
      payoutId: map['payoutId']?.toString(),
      amount: parseDouble(map['amount']),
      stockQuantity: parseInt(map['stockQuantity'] ?? map['quantity']),
      rating: parseDouble(map['rating']),
      reviewComment: map['reviewComment']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
      iconType: map['iconType']?.toString(),
      priority: SellerNotificationPriority.fromString(map['priority']?.toString()),
      isRead: map['isRead'] == true,
      readAt: parseDate(map['readAt']),
      createdAt: parseDate(map['createdAt']),
      expiresAt: parseDate(map['expiresAt']),
      actionType: SellerNotificationActionType.fromString(
        map['actionType']?.toString() ?? map['clickAction']?.toString(),
      ),
      actionPayload: map['actionPayload'] is Map
          ? Map<String, dynamic>.from(map['actionPayload'] as Map)
          : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'category': category.value,
      'type': category.value,
      if (subType != null) 'subType': subType,
      'title': title,
      if (titleTa != null) 'titleTa': titleTa,
      'body': body,
      if (bodyTa != null) 'bodyTa': bodyTa,
      if (orderId != null) 'orderId': orderId,
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      if (customerName != null) 'customerName': customerName,
      if (deliveryPartnerName != null) 'deliveryPartnerName': deliveryPartnerName,
      if (conversationId != null) 'conversationId': conversationId,
      if (payoutId != null) 'payoutId': payoutId,
      if (amount != null) 'amount': amount,
      if (stockQuantity != null) 'stockQuantity': stockQuantity,
      if (rating != null) 'rating': rating,
      if (reviewComment != null) 'reviewComment': reviewComment,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (iconType != null) 'iconType': iconType,
      'priority': priority.value,
      'isRead': isRead,
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      'actionType': actionType.value,
      'actionPayload': actionPayload,
    };
  }

  SellerNotificationModel copyWith({
    String? id,
    String? sellerId,
    SellerNotificationCategory? category,
    String? subType,
    String? title,
    String? titleTa,
    String? body,
    String? bodyTa,
    String? orderId,
    String? productId,
    String? productName,
    String? customerName,
    String? deliveryPartnerName,
    String? conversationId,
    String? payoutId,
    double? amount,
    int? stockQuantity,
    double? rating,
    String? reviewComment,
    String? imageUrl,
    String? iconType,
    SellerNotificationPriority? priority,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? expiresAt,
    SellerNotificationActionType? actionType,
    Map<String, dynamic>? actionPayload,
  }) {
    return SellerNotificationModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      category: category ?? this.category,
      subType: subType ?? this.subType,
      title: title ?? this.title,
      titleTa: titleTa ?? this.titleTa,
      body: body ?? this.body,
      bodyTa: bodyTa ?? this.bodyTa,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      customerName: customerName ?? this.customerName,
      deliveryPartnerName: deliveryPartnerName ?? this.deliveryPartnerName,
      conversationId: conversationId ?? this.conversationId,
      payoutId: payoutId ?? this.payoutId,
      amount: amount ?? this.amount,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      reviewComment: reviewComment ?? this.reviewComment,
      imageUrl: imageUrl ?? this.imageUrl,
      iconType: iconType ?? this.iconType,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      actionType: actionType ?? this.actionType,
      actionPayload: actionPayload ?? this.actionPayload,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sellerId,
        category,
        subType,
        title,
        titleTa,
        body,
        bodyTa,
        orderId,
        productId,
        productName,
        customerName,
        deliveryPartnerName,
        conversationId,
        payoutId,
        amount,
        stockQuantity,
        rating,
        reviewComment,
        imageUrl,
        iconType,
        priority,
        isRead,
        readAt,
        createdAt,
        expiresAt,
        actionType,
        actionPayload,
      ];
}
