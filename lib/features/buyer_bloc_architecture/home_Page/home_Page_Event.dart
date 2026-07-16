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
