import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';

void main() {
  group('Buyer Flow - CartItem Model', () {
    test('creates with correct defaults', () {
      final item = CartItem(
        id: 'prod-1',
        name: 'Test Item',
        price: 99.99,
        sellerId: 'seller-1',
        quantity: 3,
        isSelected: true,
      );

      expect(item.id, equals('prod-1'));
      expect(item.name, equals('Test Item'));
      expect(item.price, equals(99.99));
      expect(item.quantity, equals(3));
      expect(item.sellerId, equals('seller-1'));
      expect(item.isSelected, isTrue);
      expect(item.image, isNull);
      expect(item.imageUrls, isEmpty);
      expect(item.selectedAddons, isEmpty);
    });

    test('copyWith updates fields', () {
      final item = CartItem(
        id: 'prod-1', name: 'Original', price: 100.0,
        sellerId: 's1', quantity: 1,
      );

      final updated = item.copyWith(quantity: 5, isSelected: false);
      expect(updated.quantity, equals(5));
      expect(updated.isSelected, isFalse);
      expect(updated.name, equals('Original'));
    });

    test('toMap produces correct map', () {
      final item = CartItem(
        id: 'prod-1', name: 'Item', price: 50.0,
        sellerId: 's1', quantity: 2, isSelected: true,
      );
      final map = item.toMap();

      expect(map['name'], equals('Item'));
      expect(map['price'], equals(50.0));
      expect(map['quantity'], equals(2));
      expect(map['sellerId'], equals('s1'));
      expect(map['isSelected'], isTrue);
    });

    test('quantity * price calculation is correct', () {
      final item = CartItem(
        id: 'p1', name: 'Item', price: 100.0, sellerId: 's1', quantity: 3,
      );
      expect(item.price * item.quantity, equals(300.0));
    });
  });

  group('Buyer Flow - FavoriteItem Model', () {
    test('creates with correct fields', () {
      final item = FavoriteItem(
        id: 'fav-1',
        name: 'Fav Item',
        price: 120.0,
        description: 'Tasty food',
        sellerId: 'seller-1',
        image: 'img.png',
      );

      expect(item.id, equals('fav-1'));
      expect(item.name, equals('Fav Item'));
      expect(item.image, equals('img.png'));
      expect(item.description, equals('Tasty food'));
    });

    test('equatable props work correctly', () {
      final item1 = FavoriteItem(
        id: 'fav-1', name: 'Item', price: 120.0,
        description: 'Desc', sellerId: 'seller-1',
      );
      final item2 = FavoriteItem(
        id: 'fav-1', name: 'Item', price: 120.0,
        description: 'Desc', sellerId: 'seller-1',
      );

      expect(item1, equals(item2));
      expect(item1.props.length, equals(6));
    });

    test('LoadFavoritesStarted event creates correctly', () {
      const event = LoadFavoritesStarted();
      expect(event.props, isEmpty);
    });
  });

  group('Buyer Flow - CartItem Addons', () {
    test('supports selected addons', () {
      final item = CartItem(
        id: 'p1', name: 'Pizza', price: 299.0, sellerId: 's1',
        selectedAddons: ['Extra Cheese', 'Olives'],
      );

      expect(item.selectedAddons.length, equals(2));
      expect(item.selectedAddons, contains('Extra Cheese'));
    });

    test('copyWith preserves addons', () {
      final item = CartItem(
        id: 'p1', name: 'Pizza', price: 299.0, sellerId: 's1',
        selectedAddons: ['Extra Cheese'],
      );

      final updated = item.copyWith(quantity: 2);
      expect(updated.selectedAddons, contains('Extra Cheese'));
      expect(updated.quantity, equals(2));
    });
  });
}
