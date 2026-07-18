import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/food_item_mapper.dart';

void main() {
  group('FoodItemMapper', () {
    test('maps Core Product to FoodItem ViewModel correctly', () {
      final product = Product(
        id: 'prod1',
        name: 'Burger',
        price: 10.0,
        description: 'Delicious',
        category: 'Fast Food',
        imageUrls: const ['https://example.com/burger.png'],
        sellerId: 'seller123',
        status: ProductStatus.inStock,
        isActive: true,
        prepTime: 15,
        calories: 350,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final item = FoodItemMapper.toViewModel(product);

      expect(item.image, 'https://example.com/burger.png');
      expect(item.name, 'Burger');
      expect(item.price, 10.0);
      expect(item.prepTime, '15 mins');
      expect(item.calories, '350 kcal');
      expect(item.isActive, true);
    });
  });
}
