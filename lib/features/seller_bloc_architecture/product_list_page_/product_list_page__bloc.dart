// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_list_page__event.dart';
import 'product_list_page__state.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/repositories/i_product_repository.dart';
import '../../../../core/services/i_auth_service.dart';

// Internal event for stream updates
class _ProductsUpdated extends ProductListPageEvent {
  final List<Product> products;
  const _ProductsUpdated(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductListBloc extends Bloc<ProductListPageEvent, ProductListPageState> {
  final IProductRepository repository;
  final IAuthService authService;
  
  // Store the full list in memory for quick filtering
  List<Product> _allProducts = [];
  String _searchQuery = '';
  // Advanced filter state
  String _sortBy = 'Recently Added';
  double? _ratingFilter;
  String? _categoryFilter;
  String? _subcategoryFilter;
  double? _priceRangeMin;
  double? _priceRangeMax;
  StreamSubscription<List<Product>>? _subscription;

  ProductListBloc({required this.repository, required this.authService}) : super(ProductListInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<_ProductsUpdated>(_onProductsUpdated);
    on<FilterProductsEvent>(_onFilterProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<ApplyAdvancedFiltersEvent>(_onApplyAdvancedFilters);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<ToggleProductStatusEvent>(_onToggleProductStatus);
    on<DuplicateProductEvent>(_onDuplicateProduct);
    on<QuickUpdateStockEvent>(_onQuickUpdateStock);
    on<QuickUpdatePriceEvent>(_onQuickUpdatePrice);
    on<MarkProductOutOfStockEvent>(_onMarkProductOutOfStock);
    on<ArchiveProductEvent>(_onArchiveProduct);
    on<UnarchiveProductEvent>(_onUnarchiveProduct);
  }

  String get _sellerId => authService.currentUserId ?? '';
  List<Product> get allProducts => _allProducts;

  Future<void> _onLoadProducts(LoadProductsEvent event, Emitter<ProductListPageState> emit) async {
    emit(ProductListLoading());
    try {
      if (_sellerId.isEmpty) {
        _allProducts = [];
        _emitFilteredState(emit, 'All Products');
        return;
      }
      await _subscription?.cancel();
      _subscription = repository.getProductsStream(_sellerId).listen(
        (products) {
          if (!isClosed) {
            add(_ProductsUpdated(products));
          }
        },
        onError: (error) {
          if (!isClosed) {
            emit(ProductListError(error.toString()));
          }
        },
      );
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  void _onProductsUpdated(_ProductsUpdated event, Emitter<ProductListPageState> emit) {
    _allProducts = event.products;
    
    // Preserve current filter if already loaded
    String currentFilter = 'All Products';
    if (state is ProductListLoaded) {
      currentFilter = (state as ProductListLoaded).activeFilter;
    }
    
    _emitFilteredState(emit, currentFilter);
  }

  void _onFilterProducts(FilterProductsEvent event, Emitter<ProductListPageState> emit) {
    if (state is ProductListLoaded || state is ProductListInitial) {
      _emitFilteredState(emit, event.filterType);
    }
  }

  void _onSearchProducts(SearchProductsEvent event, Emitter<ProductListPageState> emit) {
    _searchQuery = event.query;
    String currentFilter = 'All Products';
    if (state is ProductListLoaded) {
      currentFilter = (state as ProductListLoaded).activeFilter;
    }
    _emitFilteredState(emit, currentFilter);
  }

  void _onApplyAdvancedFilters(ApplyAdvancedFiltersEvent event, Emitter<ProductListPageState> emit) {
    _sortBy = event.sortBy;
    _ratingFilter = event.ratingFilter;
    _categoryFilter = event.categoryFilter;
    _subcategoryFilter = event.subcategoryFilter;
    _priceRangeMin = event.priceRangeMin;
    _priceRangeMax = event.priceRangeMax;
    
    String currentFilter = 'All Products';
    if (state is ProductListLoaded) {
      currentFilter = (state as ProductListLoaded).activeFilter;
    }
    _emitFilteredState(emit, currentFilter);
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductListPageState> emit) async {
    try {
      if (_sellerId.isNotEmpty) {
        await repository.deleteProduct(event.productId, _sellerId);
      }
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onToggleProductStatus(ToggleProductStatusEvent event, Emitter<ProductListPageState> emit) async {
    try {
      if (_sellerId.isNotEmpty) {
        await repository.toggleProductStatus(event.productId, event.isActive, _sellerId);
      }
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onDuplicateProduct(DuplicateProductEvent event, Emitter<ProductListPageState> emit) async {
    try {
      if (_sellerId.isNotEmpty) {
        final product = await repository.getProduct(event.productId, _sellerId);
        if (product != null) {
          await repository.duplicateProduct(product, _sellerId);
        }
      }
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onQuickUpdateStock(QuickUpdateStockEvent event, Emitter<ProductListPageState> emit) async {
    try {
      if (_sellerId.isNotEmpty) {
        await repository.updateProductStock(
          event.productId,
          event.stockQuantity,
          event.hasUnlimitedStock,
          _sellerId,
        );
      }
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onQuickUpdatePrice(QuickUpdatePriceEvent event, Emitter<ProductListPageState> emit) async {
    try {
      if (_sellerId.isNotEmpty) {
        await repository.updateProductPrice(
          event.productId,
          event.price,
          event.discountPrice,
          _sellerId,
        );
      }
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onMarkProductOutOfStock(MarkProductOutOfStockEvent event, Emitter<ProductListPageState> emit) async {
    try {
      if (_sellerId.isNotEmpty) {
        await repository.markProductOutOfStock(event.productId, _sellerId);
      }
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onArchiveProduct(ArchiveProductEvent event, Emitter<ProductListPageState> emit) async {
    try {
      if (_sellerId.isNotEmpty) {
        await repository.archiveProduct(event.productId, _sellerId);
      }
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onUnarchiveProduct(UnarchiveProductEvent event, Emitter<ProductListPageState> emit) async {
    try {
      if (_sellerId.isNotEmpty) {
        await repository.unarchiveProduct(event.productId, _sellerId);
      }
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  void _emitFilteredState(Emitter<ProductListPageState> emit, String filterType) {
    List<Product> baseProducts = [];
    if (filterType == 'Archived') {
      baseProducts = _allProducts.where((p) => p.isArchived).toList();
    } else {
      baseProducts = _allProducts.where((p) => !p.isArchived).toList();
    }

    List<Product> filteredList;
    
    // Step 1: Quick filter
    if (filterType == 'Active') {
      filteredList = baseProducts.where((p) => p.isActive).toList();
    } else if (filterType == 'Inactive') {
      filteredList = baseProducts.where((p) => !p.isActive).toList();
    } else if (filterType == 'In Stock') {
      filteredList = baseProducts.where((p) => p.status == ProductStatus.inStock).toList();
    } else if (filterType == 'Low Stock') {
      filteredList = baseProducts.where((p) => p.status == ProductStatus.lowStock).toList();
    } else if (filterType == 'Out of Stock') {
      filteredList = baseProducts.where((p) => p.status == ProductStatus.outOfStock).toList();
    } else if (filterType == 'Veg') {
      filteredList = baseProducts.where((p) => p.foodType.toLowerCase() == 'veg' || p.foodType.toLowerCase() == 'vegetarian').toList();
    } else if (filterType == 'Non-Veg') {
      filteredList = baseProducts.where((p) {
        final ft = p.foodType.trim().toLowerCase();
        return ft.isNotEmpty && ft != 'veg' && ft != 'vegetarian';
      }).toList();
    } else {
      filteredList = List.from(baseProducts);
      if (filterType != 'Archived') filterType = 'All Products';
    }

    // Step 2: Search filter (across Name, SKU, Description, Category, Subcategory, Ingredients, Addons)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredList = filteredList.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final skuMatch = p.sku.toLowerCase().contains(query);
        final descMatch = p.description.toLowerCase().contains(query);
        final catMatch = p.category.toLowerCase().contains(query);
        final subcatMatch = p.subcategory.toLowerCase().contains(query);
        final ingMatch = p.ingredients.any((ing) => ing.toLowerCase().contains(query));
        final addonMatch = p.addons.any((add) => add.toLowerCase().contains(query));
        return nameMatch || skuMatch || descMatch || catMatch || subcatMatch || ingMatch || addonMatch;
      }).toList();
    }

    // Step 3: Advanced filters
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      filteredList = filteredList.where((p) => p.category.toLowerCase() == _categoryFilter!.toLowerCase()).toList();
    }
    if (_subcategoryFilter != null && _subcategoryFilter!.isNotEmpty) {
      filteredList = filteredList.where((p) => p.subcategory.toLowerCase() == _subcategoryFilter!.toLowerCase()).toList();
    }
    if (_ratingFilter != null) {
      filteredList = filteredList.where((p) => p.rating >= _ratingFilter!).toList();
    }
    if (_priceRangeMin != null) {
      filteredList = filteredList.where((p) => p.price >= _priceRangeMin!).toList();
    }
    if (_priceRangeMax != null) {
      filteredList = filteredList.where((p) => p.price <= _priceRangeMax!).toList();
    }

    // Step 4: Sort
    if (_sortBy == 'Price: Low to High') {
      filteredList.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      filteredList.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Best Selling') {
      filteredList.sort((a, b) => b.salesCount.compareTo(a.salesCount));
    } else if (_sortBy == 'Top Rated') {
      filteredList.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'Name: A to Z') {
      filteredList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      // Default to Recently Added
      filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    // Counts are always based on activeBase (non-archived) except for archivedCount
    final activeBase = _allProducts.where((p) => !p.isArchived).toList();
    final allCount = activeBase.length;
    final activeCount = activeBase.where((p) => p.isActive).length;
    final inactiveCount = activeBase.where((p) => !p.isActive).length;
    final inStockCount = activeBase.where((p) => p.status == ProductStatus.inStock).length;
    final lowStockCount = activeBase.where((p) => p.status == ProductStatus.lowStock).length;
    final outOfStockCount = activeBase.where((p) => p.status == ProductStatus.outOfStock).length;
    final vegCount = activeBase.where((p) => p.foodType.toLowerCase() == 'veg' || p.foodType.toLowerCase() == 'vegetarian').length;
    final nonVegCount = activeBase.where((p) {
      final ft = p.foodType.trim().toLowerCase();
      return ft.isNotEmpty && ft != 'veg' && ft != 'vegetarian';
    }).length;
    final archivedCount = _allProducts.where((p) => p.isArchived).length;

    double totalRevenue = 0.0;
    double totalRating = 0.0;
    int ratedProductsCount = 0;
    
    for (var p in activeBase) {
      totalRevenue += p.price * p.salesCount;
      if (p.rating > 0) {
        totalRating += p.rating;
        ratedProductsCount++;
      }
    }
    
    double averageRating = ratedProductsCount > 0 ? totalRating / ratedProductsCount : 0.0;

    emit(ProductListLoaded(
      products: filteredList,
      activeFilter: filterType,
      searchQuery: _searchQuery,
      allCount: allCount,
      activeCount: activeCount,
      inactiveCount: inactiveCount,
      inStockCount: inStockCount,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      vegCount: vegCount,
      nonVegCount: nonVegCount,
      archivedCount: archivedCount,
      averageRating: averageRating,
      totalRevenue: totalRevenue,
      sortBy: _sortBy,
      ratingFilter: _ratingFilter,
      categoryFilter: _categoryFilter,
      subcategoryFilter: _subcategoryFilter,
      priceRangeMin: _priceRangeMin,
      priceRangeMax: _priceRangeMax,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
