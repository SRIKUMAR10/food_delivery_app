// lib/Buyer Bloc Architecture/home_Page/home_Page_State.dart
//
// Defines all possible UI states for the Home Page.
// States are immutable and use Equatable for value-based equality,
// which prevents redundant BlocBuilder rebuilds.

part of 'home_Page_Bloc.dart';

/// Base class for all Home Page states.
sealed class HomePageState extends Equatable {
  /// The currently selected category ID.
  final String selectedCategoryId;
  
  /// The list of categories available.
  final List<FoodCategory> categories;

  /// Current user delivery address.
  final String currentAddress;

  /// Active promotional banners.
  final List<PromotionBanner> banners;

  /// Featured sellers / restaurants.
  final List<Seller> featuredSellers;

  /// Buyer's recently ordered food items for fast reorder.
  final List<FoodItem> recentlyOrderedItems;

  /// Popular best-selling products across categories.
  final List<FoodItem> popularProducts;

  /// Currently active restaurant sort strategy.
  final RestaurantSortOption activeSortOption;

  /// Pre-computed seller distance map (sellerId → kilometres).
  final Map<String, double> distancesMap;

  /// Per-seller availability map (sellerId → availability).
  final Map<String, SellerAvailability> sellerAvailabilities;

  /// Selected cuisine tag filter (empty string means no cuisine filter).
  final String selectedCuisine;

  /// Buyer's delivery latitude (0.0 when unknown).
  final double userLat;

  /// Buyer's delivery longitude (0.0 when unknown).
  final double userLng;

  const HomePageState(
    this.selectedCategoryId,
    this.categories, {
    this.currentAddress = 'Fetching location...',
    this.banners = kDefaultBanners,
    this.featuredSellers = const [],
    this.recentlyOrderedItems = const [],
    this.popularProducts = const [],
    this.activeSortOption = RestaurantSortOption.rating,
    this.distancesMap = const {},
    this.sellerAvailabilities = const {},
    this.selectedCuisine = '',
    this.userLat = 0.0,
    this.userLng = 0.0,
  });

  @override
  List<Object?> get props => [
        selectedCategoryId,
        categories,
        currentAddress,
        banners,
        featuredSellers,
        recentlyOrderedItems,
        popularProducts,
        activeSortOption,
        distancesMap,
        sellerAvailabilities,
        selectedCuisine,
        userLat,
        userLng,
      ];
}

// ─── States ────────────────────────────────────────────────────────────────────

/// Initial state before any data has been loaded.
final class HomePageInitial extends HomePageState {
  const HomePageInitial(
    super.selectedCategoryId,
    super.categories, {
    super.currentAddress,
  });
}

/// Shown while the Firestore stream is connecting or a new category is loading.
final class HomePageLoading extends HomePageState {
  const HomePageLoading(
    super.selectedCategoryId,
    super.categories, {
    super.currentAddress,
    super.banners,
    super.featuredSellers,
    super.recentlyOrderedItems,
    super.popularProducts,
    super.activeSortOption,
    super.distancesMap,
    super.sellerAvailabilities,
    super.selectedCuisine,
    super.userLat,
    super.userLng,
  });
}

/// Emitted when products and sections have been successfully fetched and (optionally) filtered.
final class HomePageLoaded extends HomePageState {
  /// Full unfiltered list of products for the selected category.
  final List<FoodItem> allItems;

  /// Filtered subset of [allItems] matching the current search query.
  final List<FoodItem> filteredItems;

  /// Current search query string (empty string when search is inactive).
  final String searchQuery;

  /// Sellers matching search query when global search is active.
  final List<Seller> searchedSellers;

  const HomePageLoaded({
    required this.allItems,
    required this.filteredItems,
    required String selectedCategoryId,
    required List<FoodCategory> categories,
    String currentAddress = 'Select Location',
    this.searchQuery = '',
    Map<String, SellerAvailability> sellerAvailabilities = const {},
    List<PromotionBanner> banners = kDefaultBanners,
    List<Seller> featuredSellers = const [],
    List<FoodItem> popularProducts = const [],
    List<FoodItem> recentlyOrderedItems = const [],
    this.searchedSellers = const [],
    RestaurantSortOption activeSortOption = RestaurantSortOption.rating,
    String selectedCuisine = '',
    double userLat = 0.0,
    double userLng = 0.0,
    Map<String, double> distancesMap = const {},
  }) : super(
         selectedCategoryId,
         categories,
         currentAddress: currentAddress,
         banners: banners,
         featuredSellers: featuredSellers,
         recentlyOrderedItems: recentlyOrderedItems,
         popularProducts: popularProducts,
         activeSortOption: activeSortOption,
         distancesMap: distancesMap,
         sellerAvailabilities: sellerAvailabilities,
         selectedCuisine: selectedCuisine,
         userLat: userLat,
         userLng: userLng,
       );

