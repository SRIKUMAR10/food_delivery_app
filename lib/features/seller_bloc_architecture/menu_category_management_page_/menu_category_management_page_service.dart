import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_category_management_page_model.dart';

class MenuCategoryManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MenuCategoryModel>> fetchAllGlobalCategories(String sellerId) async {
    try {
      // 1. Fetch global categories
      List<MenuCategoryModel> globalCategories = [];
      try {
        final globalSnapshot = await _firestore.collection('global_categories').get();
        globalCategories = globalSnapshot.docs.map((doc) {
          final data = doc.data();
          return MenuCategoryModel(
            id: doc.id,
            name: data['name'] ?? '',
            isSelected: false,
            sortOrder: 999, // default
          );
        }).toList();
      } catch (e) {
        debugPrint('Could not fetch global categories: $e');
      }

      // If no global categories exist (or permission denied), provide some defaults to bootstrap
      if (globalCategories.isEmpty) {
        globalCategories = [
          MenuCategoryModel(id: 'CAT-001', name: 'Starters', isSelected: false, sortOrder: 999),
          MenuCategoryModel(id: 'CAT-002', name: 'Main Course', isSelected: false, sortOrder: 999),
          MenuCategoryModel(id: 'CAT-003', name: 'Beverages', isSelected: false, sortOrder: 999),
          MenuCategoryModel(id: 'CAT-004', name: 'Desserts', isSelected: false, sortOrder: 999),
          MenuCategoryModel(id: 'CAT-005', name: 'South Indian', isSelected: false, sortOrder: 999),
          MenuCategoryModel(id: 'CAT-006', name: 'Chinese', isSelected: false, sortOrder: 999),
        ];
      }

      // 2. Fetch seller preferences
      Map<String, Map<String, dynamic>> sellerPrefs = {};
      try {
        final sellerPrefsSnapshot = await _firestore
            .collection('sellers')
            .doc(sellerId)
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
    try {
      WriteBatch batch = _firestore.batch();
      
      for (var cat in categories) {
        final docRef = _firestore
            .collection('sellers')
            .doc(sellerId)
            .collection('menu_preferences')
            .doc(cat.id);
            
        batch.set(docRef, {
          'isSelected': cat.isSelected,
          'sortOrder': cat.sortOrder,
        }, SetOptions(merge: true));
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save category preferences: $e');
    }
  }
}
