import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/buyer_bloc_architecture/home_Page/home_page_models.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches global categories from Firestore.
  /// If it fails or is empty, returns the default categories.
  Stream<List<FoodCategory>> getCategories() {
    return _firestore.collection('global_categories').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        // TODO: Remove this fallback once Firestore categories are fully populated and stable
        return kDefaultCategories;
      }
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FoodCategory(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          emoji: _getEmojiForCategory(data['name'] ?? ''),
          isSelected: false,
          size: 35,
        );
      }).toList();
    });
  }

  /// Maps a category name to an emoji (since emojis might not be in Firestore)
  String _getEmojiForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'pizza':
        return '🍕';
      case 'burger':
      case 'burgers':
        return '🍔';
      case 'pasta':
        return '🍝';
      case 'drinks':
      case 'beverages':
        return '🥤';
      case 'dessert':
      case 'desserts':
        return '🍰';
      case 'starters':
        return '🥟';
      case 'main course':
        return '🍛';
      case 'south indian':
        return '🥘';
      case 'chinese':
        return '🍜';
      default:
        return '🍽️';
    }
  }
}