  /// Returns a copy with the given fields overridden.
  HomePageLoaded copyWith({
    List<FoodItem>? allItems,
    List<FoodItem>? filteredItems,
    String? selectedCategoryId,
    List<FoodCategory>? categories,
    String? currentAddress,
    String? searchQuery,
    Map<String, SellerAvailability>? sellerAvailabilities,
    List<PromotionBanner>? banners,
    List<Seller>? featuredSellers,
    List<FoodItem>? popularProducts,
    List<FoodItem>? recentlyOrderedItems,
    List<Seller>? searchedSellers,
    RestaurantSortOption? activeSortOption,
    String? selectedCuisine,
    double? userLat,
    double? userLng,
    Map<String, double>? distancesMap,
  }) {
    return HomePageLoaded(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      categories: categories ?? this.categories,
      currentAddress: currentAddress ?? this.currentAddress,
      searchQuery: searchQuery ?? this.searchQuery,
      sellerAvailabilities: sellerAvailabilities ?? this.sellerAvailabilities,
      banners: banners ?? this.banners,
      featuredSellers: featuredSellers ?? this.featuredSellers,
      popularProducts: popularProducts ?? this.popularProducts,
      recentlyOrderedItems: recentlyOrderedItems ?? this.recentlyOrderedItems,
      searchedSellers: searchedSellers ?? this.searchedSellers,
      activeSortOption: activeSortOption ?? this.activeSortOption,
      selectedCuisine: selectedCuisine ?? this.selectedCuisine,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      distancesMap: distancesMap ?? this.distancesMap,
    );
  }

  @override
  List<Object?> get props => [
        allItems,
        filteredItems,
        selectedCategoryId,
        categories,
        currentAddress,
        searchQuery,
        sellerAvailabilities,
        banners,
        featuredSellers,
        popularProducts,
        recentlyOrderedItems,
        searchedSellers,
        activeSortOption,
        selectedCuisine,
        userLat,
        userLng,
        distancesMap,
      ];
}

/// Emitted when a Firestore error occurs during product loading.
final class HomePageError extends HomePageState {
  /// Human-readable error message to display in the UI.
  final String message;

  const HomePageError(
    this.message,
    super.selectedCategoryId,
    super.categories, {
    super.currentAddress,
    super.banners,
    super.featuredSellers,
    super.recentlyOrderedItems,
    super.popularProducts,
    super.activeSortOption,
    super.distancesMap,
    super.sellerAvailabilities,
    super.selectedCuisine,
    super.userLat,
    super.userLng,
  });

  @override
  List<Object?> get props => [message, selectedCategoryId, categories, currentAddress];
}

/// Emitted when the selected category has no products in Firestore.
final class HomePageEmpty extends HomePageState {
  /// Name of the selected category that returned no results.
  final String categoryName;

  const HomePageEmpty(
    this.categoryName,
    super.selectedCategoryId,
    super.categories, {
    super.currentAddress,
    super.banners,
    super.featuredSellers,
    super.recentlyOrderedItems,
    super.popularProducts,
    super.activeSortOption,
    super.distancesMap,
    super.sellerAvailabilities,
    super.selectedCuisine,
    super.userLat,
    super.userLng,
  });

  @override
  List<Object?> get props => [categoryName, selectedCategoryId, categories, currentAddress];
}

/// Emitted when products exist in the category but none match the search query.
final class HomePageSearchEmpty extends HomePageState {
  /// The query string that returned no results.
  final String query;

  const HomePageSearchEmpty(
    this.query,
    super.selectedCategoryId,
    super.categories, {
    super.currentAddress,
    super.banners,
    super.featuredSellers,
    super.recentlyOrderedItems,
    super.popularProducts,
    super.activeSortOption,
    super.distancesMap,
    super.sellerAvailabilities,
    super.selectedCuisine,
    super.userLat,
    super.userLng,
  });

  @override
  List<Object?> get props => [query, selectedCategoryId, categories, currentAddress];
}
