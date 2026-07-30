// lib/Buyer Bloc Architecture/home_Page/home_Page_Bloc.dart
//
// Business logic layer for the Home Page.
// Orchestrates Firestore stream subscriptions, category switching,
// and in-memory search filtering. The UI layer has zero business logic.

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/i_product_repository.dart';
import '../../../core/services/seller_status_service.dart';
import '../../../repositories/category_repository.dart';
import 'home_page_models.dart';
import 'food_item_mapper.dart';

// Pull in event and state definitions via Dart's part mechanism.
part 'home_Page_Event.dart';
part 'home_Page_State.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final IProductRepository _productRepository;
  final CategoryRepository _categoryRepository;
  final SellerStatusService _sellerStatusService;

  List<FoodItem> _allItems = [];
  List<FoodCategory> _categories = [];
  Map<String, SellerAvailability> _sellerAvailabilities = {};

  String _selectedCategoryId = '';
  String _searchQuery = '';

  StreamSubscription<List<FoodCategory>>? _categorySubscription;
  final Map<String, StreamSubscription<SellerAvailability>> _sellerStatusSubscriptions = {};
  Timer? _batchTimer;

  HomePageBloc({
    required IProductRepository productRepository,
    required CategoryRepository categoryRepository,
    SellerStatusService? sellerStatusService,
  }) : _productRepository = productRepository,
       _categoryRepository = categoryRepository,
       _sellerStatusService = sellerStatusService ?? SellerStatusService(),
       super(const HomePageInitial('', [])) {
    on<HomePageStarted>(_onStarted);
    on<CategorySelected>(_onCategorySelected);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCleared>(_onSearchCleared);
    on<CategoriesUpdated>(_onCategoriesUpdated);
    on<_SellerAvailabilitiesUpdated>(_onSellerAvailabilitiesUpdated);
  }

  @override
  Future<void> close() {
    _categorySubscription?.cancel();
    _cancelSellerStatusSubscriptions();
    _batchTimer?.cancel();
    return super.close();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String get _selectedCategoryName {
    if (_categories.isEmpty) return '';
    return _categories
        .firstWhere(
          (c) => c.id == _selectedCategoryId,
          orElse: () => _categories.first,
        )
        .name;
  }

  void _emitFilteredState(Emitter<HomePageState> emit) {
    if (_allItems.isEmpty) {
      emit(
        HomePageEmpty(_selectedCategoryName, _selectedCategoryId, _categories),
      );
      return;
    }
    emit(
      HomePageLoaded(
        allItems: _allItems,
        filteredItems: _allItems,
        selectedCategoryId: _selectedCategoryId,
        categories: _categories,
        searchQuery: _searchQuery,
        sellerAvailabilities: Map.from(_sellerAvailabilities),
      ),
    );
  }

  void _subscribeToSellerStatuses(List<String> sellerIds) {
    _cancelSellerStatusSubscriptions();
    _sellerAvailabilities = {};

    for (final sellerId in sellerIds) {
      final sub = _sellerStatusService.watchSellerStatus(sellerId).listen((status) {
        if (!isClosed) {
          _onSellerStatusReceived(sellerId, status);
        }
      });
      _sellerStatusSubscriptions[sellerId] = sub;
    }
  }

  void _onSellerStatusReceived(String sellerId, SellerAvailability status) {
    _sellerAvailabilities[sellerId] = status;
    _batchTimer?.cancel();
    _batchTimer = Timer(const Duration(milliseconds: 100), () {
      if (!isClosed) {
        add(_SellerAvailabilitiesUpdated(Map.from(_sellerAvailabilities)));
      }
    });
  }

  void _cancelSellerStatusSubscriptions() {
    for (final sub in _sellerStatusSubscriptions.values) {
      sub.cancel();
    }
    _sellerStatusSubscriptions.clear();
    _batchTimer?.cancel();
    _batchTimer = null;
  }

  // ── Event Handlers ────────────────────────────────────────────────────────────

  Future<void> _onStarted(
    HomePageStarted event,
    Emitter<HomePageState> emit,
  ) async {
    if (state is! HomePageLoaded &&
        state is! HomePageEmpty &&
        state is! HomePageSearchEmpty) {
      emit(HomePageLoading(_selectedCategoryId, _categories));
    }

    // Subscribe to categories
    _categorySubscription?.cancel();
    _categorySubscription = _categoryRepository.getCategories().listen(
      (categories) {
        add(CategoriesUpdated(categories));
      },
      onError: (error) {
        add(CategoriesUpdated(kDefaultCategories));
      },
    );
  }

  Future<void> _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<HomePageState> emit,
  ) async {
    _categories = event.categories;

    // Fallback if empty
    if (_categories.isEmpty) {
      _categories = kDefaultCategories;
    }

    // Initialize or fix selected category id
    if (_selectedCategoryId.isEmpty ||
        !_categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = _categories
          .firstWhere((c) => c.isSelected, orElse: () => _categories.first)
          .id;
      _searchQuery = '';
      _allItems = [];

      // Since category changed, we need to fetch products.
      // But we can't emit.forEach here easily without cancelling previous.
      // Instead, we just trigger CategorySelected to let it handle product fetching.
      add(CategorySelected(_selectedCategoryId));
      return;
    }

    // If category didn't change, just emit current state with new categories
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(categories: _categories));
    } else if (state is HomePageLoading) {
      add(CategorySelected(_selectedCategoryId));
    } else if (state is HomePageEmpty) {
      emit(
        HomePageEmpty(_selectedCategoryName, _selectedCategoryId, _categories),
      );
    }
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<HomePageState> emit,
  ) async {
    _selectedCategoryId = event.categoryId;
    _searchQuery = '';
    _allItems = [];
    _cancelSellerStatusSubscriptions();

    emit(HomePageLoading(_selectedCategoryId, _categories));

    await emit.forEach<List<FoodItem>>(
      _productRepository
          .getProductsByCategory(_selectedCategoryName)
          .map((products) => products.map(FoodItemMapper.toViewModel).toList()),
      onData: (items) {
        _allItems = items;
        final sellerIds = items.map((i) => i.sellerId).toSet().toList();
        _subscribeToSellerStatuses(sellerIds);

        if (_allItems.isEmpty) {
          _cancelSellerStatusSubscriptions();
          return HomePageEmpty(
            _selectedCategoryName,
            _selectedCategoryId,
            _categories,
          );
        }

        return HomePageLoaded(
          allItems: _allItems,
          filteredItems: _allItems,
          selectedCategoryId: _selectedCategoryId,
          categories: _categories,
          searchQuery: '',
          sellerAvailabilities: Map.from(_sellerAvailabilities),
        );
      },
      onError: (e, _) => HomePageError(
        'Failed to load products: $e',
        _selectedCategoryId,
        _categories,
      ),
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<HomePageState> emit,
  ) async {
    _searchQuery = event.query.trim().toLowerCase();

    if (_searchQuery.isEmpty) {
      add(const SearchCleared());
      return;
    }

    emit(HomePageLoading(_selectedCategoryId, _categories));

    await emit.forEach<List<FoodItem>>(
      _productRepository
          .searchProducts(_searchQuery, _selectedCategoryName)
          .map((products) => products.map(FoodItemMapper.toViewModel).toList()),
      onData: (items) {
        if (items.isEmpty)
          return HomePageSearchEmpty(
            _searchQuery,
            _selectedCategoryId,
            _categories,
          );

        return HomePageLoaded(
          allItems: _allItems, // keep original all items
          filteredItems: items,
          selectedCategoryId: _selectedCategoryId,
          categories: _categories,
          searchQuery: _searchQuery,
          sellerAvailabilities: Map.from(_sellerAvailabilities),
        );
      },
      onError: (e, _) =>
          HomePageError('Search failed: $e', _selectedCategoryId, _categories),
    );
  }

  void _onSearchCleared(SearchCleared event, Emitter<HomePageState> emit) {
    _searchQuery = '';
    _emitFilteredState(emit);
  }

  void _onSellerAvailabilitiesUpdated(
    _SellerAvailabilitiesUpdated event,
    Emitter<HomePageState> emit,
  ) {
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(
        sellerAvailabilities: event.availabilities,
      ));
    }
  }
}

final class _SellerAvailabilitiesUpdated extends HomePageEvent {
  final Map<String, SellerAvailability> availabilities;
  const _SellerAvailabilitiesUpdated(this.availabilities);
}
