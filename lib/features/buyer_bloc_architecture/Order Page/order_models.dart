import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../Cart Page/cart_models.dart';

class OrderModel extends Equatable {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime date;
  final List<CartItem> items;

  const OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.date,
    required this.items,
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

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse items
    final List<dynamic> itemsData = data['items'] ?? [];
    final items = itemsData.map((itemData) {
      return CartItem(
        id: itemData['id'] ?? '',
        name: itemData['name'] ?? 'Unknown',
        price: (itemData['price'] as num?)?.toDouble() ?? 0.0,
        sellerId: itemData['sellerId'] ?? '',
        image: itemData['image'],
        quantity: (itemData['quantity'] as num?)?.toInt() ?? 1,
      );
    }).toList();

    return OrderModel(
      id: doc.id,
      status: data['status'] ?? 'Pending',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'totalAmount': totalAmount,
      'date': Timestamp.fromDate(date),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, status, totalAmount, date, items];
}
