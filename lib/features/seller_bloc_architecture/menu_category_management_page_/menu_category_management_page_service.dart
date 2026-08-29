import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_category_management_page_model.dart';

class MenuCategoryManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MenuCategoryModel>> streamAllGlobalCategories(String sellerId) {
    final effectiveId = sellerId.trim();
    if (effectiveId.isEmpty) {
      return Stream.fromFuture(fetchAllGlobalCategories(effectiveId));
    }

    return _firestore
        .collection('sellers')
        .doc(effectiveId)
        .collection('menu_preferences')
        .snapshots()
        .asyncMap((prefsSnapshot) async {
      return await fetchAllGlobalCategories(effectiveId);
    });
  }

  Future<List<MenuCategoryModel>> fetchAllGlobalCategories(String sellerId) async {
    try {
      // 1. Fetch global categories
      List<MenuCategoryModel> globalCategories = [];
      try {
        final globalSnapshot = await _firestore.collection('global_categories').get();
        globalCategories = globalSnapshot.docs.map((doc) {
          final data = doc.data();
          final name = data['name'] ?? '';
          final emoji = data['emoji'] as String?;
          return MenuCategoryModel(
            id: doc.id,
            name: name,
            emoji: emoji ?? MenuCategoryModel.getCategoryEmoji(name),
            isSelected: false,
            sortOrder: data['sortOrder'] is int ? data['sortOrder'] as int : 999,
          );
        }).toList();
      } catch (e) {
        debugPrint('Could not fetch global categories: $e');
      }

      // If no global categories exist (or permission denied), provide Fast-Food QSR defaults
      if (globalCategories.isEmpty) {
        globalCategories = [
          MenuCategoryModel(id: 'CAT-001', name: 'Fried Chicken', emoji: '🍗', isSelected: false, sortOrder: 1),
          MenuCategoryModel(id: 'CAT-002', name: 'Burgers', emoji: '🍔', isSelected: false, sortOrder: 2),
          MenuCategoryModel(id: 'CAT-003', name: 'Pizza', emoji: '🍕', isSelected: false, sortOrder: 3),
          MenuCategoryModel(id: 'CAT-004', name: 'Sides', emoji: '🍟', isSelected: false, sortOrder: 4),
          MenuCategoryModel(id: 'CAT-005', name: 'Beverages', emoji: '🥤', isSelected: false, sortOrder: 5),
          MenuCategoryModel(id: 'CAT-006', name: 'Desserts', emoji: '🍰', isSelected: false, sortOrder: 6),
          MenuCategoryModel(id: 'CAT-007', name: 'Special Combos', emoji: '🍱', isSelected: false, sortOrder: 7),
          MenuCategoryModel(id: 'CAT-008', name: 'Kids Meals', emoji: '🧸', isSelected: false, sortOrder: 8),
        ];
      }

      final effectiveId = sellerId.trim();
      if (effectiveId.isEmpty) {
        return globalCategories;
      }

      // 2. Fetch seller preferences
      Map<String, Map<String, dynamic>> sellerPrefs = {};
      try {
        final sellerPrefsSnapshot = await _firestore
            .collection('sellers')
            .doc(effectiveId)
            .collection('menu_preferences')
            .get();

        for (var doc in sellerPrefsSnapshot.docs) {
          sellerPrefs[doc.id] = doc.data();
        }
      } catch (e) {
        debugPrint('Could not fetch seller preferences: $e');
      }

      // 3. Merge them
      List<MenuCategoryModel> mergedCategories = globalCategories.map((cat) {
        if (sellerPrefs.containsKey(cat.id)) {
          final pref = sellerPrefs[cat.id]!;
          return cat.copyWith(
            isSelected: pref['isSelected'] ?? false,
            sortOrder: pref['sortOrder'] ?? cat.sortOrder,
            emoji: pref['emoji'] ?? cat.emoji,
          );
        }
        return cat;
      }).toList();

      // Sort by sortOrder
      mergedCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return mergedCategories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<void> saveSellerCategoryPreferences(String sellerId, List<MenuCategoryModel> categories) async {
    final effectiveId = sellerId.trim();
    if (effectiveId.isEmpty) return;

    try {
      WriteBatch batch = _firestore.batch();
      
      for (var cat in categories) {
        final docRef = _firestore
            .collection('sellers')
            .doc(effectiveId)
            .collection('menu_preferences')
            .doc(cat.id);
            
        batch.set(docRef, {
          'name': cat.name,
          'emoji': cat.displayEmoji,
          'isSelected': cat.isSelected,
          'sortOrder': cat.sortOrder,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final selectedCategoryNames = categories
          .where((c) => c.isSelected)
          .map((c) => c.name)
          .toList();

      final sellerDocRef = _firestore.collection('sellers').doc(effectiveId);
      batch.set(sellerDocRef, {
        'cuisines': selectedCategoryNames,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save category preferences: $e');
    }
  }
}
