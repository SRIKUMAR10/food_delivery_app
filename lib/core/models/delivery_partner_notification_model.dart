import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Top-level category for delivery partner notifications
enum DeliveryNotificationCategory {
  order,
  earnings,
  account,
  chat,
  all,
  unknown;

  static DeliveryNotificationCategory fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'order':
      case 'orders':
        return DeliveryNotificationCategory.order;
      case 'earnings':
      case 'earning':
      case 'payment':
      case 'wallet':
        return DeliveryNotificationCategory.earnings;
      case 'account':
      case 'profile':
      case 'verification':
        return DeliveryNotificationCategory.account;
      case 'chat':
      case 'message':
      case 'messages':
        return DeliveryNotificationCategory.chat;
      case 'all':
        return DeliveryNotificationCategory.all;
      default:
        return DeliveryNotificationCategory.unknown;
    }
  }

  String get value {
    switch (this) {
      case DeliveryNotificationCategory.order:
        return 'order';
      case DeliveryNotificationCategory.earnings:
        return 'earnings';
      case DeliveryNotificationCategory.account:
        return 'account';
      case DeliveryNotificationCategory.chat:
        return 'chat';
      case DeliveryNotificationCategory.all:
        return 'all';
      default:
        return 'unknown';
    }
  }
}

/// Detailed type for delivery partner notification operations
enum DeliveryPartnerNotificationType {
  // Order Notifications
  newDeliveryRequest,
  orderAssigned,
  orderCancelled,
  pickupReminder,
  deliveryReminder,

  // Earnings Notifications
  paymentAdded,
  bonus,
  incentive,
  withdrawalSuccess,

  // Account Notifications
  verificationApproved,
  verificationRejected,
  accountStatus,

  // Chat Notifications
  newMessage,

  unknown;

  static DeliveryPartnerNotificationType fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      // Order
      case 'new_delivery_request':
      case 'newdeliveryrequest':
      case 'new_order_request':
      case 'order_request':
        return DeliveryPartnerNotificationType.newDeliveryRequest;
      case 'order_assigned':
      case 'orderassigned':
      case 'delivery_assigned':
        return DeliveryPartnerNotificationType.orderAssigned;
      case 'order_cancelled':
      case 'ordercancelled':
      case 'delivery_cancelled':
        return DeliveryPartnerNotificationType.orderCancelled;
      case 'pickup_reminder':
      case 'pickupreminder':
        return DeliveryPartnerNotificationType.pickupReminder;
      case 'delivery_reminder':
      case 'deliveryreminder':
        return DeliveryPartnerNotificationType.deliveryReminder;

      // Earnings
      case 'payment_added':
      case 'paymentadded':
      case 'wallet_credit':
        return DeliveryPartnerNotificationType.paymentAdded;
      case 'bonus':
      case 'bonus_received':
        return DeliveryPartnerNotificationType.bonus;
      case 'incentive':
      case 'incentive_earned':
        return DeliveryPartnerNotificationType.incentive;
      case 'withdrawal_success':
      case 'withdrawalsuccess':
      case 'payout_success':
        return DeliveryPartnerNotificationType.withdrawalSuccess;

      // Account
      case 'verification_approved':
      case 'verificationapproved':
      case 'kyc_approved':
        return DeliveryPartnerNotificationType.verificationApproved;
      case 'verification_rejected':
      case 'verificationrejected':
      case 'kyc_rejected':
        return DeliveryPartnerNotificationType.verificationRejected;
      case 'account_status':
      case 'accountstatus':
        return DeliveryPartnerNotificationType.accountStatus;

      // Chat
      case 'new_message':
      case 'newmessage':
      case 'chat_message':
        return DeliveryPartnerNotificationType.newMessage;

