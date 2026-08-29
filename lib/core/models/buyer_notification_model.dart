import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../utils/app_date_formatter.dart';

/// Top-level category for a buyer notification.
enum BuyerNotificationCategory {
  orderUpdate,
  paymentStatus,
  offerPromo,
  chatMessage,
  driverTracking,
  reviewReminder,
  securityAlert,
  system,
  unknown;

  static BuyerNotificationCategory fromString(String? raw) {
    final clean = (raw ?? '').trim().toLowerCase();
    switch (clean) {
      case 'order_update':
      case 'order':
      case 'orders':
      case 'order_status':
      case 'delivery':
      case 'delivered':
      case 'out_for_delivery':
      case 'picked_up':
      case 'confirmed':
        return BuyerNotificationCategory.orderUpdate;
      case 'payment_status':
      case 'payment':
      case 'payments':
      case 'wallet':
      case 'refund':
      case 'cashback':
      case 'transaction':
      case 'paid':
        return BuyerNotificationCategory.paymentStatus;
      case 'offer_promo':
      case 'offer':
      case 'offers':
      case 'promo':
      case 'promotion':
      case 'discount':
      case 'coupon':
      case 'deal':
        return BuyerNotificationCategory.offerPromo;
      case 'chat_message':
      case 'chat':
      case 'chats':
      case 'message':
      case 'messages':
      case 'store':
      case 'restaurant':
      case 'seller':
      case 'vendor':
      case 'rider':
      case 'support':
        return BuyerNotificationCategory.chatMessage;
      case 'driver_tracking':
      case 'tracking':
      case 'live_tracking':
        return BuyerNotificationCategory.driverTracking;
      case 'review_reminder':
      case 'review':
      case 'reviews':
      case 'rating':
      case 'ratings':
      case 'feedback':
        return BuyerNotificationCategory.reviewReminder;
      case 'security_alert':
      case 'security':
      case 'alert':
      case 'alerts':
      case 'warning':
        return BuyerNotificationCategory.securityAlert;
      case 'system':
      case 'general':
      case 'info':
        return BuyerNotificationCategory.system;
      default:
        return BuyerNotificationCategory.unknown;
    }
  }

  String get value {
    switch (this) {
      case BuyerNotificationCategory.orderUpdate:
        return 'order_update';
      case BuyerNotificationCategory.paymentStatus:
        return 'payment_status';
      case BuyerNotificationCategory.offerPromo:
        return 'offer_promo';
      case BuyerNotificationCategory.chatMessage:
        return 'chat_message';
      case BuyerNotificationCategory.driverTracking:
        return 'driver_tracking';
      case BuyerNotificationCategory.reviewReminder:
        return 'review_reminder';
      case BuyerNotificationCategory.securityAlert:
        return 'security_alert';
      case BuyerNotificationCategory.system:
        return 'system';
      case BuyerNotificationCategory.unknown:
        return 'unknown';
    }
  }
}

/// What happens when the user taps the primary action of a notification.
enum BuyerNotificationActionType {
  navigateTrackOrder,
  navigateOrder,
  navigateChat,
  navigateCart,
  navigateWallet,
  applyCoupon,
  navigateDetails,
  openRating,
  none;

  static BuyerNotificationActionType fromString(String? raw) {
    final clean = (raw ?? '').trim().toLowerCase();
    switch (clean) {
      case 'navigate_track_order':
      case 'track_order':
      case 'track':
      case 'tracking':
        return BuyerNotificationActionType.navigateTrackOrder;
      case 'navigate_order':
      case 'order':
      case 'orders':
      case 'view_order':
        return BuyerNotificationActionType.navigateOrder;
      case 'navigate_chat':
      case 'chat':
      case 'chats':
      case 'message':
      case 'reply':
      case 'store':
        return BuyerNotificationActionType.navigateChat;
      case 'navigate_cart':
      case 'cart':
      case 'view_cart':
        return BuyerNotificationActionType.navigateCart;
      case 'navigate_wallet':
      case 'wallet':
      case 'payments':
      case 'payment':
        return BuyerNotificationActionType.navigateWallet;
      case 'apply_coupon':
      case 'coupon':
      case 'offer':
      case 'promo':
        return BuyerNotificationActionType.applyCoupon;
      case 'navigate_details':
      case 'details':
      case 'view':
        return BuyerNotificationActionType.navigateDetails;
      case 'open_rating':
      case 'rating':
      case 'review':
        return BuyerNotificationActionType.openRating;
      default:
        return BuyerNotificationActionType.none;
    }
  }

  String get value {
    switch (this) {
      case BuyerNotificationActionType.navigateTrackOrder:
        return 'navigate_track_order';
      case BuyerNotificationActionType.navigateOrder:
        return 'navigate_order';
      case BuyerNotificationActionType.navigateChat:
        return 'navigate_chat';
      case BuyerNotificationActionType.navigateCart:
        return 'navigate_cart';
      case BuyerNotificationActionType.navigateWallet:
        return 'navigate_wallet';
      case BuyerNotificationActionType.applyCoupon:
        return 'apply_coupon';
      case BuyerNotificationActionType.navigateDetails:
        return 'navigate_details';
      case BuyerNotificationActionType.openRating:
        return 'open_rating';
      case BuyerNotificationActionType.none:
        return 'none';
    }
  }
}

