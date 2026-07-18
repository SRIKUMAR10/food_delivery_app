import '../../features/buyer_bloc_architecture/Cart Page/cart_models.dart';

abstract interface class ICartRepository {
  Stream<List<CartItem>> getCartItemsStream(String buyerId);
  Future<void> addItem(String buyerId, CartItem item);
  Future<void> removeItem(String buyerId, String itemId);
  Future<void> updateQuantity(String buyerId, String itemId, int delta);
  Future<void> toggleSelection(String buyerId, String itemId, bool isSelected);
  Future<void> clearCart(String buyerId);
  Future<void> checkoutCart(String buyerId, List<CartItem> selectedItems, String customerName);
}