      default:
        return DeliveryPartnerNotificationType.unknown;
    }
  }

  String get value {
    switch (this) {
      case DeliveryPartnerNotificationType.newDeliveryRequest:
        return 'new_delivery_request';
      case DeliveryPartnerNotificationType.orderAssigned:
        return 'order_assigned';
      case DeliveryPartnerNotificationType.orderCancelled:
        return 'order_cancelled';
      case DeliveryPartnerNotificationType.pickupReminder:
        return 'pickup_reminder';
      case DeliveryPartnerNotificationType.deliveryReminder:
        return 'delivery_reminder';
      case DeliveryPartnerNotificationType.paymentAdded:
        return 'payment_added';
      case DeliveryPartnerNotificationType.bonus:
        return 'bonus';
      case DeliveryPartnerNotificationType.incentive:
        return 'incentive';
      case DeliveryPartnerNotificationType.withdrawalSuccess:
        return 'withdrawal_success';
      case DeliveryPartnerNotificationType.verificationApproved:
        return 'verification_approved';
      case DeliveryPartnerNotificationType.verificationRejected:
        return 'verification_rejected';
      case DeliveryPartnerNotificationType.accountStatus:
        return 'account_status';
      case DeliveryPartnerNotificationType.newMessage:
        return 'new_message';
      default:
        return 'unknown';
    }
  }

  DeliveryNotificationCategory get category {
    switch (this) {
      case DeliveryPartnerNotificationType.newDeliveryRequest:
      case DeliveryPartnerNotificationType.orderAssigned:
      case DeliveryPartnerNotificationType.orderCancelled:
      case DeliveryPartnerNotificationType.pickupReminder:
      case DeliveryPartnerNotificationType.deliveryReminder:
        return DeliveryNotificationCategory.order;

      case DeliveryPartnerNotificationType.paymentAdded:
      case DeliveryPartnerNotificationType.bonus:
      case DeliveryPartnerNotificationType.incentive:
      case DeliveryPartnerNotificationType.withdrawalSuccess:
        return DeliveryNotificationCategory.earnings;

      case DeliveryPartnerNotificationType.verificationApproved:
      case DeliveryPartnerNotificationType.verificationRejected:
      case DeliveryPartnerNotificationType.accountStatus:
        return DeliveryNotificationCategory.account;

      case DeliveryPartnerNotificationType.newMessage:
        return DeliveryNotificationCategory.chat;

      default:
        return DeliveryNotificationCategory.unknown;
    }
  }
}

/// Delivery Partner Notification Model for Real-time Firestore & Push/In-App Notifications
class DeliveryPartnerNotificationModel extends Equatable {
  final String id;
  final String recipientId;
  final String title;
  final String body;
  final DeliveryPartnerNotificationType type;
  final DeliveryNotificationCategory category;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? priority;
  final String? actionRoute;

  const DeliveryPartnerNotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.type,
    required this.category,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.priority,
    this.actionRoute,
  });

  /// Intelligently resolves the effective category for routing and visual styling
  DeliveryNotificationCategory get effectiveCategory {
    if (category != DeliveryNotificationCategory.unknown && category != DeliveryNotificationCategory.all) {
      return category;
    }
    if (type != DeliveryPartnerNotificationType.unknown) {
      return type.category;
    }
    final text = '${title.toLowerCase()} ${body.toLowerCase()}';
    if (text.contains('order') || text.contains('delivery') || text.contains('pickup') || text.contains('drop') || data.containsKey('orderId')) {
      return DeliveryNotificationCategory.order;
    }
    if (text.contains('earning') || text.contains('payout') || text.contains('wallet') || text.contains('bonus') || text.contains('incentive') || text.contains('payment')) {
      return DeliveryNotificationCategory.earnings;
    }
    if (text.contains('message') || text.contains('chat') || text.contains('customer') || text.contains('seller')) {
      return DeliveryNotificationCategory.chat;
    }
    if (text.contains('account') || text.contains('profile') || text.contains('verify') || text.contains('kyc')) {
      return DeliveryNotificationCategory.account;
    }
    return DeliveryNotificationCategory.order;
  }

  DeliveryPartnerNotificationModel copyWith({
    String? id,
    String? recipientId,
    String? title,
    String? body,
    DeliveryPartnerNotificationType? type,
    DeliveryNotificationCategory? category,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    String? priority,
    String? actionRoute,
  }) {
    return DeliveryPartnerNotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      category: category ?? this.category,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      priority: priority ?? this.priority,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }

  factory DeliveryPartnerNotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return DeliveryPartnerNotificationModel.fromMap(data, snapshot.id);
  }

  factory DeliveryPartnerNotificationModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    final rawType = map['type'] as String?;
    final notifType = DeliveryPartnerNotificationType.fromString(rawType);
    final rawCat = map['category'] as String?;
    final notifCat = rawCat != null
        ? DeliveryNotificationCategory.fromString(rawCat)
        : notifType.category;

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return DeliveryPartnerNotificationModel(
      id: id,
      recipientId: map['recipientId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? map['message'] as String? ?? '',
      type: notifType,
      category: notifCat,
      data: map['data'] != null && map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : {},
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? parseDate(map['createdAt'])
          : (map['timestamp'] != null
              ? parseDate(map['timestamp'])
              : DateTime.now()),
      readAt: map['readAt'] != null ? parseDate(map['readAt']) : null,
      priority: map['priority'] as String? ?? 'normal',
      actionRoute: map['actionRoute'] as String? ?? map['route'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'title': title,
      'body': body,
      'type': type.value,
      'category': category.value,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      'priority': priority ?? 'normal',
      if (actionRoute != null) 'actionRoute': actionRoute,
    };
  }

  factory DeliveryPartnerNotificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DeliveryPartnerNotificationModel.fromMap(
      json,
      json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'title': title,
      'body': body,
      'type': type.value,
      'category': category.value,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'priority': priority,
      'actionRoute': actionRoute,
    };
  }

  @override
  List<Object?> get props => [
        id,
        recipientId,
        title,
        body,
        type,
        category,
        data,
        isRead,
        createdAt,
        readAt,
        priority,
        actionRoute,
      ];
}
