import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/repositories/category_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CategoryRepository categoryRepository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    categoryRepository = CategoryRepository(firestore: fakeFirestore);
  });

  group('CategoryRepository Unit Tests', () {
    test('getCategories returns defaultCategories when global_categories is empty', () async {
      final categories = await categoryRepository.getCategories().first;

      expect(categories, isNotEmpty);
      expect(categories.first.name, equals('All'));
      expect(categories.any((c) => c.name == 'Burgers'), isTrue);
      expect(categories.any((c) => c.name == 'Pizza'), isTrue);
    });

    test('getCategories prepends "All" category if not present in Firestore documents', () async {
      await fakeFirestore.collection('global_categories').doc('cat_1').set({
        'name': 'Burgers',
      });
      await fakeFirestore.collection('global_categories').doc('cat_2').set({
        'name': 'Pizza',
      });

      final categories = await categoryRepository.getCategories().first;

      expect(categories.length, equals(3)); // All + Burgers + Pizza
      expect(categories.first.name, equals('All'));
      expect(categories[1].name, equals('Burgers'));
      expect(categories[2].name, equals('Pizza'));
    });

    test('getCategories maps emojis correctly for known category names', () async {
      await fakeFirestore.collection('global_categories').doc('c1').set({'name': 'All'});
      await fakeFirestore.collection('global_categories').doc('c2').set({'name': 'Pizza'});

      final categories = await categoryRepository.getCategories().first;

      final allCat = categories.firstWhere((c) => c.name == 'All');
      final pizzaCat = categories.firstWhere((c) => c.name == 'Pizza');

      expect(allCat.emoji, equals('🔥'));
      expect(pizzaCat.emoji, equals('🍕'));
    });
  });
}
