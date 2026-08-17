import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/food_item_mapper.dart';

void main() {
    test('maps Core Product to FoodItem ViewModel correctly with ingredients', () {
      final product = Product(
        id: 'prod1',
        name: 'Burger',
        price: 10.0,
        discountPrice: 8.0,
        description: 'Delicious Burger',
        category: 'Fast Food',
        imageUrls: const ['https://example.com/burger.png'],
        sellerId: 'seller123',
        status: ProductStatus.inStock,
        isActive: true,
        prepTime: 15,
        calories: 350,
        addons: const ['Extra Cheese', 'Mayo'],
        ingredients: const ['Bun', 'Patty', 'Lettuce', 'Tomato'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final item = FoodItemMapper.toViewModel(product);

      expect(item.image, 'https://example.com/burger.png');
      expect(item.name, 'Burger');
      expect(item.price, 10.0);
      expect(item.discountPrice, 8.0);
      expect(item.prepTime, '15 mins');
      expect(item.calories, '350 kcal');
      expect(item.addons, ['Extra Cheese', 'Mayo']);
      expect(item.ingredients, ['Bun', 'Patty', 'Lettuce', 'Tomato']);
      expect(item.isActive, true);
    });

    test('Product fromMap and toMap safely handles ingredients and addons', () {
      final map = {
        'name': 'Pizza',
        'price': 15.0,
        'discountPrice': 12.0,
        'addons': ['Olives', 'Mushrooms'],
        'ingredients': ['Dough', 'Cheese', 'Tomato Sauce'],
        'isActive': true,
        'availableStock': 5,
        'minimumAlert': 2,
      };

      final product = Product.fromMap('pizza1', map);

      expect(product.id, 'pizza1');
      expect(product.name, 'Pizza');
      expect(product.ingredients, ['Dough', 'Cheese', 'Tomato Sauce']);
      expect(product.addons, ['Olives', 'Mushrooms']);

      final serialized = product.toMap();
      expect(serialized['ingredients'], ['Dough', 'Cheese', 'Tomato Sauce']);
      expect(serialized['addons'], ['Olives', 'Mushrooms']);
    });

    test('multi-field search matching filters by ingredient, addon, and category', () {
      final now = DateTime.now();
      final products = [
        Product(
          id: 'p1',
          name: 'Classic Cheeseburger',
          price: 150.0,
          description: 'Juicy beef burger',
          category: 'Burgers',
          imageUrls: const ['https://example.com/burger.png'],
          sellerId: 's1',
          status: ProductStatus.inStock,
          createdAt: now,
          updatedAt: now,
          addons: const ['Extra Bacon (+₹40)'],
          ingredients: const ['Brioche Bun', 'Cheddar Cheese', 'Lettuce'],
        ),
        Product(
          id: 'p2',
          name: 'Farmhouse Pizza',
          price: 250.0,
          description: 'Fresh vegetable pizza',
          category: 'Pizza',
          imageUrls: const ['https://example.com/pizza.png'],
          sellerId: 's1',
          status: ProductStatus.inStock,
          createdAt: now,
          updatedAt: now,
          addons: const ['Garlic Dip (+₹25)'],
          ingredients: const ['Dough', 'Mozzarella', 'Mushroom', 'Capsicum'],
        ),
      ];

      List<Product> filter(String query) {
        final q = query.toLowerCase().trim();
        return products.where((p) {
          final nameMatch = p.name.toLowerCase().contains(q);
          final descMatch = p.description.toLowerCase().contains(q);
          final ingMatch = p.ingredients.any((ing) => ing.toLowerCase().contains(q));
          final addonMatch = p.addons.any((add) => add.toLowerCase().contains(q));
          final catMatch = p.category.toLowerCase().contains(q);
          return nameMatch || descMatch || ingMatch || addonMatch || catMatch;
        }).toList();
      }

      // Search by Ingredient
      expect(filter('Mushroom').length, 1);
      expect(filter('Mushroom').first.id, 'p2');

      // Search by Addon
      expect(filter('Bacon').length, 1);
      expect(filter('Bacon').first.id, 'p1');

      // Search by Category
      expect(filter('Burgers').length, 1);
      expect(filter('Burgers').first.id, 'p1');

      // Search by Name
      expect(filter('Pizza').length, 1);
      expect(filter('Pizza').first.id, 'p2');
    });
}
