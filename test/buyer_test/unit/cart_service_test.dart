import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_models.dart';

// --- Blueprint Classes ---
// CartService handles complex business logic (e.g., calculating totals, applying discounts)
class CartService {
  double calculateTotal(List<CartItem> items) {
    return items.fold(0.0, (total, item) {
      if (item.isSelected) {
        return total + (item.price * item.quantity);
      }
      return total;
    });
  }
}

void main() {
  group('CartService Unit Tests (Blueprint)', () {
    late CartService cartService;

    setUp(() {
      cartService = CartService();
    });

    test('calculateTotal calculates correctly for selected items', () {
      final items = [
        CartItem(
          id: '1',
          name: 'A',
          price: 100.0,
          sellerId: 's1',
          quantity: 2,
          isSelected: true,
        ),
        CartItem(
          id: '2',
          name: 'B',
          price: 50.0,
          sellerId: 's1',
          quantity: 1,
          isSelected: false,
        ),
      ];

      final total = cartService.calculateTotal(items);
      expect(total, 200.0); // Only item A is selected
    });

    test('calculateTotal returns 0.0 for empty cart', () {
      final total = cartService.calculateTotal([]);
      expect(total, 0.0);
    });
  });
}
