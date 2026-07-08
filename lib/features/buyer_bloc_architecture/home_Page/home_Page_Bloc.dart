// lib/Buyer Bloc Architecture/home_Page/home_Page_Bloc.dart
//
// Business logic layer for the Home Page.
// Orchestrates Firestore stream subscriptions, category switching,
// and in-memory search filtering. The UI layer has zero business logic.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/product_repository.dart';
import 'home_page_models.dart';

// Pull in event and state definitions via Dart's part mechanism.
part 'home_Page_Event.dart';
part 'home_Page_State.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  // ProductRepository instance injected via constructor.
  final ProductRepository _productRepository;

  // Snapshot of all products for the current category (unfiltered).
  List<FoodItem> _allItems = [];

  // The ID of the currently selected category chip.
  String _selectedCategoryId = kDefaultCategories
      .firstWhere((c) => c.isSelected, orElse: () => kDefaultCategories.first)
      .id;

  // Active search query string (empty when search is inactive).
  String _searchQuery = '';

  HomePageBloc({ProductRepository? productRepository})
    : _productRepository = productRepository ?? ProductRepository(),
      super(
        HomePageInitial(
          kDefaultCategories
              .firstWhere(
                (c) => c.isSelected,
                orElse: () => kDefaultCategories.first,
              )
              .id,
        ),
      ) {
    on<HomePageStarted>(_onStarted);
    on<CategorySelected>(_onCategorySelected);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCleared>(_onSearchCleared);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Returns the name of the currently selected category.
  String get _selectedCategoryName =>
      kDefaultCategories.firstWhere((c) => c.id == _selectedCategoryId).name;

  /// Applies the current search query to [_allItems] and emits the correct state.
  /// Note: This is kept for small datasets, but for enterprise scalability,
  /// _onSearchQueryChanged now uses server-side filtering via ProductRepository.
  void _emitFilteredState(Emitter<HomePageState> emit) {
    if (_allItems.isEmpty) {
      emit(HomePageEmpty(_selectedCategoryName, _selectedCategoryId));
      return;
    }

    emit(
      HomePageLoaded(
        allItems: _allItems,
        filteredItems: _allItems,
        selectedCategoryId: _selectedCategoryId,
        searchQuery: _searchQuery,
      ),
    );
  }

  // ── Event Handlers ────────────────────────────────────────────────────────────

  /// Handles the initial page load — subscribes to the default category stream.
  /// emit.forEach drives the Firestore stream and maps each snapshot to a state.
  Future<void> _onStarted(
    HomePageStarted event,
    Emitter<HomePageState> emit,
  ) async {
    emit(HomePageLoading(_selectedCategoryId));

    // Keep the handler alive so the stream emits states into the BLoC.
    await emit.forEach<List<FoodItem>>(
      _productRepository
          .getProductsByCategory(_selectedCategoryName)
          .map((s) => s.docs.map(FoodItem.fromFirestore).toList()),
      onData: (items) {
        _allItems = items;
        if (_allItems.isEmpty)
          return HomePageEmpty(_selectedCategoryName, _selectedCategoryId);

        return HomePageLoaded(
          allItems: _allItems,
          filteredItems: _allItems,
          selectedCategoryId: _selectedCategoryId,
          searchQuery: _searchQuery,
        );
      },
      onError: (e, _) =>
          HomePageError('Failed to load products: $e', _selectedCategoryId),
    );
  }

  /// Handles category chip tap — switches the Firestore subscription.
  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<HomePageState> emit,
  ) async {
    if (_selectedCategoryId == event.categoryId)
      return; // No-op if same category.

    _selectedCategoryId = event.categoryId;
    _searchQuery = ''; // Clear search when switching categories.
    _allItems = [];

    emit(HomePageLoading(_selectedCategoryId));

    await emit.forEach<List<FoodItem>>(
      _productRepository
          .getProductsByCategory(_selectedCategoryName)
          .map((s) => s.docs.map(FoodItem.fromFirestore).toList()),
      onData: (items) {
        _allItems = items;
        if (_allItems.isEmpty)
          return HomePageEmpty(_selectedCategoryName, _selectedCategoryId);

        return HomePageLoaded(
          allItems: _allItems,
          filteredItems: _allItems,
          selectedCategoryId: _selectedCategoryId,
          searchQuery: '',
        );
      },
      onError: (e, _) =>
          HomePageError('Failed to load products: $e', _selectedCategoryId),
    );
  }

  /// Handles search input — uses server-side filtering for scalability.
  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<HomePageState> emit,
  ) async {
    _searchQuery = event.query.trim().toLowerCase();

    if (_searchQuery.isEmpty) {
      add(const SearchCleared());
      return;
    }

    emit(HomePageLoading(_selectedCategoryId));

    await emit.forEach<List<FoodItem>>(
      _productRepository
          .searchProducts(_searchQuery, _selectedCategoryName)
          .map((s) => s.docs.map(FoodItem.fromFirestore).toList()),
      onData: (items) {
        if (items.isEmpty)
          return HomePageSearchEmpty(_searchQuery, _selectedCategoryId);

        return HomePageLoaded(
          allItems: _allItems, // keep original all items
          filteredItems: items,
          selectedCategoryId: _selectedCategoryId,
          searchQuery: _searchQuery,
        );
      },
      onError: (e, _) =>
          HomePageError('Search failed: $e', _selectedCategoryId),
    );
  }

  /// Handles search clear — resets to the full unfiltered product list.
  void _onSearchCleared(SearchCleared event, Emitter<HomePageState> emit) {
    _searchQuery = '';
    _emitFilteredState(emit);
  }

  @override
  Future<void> close() {
    // emit.forEach subscriptions are cancelled automatically by flutter_bloc
    // when close() is called — no manual cleanup needed here.
    return super.close();
  }
}
