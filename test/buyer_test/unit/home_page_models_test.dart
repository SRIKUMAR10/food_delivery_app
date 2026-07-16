import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';

void main() {
  group('FoodItem fromFirestore', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('parses legacy imageUrl correctly', () async {
      final ref = fakeFirestore.collection('products').doc('prod1');
      await ref.set({
        'name': 'Burger',
        'price': 10.0,
        'description': 'Delicious',
        'category': 'Fast Food',
        'imageUrl': 'https://example.com/burger.png',
        'sellerId': 'seller123',
      });

      final doc = await ref.get();
      final item = FoodItem.fromFirestore(doc);

      expect(item.image, 'https://example.com/burger.png');
      expect(item.name, 'Burger');
      expect(item.price, 10.0);
    });

    test('parses new imageUrls list and picks the first item', () async {
      final ref = fakeFirestore.collection('products').doc('prod2');
      await ref.set({
        'name': 'Pizza',
        'price': 15.0,
        'description': 'Cheesy',
        'category': 'Fast Food',
        'imageUrls': ['https://example.com/pizza1.png', 'https://example.com/pizza2.png'],
        'sellerId': 'seller123',
      });

      final doc = await ref.get();
      final item = FoodItem.fromFirestore(doc);

      expect(item.image, 'https://example.com/pizza1.png');
      expect(item.name, 'Pizza');
      expect(item.price, 15.0);
    });
  });
}
