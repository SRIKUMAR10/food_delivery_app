import '../../../../core/models/order_model.dart';
import '../Cart Page/cart_models.dart';
import 'order_view_model.dart';

class OrderMapper {
  static OrderViewModel toViewModel(OrderModel domainOrder) {
    // Map Domain OrderItemModel to UI CartItem (since UI heavily uses CartItem)
    final items = domainOrder.items?.map((item) {
          return CartItem(
            id: item.productId,
            name: item.name,
            price: item.price,
            sellerId: domainOrder.sellerId,
            image: item.imageUrl,
            imageUrls: item.imageUrl != null ? [item.imageUrl!] : [],
            quantity: item.quantity,
          );
        }).toList() ??
        [];

    return OrderViewModel(
      id: domainOrder.id,
      status: domainOrder.status.value,
      totalAmount: domainOrder.amount,
      date: domainOrder.timestamp,
      items: items,
    );
  }
}
