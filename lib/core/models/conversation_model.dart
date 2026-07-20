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

  const ConversationModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    this.shopName,
    this.sellerImageUrl,
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
  });

  int unreadCountForUser(String userId) {
    if (userId == buyerId) return buyerUnreadCount;
    if (userId == sellerId) return sellerUnreadCount;
    return 0;
  }

  String otherParticipantName(String userId) {
    if (userId == buyerId) return sellerName;
    if (userId == sellerId) return buyerName;
    return '';
  }

  factory ConversationModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return ConversationModel(
      id: documentId,
      buyerId: map['buyerId'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      buyerName: map['buyerName'] as String? ?? 'Buyer',
      sellerName: map['sellerName'] as String? ?? 'Seller',
      shopName: map['shopName'] as String?,
      sellerImageUrl: map['sellerImageUrl'] as String?,
      productId: map['productId'] as String?,
      orderId: map['orderId'] as String?,
      orderImageUrl: map['orderImageUrl'] as String?,
      orderTitle: map['orderTitle'] as String?,
      orderTotal: (map['orderTotal'] as num?)?.toDouble(),
      lastMessage: map['lastMessage'] as String?,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp?)
          ?.toDate(),
      buyerUnreadCount: (map['buyerUnreadCount'] as num?)?.toInt() ?? 0,
      sellerUnreadCount: (map['sellerUnreadCount'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
  }) {
    return ConversationModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
      shopName: shopName ?? this.shopName,
      sellerImageUrl: sellerImageUrl ?? this.sellerImageUrl,
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
  ];
}
