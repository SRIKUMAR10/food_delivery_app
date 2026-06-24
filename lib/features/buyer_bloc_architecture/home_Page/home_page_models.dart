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

  /// Short product description shown on the Details Page.
  final String description;

  /// Category name used for Firestore filtering.
  final String category;

  /// Nullable product image URL (stored as 'imageUrl' in Firestore).
  final String? image;

  /// Seller UID linking this product to its seller account.
  final String sellerId;

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    this.image,
    required this.sellerId,
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
      description: data['description'] ?? 'No description available.',
      category: data['category'] ?? 'Uncategorized',
      // Trim whitespace from the image URL stored in Firestore as 'imageUrl'.
      image: (data['imageUrl'] as String?)?.trim(),
      sellerId: data['sellerId'] ?? 'Unknown Seller',
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
  FoodCategory(id: '1', name: 'Pizza',   emoji: '🍕', isSelected: true, size: 35),
  FoodCategory(id: '2', name: 'Burger',  emoji: '🍔', size: 35),
  FoodCategory(id: '3', name: 'Pasta',   emoji: '🍝', size: 35),
  FoodCategory(id: '4', name: 'Drinks',  emoji: '🥤', size: 35),
  FoodCategory(id: '5', name: 'Dessert', emoji: '🍰', size: 35),
];
