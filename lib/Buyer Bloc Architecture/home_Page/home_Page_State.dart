// lib/Buyer Bloc Architecture/home_Page/home_Page_State.dart
//
// Defines all possible UI states for the Home Page.
// States are immutable and use Equatable for value-based equality,
// which prevents redundant BlocBuilder rebuilds.

part of 'home_Page_Bloc.dart';

/// Base class for all Home Page states.
sealed class HomePageState extends Equatable {
  /// The currently selected category ID. This ensures the UI can always highlight the correct category chip, even while loading.
  final String selectedCategoryId;

  const HomePageState(this.selectedCategoryId);

  @override
  List<Object?> get props => [selectedCategoryId];
}

// ─── States ────────────────────────────────────────────────────────────────────

/// Initial state before any data has been loaded.
final class HomePageInitial extends HomePageState {
  const HomePageInitial(super.selectedCategoryId);
}

/// Shown while the Firestore stream is connecting or a new category is loading.
final class HomePageLoading extends HomePageState {
  const HomePageLoading(super.selectedCategoryId);
}

/// Emitted when products have been successfully fetched and (optionally) filtered.
final class HomePageLoaded extends HomePageState {
  /// Full unfiltered list of products for the selected category.
  final List<FoodItem> allItems;

  /// Filtered subset of [allItems] matching the current search query.
  /// Equals [allItems] when there is no active search.
  final List<FoodItem> filteredItems;

  /// Current search query string (empty string when search is inactive).
  final String searchQuery;

  const HomePageLoaded({
    required this.allItems,
    required this.filteredItems,
    required String selectedCategoryId,
    this.searchQuery = '',
  }) : super(selectedCategoryId);

  /// Returns a copy with the given fields overridden.
  HomePageLoaded copyWith({
    List<FoodItem>? allItems,
    List<FoodItem>? filteredItems,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return HomePageLoaded(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props =>
      [allItems, filteredItems, selectedCategoryId, searchQuery];
}

/// Emitted when a Firestore error occurs during product loading.
final class HomePageError extends HomePageState {
  /// Human-readable error message to display in the UI.
  final String message;

  const HomePageError(this.message, super.selectedCategoryId);

  @override
  List<Object?> get props => [message, selectedCategoryId];
}

/// Emitted when the selected category has no products in Firestore.
final class HomePageEmpty extends HomePageState {
  /// Name of the selected category that returned no results.
  final String categoryName;

  const HomePageEmpty(this.categoryName, super.selectedCategoryId);

  @override
  List<Object?> get props => [categoryName, selectedCategoryId];
}

/// Emitted when products exist in the category but none match the search query.
final class HomePageSearchEmpty extends HomePageState {
  /// The query string that returned no results.
  final String query;

  const HomePageSearchEmpty(this.query, super.selectedCategoryId);

  @override
  List<Object?> get props => [query, selectedCategoryId];
}

