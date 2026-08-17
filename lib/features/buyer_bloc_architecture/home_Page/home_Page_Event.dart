// lib/Buyer Bloc Architecture/home_Page/home_Page_Event.dart
//
// Defines all events that the HomePageBloc can receive.
// Events are triggered by user interactions or system initialisation signals.
//
// Sealed class pattern: every possible event is listed here, making it
// exhaustive and easy to find in switch/when expressions.

part of 'home_Page_Bloc.dart';

/// Base class for all Home Page events.
sealed class HomePageEvent {
  const HomePageEvent();
}

// ─── Events ────────────────────────────────────────────────────────────────────

/// Dispatched when the Home Page is first mounted.
/// Triggers initial data loading for the default category.
final class HomePageStarted extends HomePageEvent {
  const HomePageStarted();
}

/// Dispatched when the user taps a category chip to switch product filters.
final class CategorySelected extends HomePageEvent {
  /// The ID of the category that was tapped.
  final String categoryId;

  const CategorySelected(this.categoryId);
}

/// Dispatched on every keystroke while the user types in the search field.
/// The BLoC filters the already-loaded product list in memory (no Firestore call).
final class SearchQueryChanged extends HomePageEvent {
  /// Lowercase, trimmed search text entered by the user.
  final String query;

  const SearchQueryChanged(this.query);
}

/// Dispatched when the user clears the search field (e.g., taps ✕).
/// Resets the displayed list to the full unfiltered product list.
final class SearchCleared extends HomePageEvent {
  const SearchCleared();
}

/// Dispatched when the CategoryRepository yields new categories from Firestore.
final class CategoriesUpdated extends HomePageEvent {
  final List<FoodCategory> categories;
  const CategoriesUpdated(this.categories);
}

final class _ProductsReceived extends HomePageEvent {
  final List<FoodItem> items;
  final bool isSearch;
  final String query;
  const _ProductsReceived(this.items, {this.isSearch = false, this.query = ''});
}

final class _ProductErrorReceived extends HomePageEvent {
  final String message;
  const _ProductErrorReceived(this.message);
}

/// Dispatched to fetch or refresh current GPS location.
final class FetchUserLocation extends HomePageEvent {
  const FetchUserLocation();
}

/// Dispatched when the user selects a new location or location is fetched from GPS.
final class LocationUpdated extends HomePageEvent {
  final String address;
  const LocationUpdated(this.address);
}

/// Dispatched when featured sellers are fetched from Firestore.
final class FeaturedSellersUpdated extends HomePageEvent {
  final List<Seller> sellers;
  const FeaturedSellersUpdated(this.sellers);
}

/// Dispatched when recently ordered food items are fetched.
final class RecentOrdersUpdated extends HomePageEvent {
  final List<FoodItem> items;
  const RecentOrdersUpdated(this.items);
}

/// Dispatched when active promotional banners are updated.
final class PromotionsUpdated extends HomePageEvent {
  final List<PromotionBanner> banners;
  const PromotionsUpdated(this.banners);
}

/// Dispatched when the user picks a new restaurant sort strategy
/// (rating, distance, or delivery time).
final class RestaurantSortChanged extends HomePageEvent {
  final RestaurantSortOption sortOption;
  const RestaurantSortChanged(this.sortOption);
}

/// Dispatched when the buyer's delivery coordinates (GPS or selected address)
/// are known, so distances can be computed with the Haversine formula.
final class BuyerLocationUpdated extends HomePageEvent {
  final double lat;
  final double lng;
  final String address;
  const BuyerLocationUpdated(this.lat, this.lng, this.address);
}

/// Dispatched when the user selects a cuisine tag to filter restaurants.
/// An empty string clears the cuisine filter.
final class CuisineFilterChanged extends HomePageEvent {
  final String cuisine;
  const CuisineFilterChanged(this.cuisine);
}

