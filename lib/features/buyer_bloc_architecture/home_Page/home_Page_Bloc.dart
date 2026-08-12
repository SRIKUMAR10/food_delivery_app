// lib/Buyer Bloc Architecture/home_Page/home_Page_Bloc.dart
//
// Business logic layer for the Home Page.
// Orchestrates Firestore stream subscriptions, category switching,
// and in-memory search filtering. The UI layer has zero business logic.

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/product_model.dart';
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
  StreamSubscription<List<Product>>? _productSubscription;
  final Map<String, StreamSubscription<SellerAvailability>> _sellerStatusSubscriptions = {};
  Timer? _batchTimer;
  Timer? _loadingTimeoutTimer;

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
    on<_ProductsReceived>(_onProductsReceived);
    on<_ProductErrorReceived>(_onProductErrorReceived);
    on<_SellerAvailabilitiesUpdated>(_onSellerAvailabilitiesUpdated);
  }

  @override
  Future<void> close() {
    _categorySubscription?.cancel();
    _productSubscription?.cancel();
    _cancelSellerStatusSubscriptions();
    _batchTimer?.cancel();
    _loadingTimeoutTimer?.cancel();
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
    if (_categories.isEmpty) {
      _categories = CategoryRepository.defaultCategories;
    }
    if (_selectedCategoryId.isEmpty) {
      _selectedCategoryId = _categories.first.id;
    }

    if (state is! HomePageLoaded &&
        state is! HomePageEmpty &&
        state is! HomePageSearchEmpty) {
      emit(HomePageLoading(_selectedCategoryId, _categories));
    }

    // Immediately trigger fetching default category products
    add(CategorySelected(_selectedCategoryId));

    // Subscribe to categories safely
    _categorySubscription?.cancel();
    _categorySubscription = _categoryRepository.getCategories().listen(
      (categories) {
        if (!isClosed) {
          add(CategoriesUpdated(categories));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(CategoriesUpdated(CategoryRepository.defaultCategories));
        }
      },
    );
  }

  Future<void> _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<HomePageState> emit,
  ) async {
    if (event.categories.isNotEmpty) {
      _categories = event.categories;
    }

    if (_categories.isEmpty) {
      emit(HomePageEmpty('', '', []));
      return;
    }

    // Initialize or fix selected category id
    if (_selectedCategoryId.isEmpty ||
        !_categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = _categories
          .firstWhere((c) => c.isSelected, orElse: () => _categories.first)
          .id;
      _searchQuery = '';
      _allItems = [];

      add(CategorySelected(_selectedCategoryId));
      return;
    }

    // If category didn't change, update state with new categories
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(categories: _categories));
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

    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!isClosed && state is HomePageLoading) {
        add(const _ProductsReceived([], isSearch: false));
      }
    });

    _productSubscription?.cancel();
    _productSubscription = _productRepository
        .getProductsByCategory(_selectedCategoryName)
        .listen(
      (products) {
        if (!isClosed) {
          try {
            final items = products.map((p) => FoodItemMapper.toViewModel(p)).toList();
            add(_ProductsReceived(items, isSearch: false));
          } catch (e) {
            add(_ProductsReceived(const [], isSearch: false));
          }
        }
      },
      onError: (e) {
        if (!isClosed) {
          add(_ProductErrorReceived('Failed to load products: $e'));
        }
      },
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

    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!isClosed && state is HomePageLoading) {
        add(const _ProductsReceived([], isSearch: true, query: ''));
      }
    });

    _productSubscription?.cancel();
    _productSubscription = _productRepository
        .searchProducts(_searchQuery, _selectedCategoryName)
        .listen(
      (products) {
        if (!isClosed) {
          try {
            final items = products.map((p) => FoodItemMapper.toViewModel(p)).toList();
            add(_ProductsReceived(items, isSearch: true, query: _searchQuery));
          } catch (e) {
            add(_ProductsReceived(const [], isSearch: true, query: _searchQuery));
          }
        }
      },
      onError: (e) {
        if (!isClosed) {
          add(_ProductErrorReceived('Search failed: $e'));
        }
      },
    );
  }

  void _onProductsReceived(
    _ProductsReceived event,
    Emitter<HomePageState> emit,
  ) {
    _loadingTimeoutTimer?.cancel();

    if (event.isSearch) {
      if (event.items.isEmpty) {
        emit(
          HomePageSearchEmpty(
            event.query,
            _selectedCategoryId,
            _categories,
          ),
        );
        return;
      }
      emit(
        HomePageLoaded(
          allItems: _allItems,
          filteredItems: event.items,
          selectedCategoryId: _selectedCategoryId,
          categories: _categories,
          searchQuery: event.query,
          sellerAvailabilities: Map.from(_sellerAvailabilities),
        ),
      );
      return;
    }

    _allItems = event.items;
    final sellerIds = event.items.map((i) => i.sellerId).toSet().toList();
    _subscribeToSellerStatuses(sellerIds);

    if (_allItems.isEmpty) {
      _cancelSellerStatusSubscriptions();
      emit(
        HomePageEmpty(
          _selectedCategoryName,
          _selectedCategoryId,
          _categories,
        ),
      );
      return;
    }

    emit(
      HomePageLoaded(
        allItems: _allItems,
        filteredItems: _allItems,
        selectedCategoryId: _selectedCategoryId,
        categories: _categories,
        searchQuery: '',
        sellerAvailabilities: Map.from(_sellerAvailabilities),
      ),
    );
  }

  void _onProductErrorReceived(
    _ProductErrorReceived event,
    Emitter<HomePageState> emit,
  ) {
    _loadingTimeoutTimer?.cancel();
    emit(
      HomePageError(
        event.message,
        _selectedCategoryId,
        _categories,
      ),
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
