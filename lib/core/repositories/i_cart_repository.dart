import '../../features/buyer_bloc_architecture/Cart Page/cart_models.dart';

abstract interface class ICartRepository {
  Stream<List<CartItem>> getCartItemsStream(String buyerId);
  Future<void> addItem(String buyerId, CartItem item);
  Future<void> removeItem(String buyerId, String itemId);
  Future<void> updateQuantity(String buyerId, String itemId, int delta);
  Future<void> toggleSelection(String buyerId, String itemId, bool isSelected);
  Future<void> clearCart(String buyerId);
  Future<void> updateItemPrice(String buyerId, String itemId, double newPrice);
  Future<void> checkoutCart(
    String buyerId,
    List<CartItem> selectedItems,
    String customerName,
    String deliveryAddress, {
    String? customerPhone,
    AppliedCoupon? appliedCoupon,
    String paymentMethod = 'COD',
  });

  Future<void> verifyAndCheckoutRazorpay({
    required String buyerId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required List<CartItem> selectedItems,
    required String customerName,
    required String deliveryAddress,
    String? customerPhone,
    AppliedCoupon? appliedCoupon,
  });
}
