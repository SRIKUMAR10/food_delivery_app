// lib/Buyer Bloc Architecture/home_Page/home_page_models.dart
//
// Pure data models for the Home Page feature.
// No business logic, no UI dependencies — only data definitions.

import 'dart:math';

// Default fallback image URL used when a product has no image stored.
const String kDefaultFoodImageUrl =
    'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-cd4ca.firebasestorage.app/o/product_images%2FWpN6x21MmWUjG1DS9BfLnX2M3Js2%2F2026-06-12T00%3A40%3A44.162_images%20(1).jpg?alt=media&token=de903631-0a43-438e-b01c-effe404bd982';

// ─── Restaurant Discovery Helpers ──────────────────────────────────────────────

/// The available sorting strategies for the restaurant list.
enum RestaurantSortOption {
  rating,
  distance,
  deliveryTime,
}

/// Computes the great-circle distance between two coordinates in kilometres
/// using the Haversine formula.
double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadiusKm = 6371.0;
  final double dLat = _degreesToRadians(lat2 - lat1);
  final double dLon = _degreesToRadians(lon2 - lon1);
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degreesToRadians(double degrees) => degrees * pi / 180.0;

/// Estimates total delivery time in minutes from a distance in kilometres.
///
/// Combines a fixed preparation time with an average travel speed.
int estimateDeliveryTimeMinutes(double distanceKm) {
  const int basePreparationMinutes = 15;
  const double speedKmPerMinute = 0.45; // ~27 km/h average city speed.
  final int travelMinutes = (distanceKm / speedKmPerMinute).round();
  return basePreparationMinutes + travelMinutes;
}

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

// ─── PromotionBanner ───────────────────────────────────────────────────────────

/// Represents a promotional banner shown in the home page banner carousel.
class PromotionBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String code;
  final double discountPercent;

  const PromotionBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.code,
    required this.discountPercent,
  });

  factory PromotionBanner.fromFirestore(Map<String, dynamic> data, String id) {
    return PromotionBanner(
      id: id,
      title: data['title']?.toString() ?? '',
      subtitle: data['subtitle']?.toString() ?? data['description']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? data['image']?.toString() ?? '',
      code: data['code']?.toString() ?? data['couponCode']?.toString() ?? '',
      discountPercent: (data['discountPercent'] as num?)?.toDouble() ??
          (data['discount'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

const List<PromotionBanner> kDefaultBanners = [
  PromotionBanner(
    id: 'BAN-001',
    title: '50% OFF on First Order',
    subtitle: 'Use code WELCOME50',
    imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
    code: 'WELCOME50',
    discountPercent: 50.0,
  ),
  PromotionBanner(
    id: 'BAN-002',
    title: 'Free Delivery on Combos',
    subtitle: 'Orders above ₹299',
    imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
    code: 'FREEDEL',
    discountPercent: 0.0,
  ),
  PromotionBanner(
    id: 'BAN-003',
    title: 'Weekend Special 30% OFF',
    subtitle: 'On top rated restaurants',
    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
    code: 'WEEKEND30',
    discountPercent: 30.0,
  ),
];


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

  /// Multiple product image URLs from Firestore (stored as 'imageUrls').
  final List<String> imageUrls;

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
  final List<String> ingredients;
  final bool isActive;
  final String status;
  final int availableStock;
  final bool hasUnlimitedStock;

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    this.discountPrice = 0.0,
    required this.description,
    required this.category,
    this.image,
    this.imageUrls = const [],
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
    this.ingredients = const [],
    this.isActive = true,
    this.status = 'inStock',
    this.availableStock = 999,
    this.hasUnlimitedStock = true,
  });

  bool get isOutOfStock =>
      !isActive ||
      status.toLowerCase().contains('outofstock') ||
      (!hasUnlimitedStock && availableStock <= 0);

  bool get isInStock => !isOutOfStock;

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