enum BuyerNotificationPriority {
  high,
  medium,
  low;

  static BuyerNotificationPriority fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'high':
        return BuyerNotificationPriority.high;
      case 'low':
        return BuyerNotificationPriority.low;
      default:
        return BuyerNotificationPriority.medium;
    }
  }

  String get value => name;
}

/// Immutable buyer notification read from
/// `buyer_user/{uid}/notifications/{notificationId}`.
class BuyerNotificationModel extends Equatable {
  final String id;
  final String userId;
  final BuyerNotificationCategory category;
  final String? subType;
  final String title;
  final String? titleTa;
  final String body;
  final String? bodyTa;
  final String? orderId;
  final String? conversationId;
  final String? couponCode;
  final String? productId;
  final String? imageUrl;
  final String? iconType;
  final BuyerNotificationPriority priority;
  final bool isRead;
  final BuyerNotificationActionType actionType;
  final Map<String, dynamic> actionPayload;
  final DateTime? createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt;

  const BuyerNotificationModel({
    required this.id,
    required this.userId,
    required this.category,
    this.subType,
    required this.title,
    this.titleTa,
    required this.body,
    this.bodyTa,
    this.orderId,
    this.conversationId,
    this.couponCode,
    this.productId,
    this.imageUrl,
    this.iconType,
    this.priority = BuyerNotificationPriority.medium,
    this.isRead = false,
    this.actionType = BuyerNotificationActionType.none,
    this.actionPayload = const {},
    this.createdAt,
    this.readAt,
    this.expiresAt,
  });

  bool get isUnread => !isRead;

  /// Returns the title in the requested language. Falls back to English.
  String localizedTitle(String languageCode) {
    if (languageCode == 'ta' && (titleTa ?? '').isNotEmpty) {
      return titleTa!;
    }
    return title;
  }

  /// Returns the body in the requested language. Falls back to English.
  String localizedBody(String languageCode) {
    if (languageCode == 'ta' && (bodyTa ?? '').isNotEmpty) {
      return bodyTa!;
    }
    return body;
  }

  /// Relative human readable timestamp, e.g. "Just now", "2m ago", "1h ago", or "dd MMM, yyyy".
  String get timeAgo {
    return AppDateFormatter.formatTimeAgo(createdAt ?? DateTime.now());
  }

  /// Resolves the effective category intelligently even if category is unspecified/unknown in Firestore.
  BuyerNotificationCategory get effectiveCategory {
    if (category != BuyerNotificationCategory.unknown) {
      return category;
    }
    if (orderId != null && orderId!.isNotEmpty) {
      return BuyerNotificationCategory.orderUpdate;
    }
    if (conversationId != null && conversationId!.isNotEmpty) {
      return BuyerNotificationCategory.chatMessage;
    }
    if (couponCode != null && couponCode!.isNotEmpty) {
      return BuyerNotificationCategory.offerPromo;
    }
    if (productId != null && productId!.isNotEmpty) {
      return BuyerNotificationCategory.reviewReminder;
    }
    final text = '$title $body ${subType ?? ''}'.toLowerCase();
    if (text.contains('order') || text.contains('delivery') || text.contains('driver') || text.contains('track')) {
      return BuyerNotificationCategory.orderUpdate;
    }
    if (text.contains('store') || text.contains('chat') || text.contains('message') || text.contains('seller') || text.contains('support') || text.contains('rider')) {
      return BuyerNotificationCategory.chatMessage;
    }
    if (text.contains('wallet') || text.contains('payment') || text.contains('refund') || text.contains('cashback') || text.contains('paid')) {
      return BuyerNotificationCategory.paymentStatus;
    }
    if (text.contains('offer') || text.contains('promo') || text.contains('coupon') || text.contains('discount') || text.contains('deal') || text.contains('% off')) {
      return BuyerNotificationCategory.offerPromo;
    }
    if (text.contains('review') || text.contains('rate') || text.contains('feedback') || text.contains('star')) {
      return BuyerNotificationCategory.reviewReminder;
    }
    return BuyerNotificationCategory.unknown;
  }

