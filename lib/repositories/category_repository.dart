import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/buyer_bloc_architecture/home_Page/home_page_models.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Default fallback categories when Firestore global_categories is unpopulated.
  static final List<FoodCategory> defaultCategories = [
    const FoodCategory(id: 'cat_all', name: 'All', emoji: '🔥', isSelected: true, size: 35),
    const FoodCategory(id: 'cat_chicken', name: 'Fried Chicken', emoji: '🍗', isSelected: false, size: 35),
    const FoodCategory(id: 'cat_burgers', name: 'Burgers', emoji: '🍔', isSelected: false, size: 35),
    const FoodCategory(id: 'cat_pizza', name: 'Pizza', emoji: '🍕', isSelected: false, size: 35),
    const FoodCategory(id: 'cat_sides', name: 'Sides', emoji: '🍟', isSelected: false, size: 35),
    const FoodCategory(id: 'cat_drinks', name: 'Beverages', emoji: '🥤', isSelected: false, size: 35),
    const FoodCategory(id: 'cat_desserts', name: 'Desserts', emoji: '🍰', isSelected: false, size: 35),
    const FoodCategory(id: 'cat_combos', name: 'Special Combos', emoji: '🍱', isSelected: false, size: 35),
    const FoodCategory(id: 'cat_kids', name: 'Kids Meals', emoji: '🧸', isSelected: false, size: 35),
  ];

  /// Fetches global categories from Firestore.
  Stream<List<FoodCategory>> getCategories() {
    return _firestore.collection('global_categories').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return defaultCategories;
      }

      final categories = snapshot.docs.map((doc) {
        final data = doc.data();
        final name = data['name'] ?? 'Unknown';
        return FoodCategory(
          id: doc.id,
          name: name,
          emoji: _getEmojiForCategory(name),
          isSelected: false,
          size: 35,
        );
      }).toList();

      final hasAll = categories.any((c) => c.name.toLowerCase() == 'all');
      if (!hasAll) {
        categories.insert(
          0,
          const FoodCategory(id: 'cat_all', name: 'All', emoji: '🔥', isSelected: true, size: 35),
        );
      }

      return categories;
    }).handleError((_) => defaultCategories);
  }

  /// Maps a category name to an emoji (since emojis might not be in Firestore)
  String _getEmojiForCategory(String name) {
    final lower = name.toLowerCase().trim();
    if (lower == 'all') return '🔥';
    if (lower.contains('chicken')) return '🍗';
    if (lower.contains('burger')) return '🍔';
    if (lower.contains('pizza')) return '🍕';
    if (lower.contains('side') || lower.contains('frie')) return '🍟';
    if (lower.contains('beverage') || lower.contains('drink')) return '🥤';
    if (lower.contains('dessert') || lower.contains('cake')) return '🍰';
    if (lower.contains('combo')) return '🍱';
    if (lower.contains('kid')) return '🧸';
    if (lower.contains('wrap')) return '🌯';
    return '🍽️';
  }
}
