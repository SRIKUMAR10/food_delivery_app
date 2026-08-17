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
            selectedAddons: item.selectedAddons,
          );
        }).toList() ??
        [];

    return OrderViewModel(
      id: domainOrder.id,
      status: domainOrder.status.value,
      totalAmount: domainOrder.amount,
      date: domainOrder.timestamp,
      items: items,
      paymentMethod: domainOrder.paymentMethod ?? 'COD',
      paymentStatus: domainOrder.paymentStatus ?? 'Pending',
      sellerId: domainOrder.sellerId,
      riderId: domainOrder.riderId,
      deliveryAddress: domainOrder.deliveryAddress,
      customerPhone: domainOrder.customerPhone,
      customerName: domainOrder.customerName,
      codAmount: domainOrder.codAmount,
      isCodCollected: domainOrder.isCodCollected,
      discountAmount: domainOrder.discountAmount,
      couponCode: domainOrder.couponCode,
      subtotal: domainOrder.subtotal,
      deliveryFee: domainOrder.deliveryFee,
      taxAmount: domainOrder.taxAmount,
      platformFee: domainOrder.platformFee,
      sellerName: domainOrder.sellerName,
      cancellationReason: domainOrder.cancellationReason,
      acceptedAt: domainOrder.acceptedAt,
      preparingAt: domainOrder.preparingAt,
      readyAt: domainOrder.readyAt,
      outForDeliveryAt: domainOrder.outForDeliveryAt,
      deliveredAt: domainOrder.deliveredAt,
      cancelledAt: domainOrder.cancelledAt,
    );
  }
}

