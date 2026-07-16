// lib/Buyer Bloc Architecture/home_Page/home_page_models.dart
//
// Pure data models for the Home Page feature.
// No business logic, no UI dependencies — only data definitions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Default fallback image URL used when a product has no image stored.
const String kDefaultFoodImageUrl =
    'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982';

// ─── FoodCategory ──────────────────────────────────────────────────────────────

/// Represents a food category shown in the horizontal category filter row.
class FoodCategory {
  final String id;
  final String name;
  final String emoji;
  final bool isSelected;
  final int size;

  const FoodCategory({
    required this.id,
    required this.name,
    required this.emoji,
    this.isSelected = false,
    required this.size,
  });

  /// Returns a copy of this category with the given fields overridden.
  FoodCategory copyWith({bool? isSelected}) {
    return FoodCategory(
      id: id,
      name: name,
      emoji: emoji,
      isSelected: isSelected ?? this.isSelected,
      size: size,
    );
  }
}

// ─── FoodItem ──────────────────────────────────────────────────────────────────

/// Represents a single food product fetched from the Firestore 'products' collection.
class FoodItem {
  /// Firestore document ID.
  final String id;
  final String name;

  /// Price stored as double (converted from Firestore num type).
  final double price;

  /// Discounted price (if any).
  final double discountPrice;

  /// Short product description shown on the Details Page.
  final String description;

  /// Category name used for Firestore filtering.
  final String category;

  /// Nullable product image URL (stored as 'imageUrl' in Firestore).
  final String? image;

  /// Seller UID linking this product to its seller account.
  final String sellerId;

  // New fields aligned with Seller's Product model
  final String foodType;
  final bool isBestSeller;
  final double rating;
  final int reviewCount;
  final String spicyLevel;
  final String prepTime;
  final String portionSize;
  final String calories;
  final List<String> addons;
  final bool isActive;
  final String status;

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    this.discountPrice = 0.0,
    required this.description,
    required this.category,
    this.image,
    required this.sellerId,
    this.foodType = '',
    this.isBestSeller = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.spicyLevel = '',
    this.prepTime = '',
    this.portionSize = '',
    this.calories = '',
    this.addons = const [],
    this.isActive = true,
    this.status = 'inStock',
  });

  /// Factory constructor: maps a Firestore DocumentSnapshot to a FoodItem.
  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Log the raw Firestore payload for debugging purposes.
    debugPrint('DEBUG 1 (Firestore Data): $data');

    return FoodItem(
      id: doc.id,
      name: data['name'] ?? 'Unknown Product',
      // Convert Firestore num to Dart double safely.
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (data['discountPrice'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? 'No description available.',
      category: data['category'] ?? 'Uncategorized',
      // Support both legacy 'imageUrl' and new 'imageUrls' (from Seller)
      image:
          (data['imageUrls'] is List && (data['imageUrls'] as List).isNotEmpty)
          ? (data['imageUrls'][0].toString()).trim()
          : (data['imageUrl'] != null
                ? data['imageUrl'].toString().trim()
                : null),
      sellerId: data['sellerId'] ?? 'Unknown Seller',
      foodType: data['foodType'] ?? '',
      isBestSeller: data['isBestSeller'] ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      spicyLevel: data['spicyLevel'] ?? '',
      prepTime: data['prepTime'] ?? '',
      portionSize: data['portionSize'] ?? '',
      calories: data['calories'] ?? '',
      addons: data['addons'] != null ? List<String>.from(data['addons']) : [],
      isActive: data['isActive'] ?? true,
      status: data['status'] ?? 'inStock',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FoodItem && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

// ─── Category Seed Data ────────────────────────────────────────────────────────

/// Predefined list of food categories displayed on the home page.
/// The first category (Pizza) is selected by default.
const List<FoodCategory> kDefaultCategories = [
  FoodCategory(
    id: 'CAT-FF-001',
    name: 'Burgers',
    emoji: '🍔',
    isSelected: true,
    size: 35,
  ),
  FoodCategory(id: 'CAT-FF-002', name: 'Pizza', emoji: '🍕', size: 35),
  FoodCategory(id: 'CAT-FF-003', name: 'Chicken', emoji: '🍗', size: 35),
  FoodCategory(id: 'CAT-FF-004', name: 'Wraps', emoji: '🌯', size: 35),
  FoodCategory(id: 'CAT-FF-005', name: 'Fries & Sides', emoji: '🍟', size: 35),
  FoodCategory(id: 'CAT-FF-006', name: 'Beverages', emoji: '🥤', size: 35),
  FoodCategory(id: 'CAT-FF-007', name: 'Desserts', emoji: '🍰', size: 35),
  FoodCategory(id: 'CAT-FF-008', name: 'Combo Meals', emoji: '🍱', size: 35),
];