  /// Resolves the effective action type to ensure every notification navigates to the right page on tap.
  BuyerNotificationActionType get effectiveActionType {
    if (actionType != BuyerNotificationActionType.none) {
      return actionType;
    }
    switch (effectiveCategory) {
      case BuyerNotificationCategory.orderUpdate:
      case BuyerNotificationCategory.driverTracking:
        return (orderId != null && orderId!.isNotEmpty)
            ? BuyerNotificationActionType.navigateTrackOrder
            : BuyerNotificationActionType.navigateOrder;
      case BuyerNotificationCategory.chatMessage:
        return BuyerNotificationActionType.navigateChat;
      case BuyerNotificationCategory.paymentStatus:
        return BuyerNotificationActionType.navigateWallet;
      case BuyerNotificationCategory.offerPromo:
        return (couponCode != null && couponCode!.isNotEmpty)
            ? BuyerNotificationActionType.applyCoupon
            : BuyerNotificationActionType.navigateCart;
      case BuyerNotificationCategory.reviewReminder:
        return BuyerNotificationActionType.openRating;
      case BuyerNotificationCategory.securityAlert:
      case BuyerNotificationCategory.system:
      case BuyerNotificationCategory.unknown:
        final text = '$title $body'.toLowerCase();
        if (text.contains('order') || text.contains('delivery')) {
          return BuyerNotificationActionType.navigateOrder;
        }
        if (text.contains('store') || text.contains('chat') || text.contains('message') || text.contains('support')) {
          return BuyerNotificationActionType.navigateChat;
        }
        if (text.contains('wallet') || text.contains('payment') || text.contains('refund')) {
          return BuyerNotificationActionType.navigateWallet;
        }
        if (text.contains('coupon') || text.contains('offer') || text.contains('discount')) {
          return BuyerNotificationActionType.navigateCart;
        }
        return BuyerNotificationActionType.navigateDetails;
    }
  }

  /// Returns true if the notification is expired and should be hidden.
  bool get isExpired {
    final expires = expiresAt;
    if (expires == null) return false;
    return DateTime.now().isAfter(expires);
  }

  factory BuyerNotificationModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    final rawPayload = map['actionPayload'];
    final payload = rawPayload is Map ? Map<String, dynamic>.from(rawPayload) : <String, dynamic>{};
    final rawCategory = (map['category'] ?? map['type'] ?? map['notificationType']) as String?;
    final rawAction = (map['actionType'] ?? map['action'] ?? map['clickAction'] ?? map['route']) as String?;

    return BuyerNotificationModel(
      id: documentId,
      userId: (map['userId'] ?? map['buyerId'] ?? map['recipientId'] ?? '').toString(),
      category: BuyerNotificationCategory.fromString(rawCategory),
      subType: map['subType'] as String?,
      title: map['title'] as String? ?? '',
      titleTa: map['titleTa'] as String?,
      body: (map['body'] ?? map['message']) as String? ?? '',
      bodyTa: (map['bodyTa'] ?? map['messageTa']) as String?,
      orderId: (map['orderId'] ?? payload['orderId'])?.toString(),
      conversationId: (map['conversationId'] ?? payload['conversationId'] ?? payload['chatId'])?.toString(),
      couponCode: (map['couponCode'] ?? payload['couponCode'] ?? payload['coupon'])?.toString(),
      productId: (map['productId'] ?? payload['productId'] ?? payload['foodId'])?.toString(),
      imageUrl: (map['imageUrl'] ?? map['image']) as String?,
      iconType: map['iconType'] as String?,
      priority: BuyerNotificationPriority.fromString(map['priority'] as String?),
      isRead: map['isRead'] as bool? ?? false,
      actionType: BuyerNotificationActionType.fromString(rawAction),
      actionPayload: payload,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ??
          (map['timestamp'] is Timestamp ? (map['timestamp'] as Timestamp).toDate() : null),
      readAt: (map['readAt'] as Timestamp?)?.toDate(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category.value,
      'subType': subType,
      'title': title,
      'titleTa': titleTa,
      'body': body,
      'bodyTa': bodyTa,
      'orderId': orderId,
      'conversationId': conversationId,
      'couponCode': couponCode,
      'productId': productId,
      'imageUrl': imageUrl,
      'iconType': iconType,
      'priority': priority.value,
      'isRead': isRead,
      'actionType': actionType.value,
      'actionPayload': actionPayload,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
    };
  }

  BuyerNotificationModel copyWith({
    String? id,
    String? userId,
    BuyerNotificationCategory? category,
    String? title,
    String? titleTa,
    String? body,
    String? bodyTa,
    bool? isRead,
    DateTime? readAt,
  }) {
    return BuyerNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      subType: subType,
      title: title ?? this.title,
      titleTa: titleTa ?? this.titleTa,
      body: body ?? this.body,
      bodyTa: bodyTa ?? this.bodyTa,
      orderId: orderId,
      conversationId: conversationId,
      couponCode: couponCode,
      productId: productId,
      imageUrl: imageUrl,
      iconType: iconType,
      priority: priority,
      isRead: isRead ?? this.isRead,
      actionType: actionType,
      actionPayload: actionPayload,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        category,
        subType,
        title,
        titleTa,
        body,
        bodyTa,
        orderId,
        conversationId,
        couponCode,
        productId,
        imageUrl,
        iconType,
        priority,
        isRead,
        actionType,
        actionPayload,
        createdAt,
        readAt,
        expiresAt,
      ];
}
