// lib/Buyer Bloc Architecture/home_Page/home_page_models.dart
//
// Pure data models for the Home Page feature.
// No business logic, no UI dependencies — only data definitions.


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
    this.isActive = true,
    this.status = 'inStock',
  });

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
