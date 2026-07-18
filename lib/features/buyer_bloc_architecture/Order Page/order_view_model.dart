import 'package:equatable/equatable.dart';
import '../Cart Page/cart_models.dart';

class OrderViewModel extends Equatable {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime date;
  final List<CartItem> items;

  const OrderViewModel({
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

  @override
  List<Object?> get props => [id, status, totalAmount, date, items];
}
