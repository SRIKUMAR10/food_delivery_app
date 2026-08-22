import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ConversationModel extends Equatable {
  final String id;
  final String buyerId;
  final String sellerId;
  final String buyerName;
  final String sellerName;
  final String? shopName;
  final String? sellerImageUrl;
  final String? sellerPhone;
  final String? productId;
  final String? orderId;
  final String? orderImageUrl;
  final String? orderTitle;
  final double? orderTotal;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTimestamp;
  final int buyerUnreadCount;
  final int sellerUnreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Multi-party chat fields
  final String? deliveryPartnerId;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String? deliveryPartnerImageUrl;
  final int deliveryUnreadCount;
  final String conversationType; // buyer_seller | buyer_delivery | seller_delivery
  final List<String> participants;
  final Map<String, String> participantRoles;

  const ConversationModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    this.shopName,
    this.sellerImageUrl,
    this.sellerPhone,
    this.productId,
    this.orderId,
    this.orderImageUrl,
    this.orderTitle,
    this.orderTotal,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTimestamp,
    this.buyerUnreadCount = 0,
    this.sellerUnreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryPartnerId,
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    this.deliveryPartnerImageUrl,
    this.deliveryUnreadCount = 0,
    this.conversationType = 'buyer_seller',
    this.participants = const [],
    this.participantRoles = const {},
  });

  bool get isDeliveryChat =>
      conversationType == 'buyer_delivery' ||
      conversationType == 'seller_delivery' ||
      (deliveryPartnerId != null && deliveryPartnerId!.isNotEmpty);

  int unreadCountForUser(String userId, {String? role}) {
    if (userId == buyerId) return buyerUnreadCount;
    if (userId == sellerId) return sellerUnreadCount;
    if (userId == deliveryPartnerId) return deliveryUnreadCount;
    return 0;
  }

  String otherParticipantName(String userId) {
    if (userId == buyerId) {
      if (isDeliveryChat && (sellerId.isEmpty || sellerId == deliveryPartnerId)) {
        return deliveryPartnerName ?? 'Delivery Partner';
      }
      return sellerName;
    }
    if (userId == sellerId) return buyerName;
    if (userId == deliveryPartnerId) return buyerName;
    return '';
  }

  String otherParticipantRole(String userId) {
    if (userId == buyerId) {
      if (isDeliveryChat && (sellerId.isEmpty || sellerId == deliveryPartnerId)) {
        return 'delivery_partner';
      }
      return 'seller';
    }
    if (userId == sellerId) return 'buyer';
    if (userId == deliveryPartnerId) return 'buyer';
    return '';
  }

  String? otherParticipantId(String userId) {
    if (userId == buyerId) {
      if (isDeliveryChat &&
          (sellerId.isEmpty || sellerId == deliveryPartnerId)) {
        return deliveryPartnerId;
      }
      return sellerId;
    }
    if (userId == sellerId) return buyerId;
    if (userId == deliveryPartnerId) return buyerId;
    return null;
  }

  factory ConversationModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    final buyerId = map['buyerId'] as String? ??
        map['customerId'] as String? ??
        map['userId'] as String? ??
        '';
    final sellerId = map['sellerId'] as String? ??
        map['merchantId'] as String? ??
        map['restaurantId'] as String? ??
        '';
    final deliveryPartnerId = map['deliveryPartnerId'] as String? ??
        map['riderId'] as String? ??
        map['driverId'] as String? ??
        map['delivery_partner_id'] as String? ??
        map['partnerId'] as String?;

    List<String> participants;
    if (map['participants'] is List) {
      participants = List<String>.from(map['participants'] as List);
    } else {
      participants = <String>[
        if (buyerId.isNotEmpty) buyerId,
        if (sellerId.isNotEmpty) sellerId,
        if (deliveryPartnerId != null && deliveryPartnerId.isNotEmpty)
          deliveryPartnerId,
      ];
    }

    final rawRoles = map['participantRoles'] as Map?;
    final participantRoles = rawRoles != null
        ? Map<String, String>.from(rawRoles.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ))
        : <String, String>{};

    String? resolvedShopName = map['shopName'] as String? ??
        map['restaurantName'] as String? ??
        map['storeName'] as String? ??
        map['sellerShopName'] as String? ??
        map['restaurant'] as String? ??
        map['store'] as String?;

    if (resolvedShopName == null || resolvedShopName.isEmpty || resolvedShopName == 'Store Support') {
      if (map['seller'] is Map) {
        final sMap = map['seller'] as Map;
        resolvedShopName = (sMap['shopName'] ?? sMap['restaurantName'] ?? sMap['name'] ?? sMap['storeName']) as String?;
      }
    }

    String resolvedSellerName = map['sellerName'] as String? ??
        map['restaurantName'] as String? ??
        resolvedShopName ??
        '';

    if (resolvedSellerName.isEmpty || resolvedSellerName == 'Store' || resolvedSellerName == 'Store Support') {
      resolvedSellerName = resolvedShopName ?? 'Ahbi food restaurants';
    }
    if (resolvedShopName == null || resolvedShopName.isEmpty || resolvedShopName == 'Store Support') {
      resolvedShopName = resolvedSellerName;
    }
    final resolvedSellerImage = map['sellerImageUrl'] as String? ??
        map['restaurantImage'] as String? ??
        map['storeImage'] as String? ??
        map['sellerImage'] as String? ??
        map['logoUrl'] as String?;
    final resolvedSellerPhone = map['sellerPhone'] as String? ??
        map['restaurantPhone'] as String? ??
        map['storePhone'] as String? ??
        map['phone'] as String? ??
        map['phoneNumber'] as String?;
    String resolvedBuyerName = map['buyerName'] as String? ??
        map['customerName'] as String? ??
        map['buyer_name'] as String? ??
        map['customer_name'] as String? ??
        map['userName'] as String? ??
        map['user_name'] as String? ??
        map['name'] as String? ??
        map['fullName'] as String? ??
        map['full_name'] as String? ??
        map['senderName'] as String? ??
        '';

    if (resolvedBuyerName.isEmpty || resolvedBuyerName.toLowerCase() == 'customer') {
      if (map['buyer'] is Map) {
        final bMap = map['buyer'] as Map;
        resolvedBuyerName = (bMap['name'] ?? bMap['fullName'] ?? bMap['userName'] ?? bMap['buyerName']) as String? ?? '';
      } else if (map['customer'] is Map) {
        final cMap = map['customer'] as Map;
        resolvedBuyerName = (cMap['name'] ?? cMap['fullName'] ?? cMap['userName'] ?? cMap['customerName']) as String? ?? '';
      }
    }

    if (resolvedBuyerName.isEmpty || resolvedBuyerName.toLowerCase() == 'customer') {
      resolvedBuyerName = 'Anu';
    }

    return ConversationModel(
      id: documentId,
      buyerId: buyerId,
      sellerId: sellerId,
      buyerName: resolvedBuyerName,
      sellerName: resolvedSellerName,
      shopName: resolvedShopName,
      sellerImageUrl: resolvedSellerImage,
      sellerPhone: resolvedSellerPhone,
      productId: map['productId'] as String?,
      orderId: map['orderId'] as String?,
      orderImageUrl: map['orderImageUrl'] as String? ?? map['itemImageUrl'] as String?,
      orderTitle: map['orderTitle'] as String? ?? map['productName'] as String? ?? map['itemName'] as String?,
      orderTotal: (map['orderTotal'] as num?)?.toDouble() ?? (map['totalAmount'] as num?)?.toDouble(),
      lastMessage: map['lastMessage'] as String?,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp?)
          ?.toDate(),
      buyerUnreadCount: (map['buyerUnreadCount'] as num?)?.toInt() ?? 0,
      sellerUnreadCount: (map['sellerUnreadCount'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryPartnerId: deliveryPartnerId,
      deliveryPartnerName: map['deliveryPartnerName'] as String? ??
          map['riderName'] as String? ??
          map['driverName'] as String?,
      deliveryPartnerPhone: map['deliveryPartnerPhone'] as String? ??
          map['riderPhone'] as String? ??
          map['driverPhone'] as String?,
      deliveryPartnerImageUrl: map['deliveryPartnerImageUrl'] as String? ??
          map['riderImageUrl'] as String?,
      deliveryUnreadCount: (map['deliveryUnreadCount'] as num?)?.toInt() ?? 0,
      conversationType: map['conversationType'] as String? ?? 'buyer_seller',
      participants: participants,
      participantRoles: participantRoles,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'shopName': shopName,
      'sellerImageUrl': sellerImageUrl,
      'sellerPhone': sellerPhone,
      'productId': productId,
      'orderId': orderId,
      'orderImageUrl': orderImageUrl,
      'orderTitle': orderTitle,
      'orderTotal': orderTotal,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTimestamp': lastMessageTimestamp != null
          ? Timestamp.fromDate(lastMessageTimestamp!)
          : null,
      'buyerUnreadCount': buyerUnreadCount,
      'sellerUnreadCount': sellerUnreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deliveryPartnerId': deliveryPartnerId,
      'deliveryPartnerName': deliveryPartnerName,
      'deliveryPartnerPhone': deliveryPartnerPhone,
      'deliveryPartnerImageUrl': deliveryPartnerImageUrl,
      'deliveryUnreadCount': deliveryUnreadCount,
      'conversationType': conversationType,
      'participants': participants,
      'participantRoles': participantRoles,
    };
  }

  ConversationModel copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    String? buyerName,
    String? sellerName,
    String? shopName,
    String? sellerImageUrl,
    String? sellerPhone,
    String? productId,
    String? orderId,
    String? orderImageUrl,
    String? orderTitle,
    double? orderTotal,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTimestamp,
    int? buyerUnreadCount,
    int? sellerUnreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deliveryPartnerId,
    String? deliveryPartnerName,
    String? deliveryPartnerPhone,
    String? deliveryPartnerImageUrl,
    int? deliveryUnreadCount,
    String? conversationType,
    List<String>? participants,
    Map<String, String>? participantRoles,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
      shopName: shopName ?? this.shopName,
      sellerImageUrl: sellerImageUrl ?? this.sellerImageUrl,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      orderImageUrl: orderImageUrl ?? this.orderImageUrl,
      orderTitle: orderTitle ?? this.orderTitle,
      orderTotal: orderTotal ?? this.orderTotal,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      buyerUnreadCount: buyerUnreadCount ?? this.buyerUnreadCount,
      sellerUnreadCount: sellerUnreadCount ?? this.sellerUnreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryPartnerId: deliveryPartnerId ?? this.deliveryPartnerId,
      deliveryPartnerName: deliveryPartnerName ?? this.deliveryPartnerName,
      deliveryPartnerPhone: deliveryPartnerPhone ?? this.deliveryPartnerPhone,
      deliveryPartnerImageUrl:
          deliveryPartnerImageUrl ?? this.deliveryPartnerImageUrl,
      deliveryUnreadCount: deliveryUnreadCount ?? this.deliveryUnreadCount,
      conversationType: conversationType ?? this.conversationType,
      participants: participants ?? this.participants,
      participantRoles: participantRoles ?? this.participantRoles,
    );
  }

  @override
  List<Object?> get props => [
    id,
    buyerId,
    sellerId,
    buyerName,
    sellerName,
    shopName,
    sellerImageUrl,
    sellerPhone,
    productId,
    orderId,
    orderImageUrl,
    orderTitle,
    orderTotal,
    lastMessage,
    lastMessageSenderId,
    lastMessageTimestamp,
    buyerUnreadCount,
    sellerUnreadCount,
    createdAt,
    updatedAt,
    deliveryPartnerId,
    deliveryPartnerName,
    deliveryPartnerPhone,
    deliveryPartnerImageUrl,
    deliveryUnreadCount,
    conversationType,
    participants,
    participantRoles,
  ];
}
