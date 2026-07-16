import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_list_page__event.dart';
import 'product_list_page__state.dart';
import 'product_model.dart';
import 'product_repository.dart';

// Internal event for stream updates
class _ProductsUpdated extends ProductListPageEvent {
  final List<Product> products;
  const _ProductsUpdated(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductListBloc extends Bloc<ProductListPageEvent, ProductListPageState> {
  final ProductRepository repository;
  
  // Store the full list in memory for quick filtering
  List<Product> _allProducts = [];
  String _searchQuery = '';
  // Advanced filter state
  String _sortBy = 'Recently Added';
  double? _ratingFilter;
  String? _categoryFilter;
  double? _priceRangeMin;
  double? _priceRangeMax;
  StreamSubscription<List<Product>>? _subscription;

  ProductListBloc({required this.repository}) : super(ProductListInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<_ProductsUpdated>(_onProductsUpdated);
    on<FilterProductsEvent>(_onFilterProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<ApplyAdvancedFiltersEvent>(_onApplyAdvancedFilters);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<ToggleProductStatusEvent>(_onToggleProductStatus);
    on<DuplicateProductEvent>(_onDuplicateProduct);
    on<ArchiveProductEvent>(_onArchiveProduct);
    on<UnarchiveProductEvent>(_onUnarchiveProduct);
  }

  Future<void> _onLoadProducts(LoadProductsEvent event, Emitter<ProductListPageState> emit) async {
    emit(ProductListLoading());
    try {
      await _subscription?.cancel();
      _subscription = repository.getProductsStream().listen((products) {
        add(_ProductsUpdated(products));
      });
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
      await repository.deleteProduct(event.productId);
      // Stream will automatically trigger _ProductsUpdated
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onToggleProductStatus(ToggleProductStatusEvent event, Emitter<ProductListPageState> emit) async {
    try {
      await repository.toggleProductStatus(event.productId, event.isActive);
      // Stream will automatically trigger _ProductsUpdated
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onDuplicateProduct(DuplicateProductEvent event, Emitter<ProductListPageState> emit) async {
    try {
      await repository.duplicateProduct(event.productId);
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onArchiveProduct(ArchiveProductEvent event, Emitter<ProductListPageState> emit) async {
    try {
      await repository.archiveProduct(event.productId);
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  Future<void> _onUnarchiveProduct(UnarchiveProductEvent event, Emitter<ProductListPageState> emit) async {
    try {
      await repository.unarchiveProduct(event.productId);
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
    } else if (filterType == 'Low Stock') {
      filteredList = baseProducts.where((p) => p.status == ProductStatus.lowStock).toList();
    } else if (filterType == 'Veg') {
      filteredList = baseProducts.where((p) => p.foodType.toLowerCase() == 'veg' || p.foodType.toLowerCase() == 'vegetarian').toList();
    } else if (filterType == 'Non-Veg') {
      filteredList = baseProducts.where((p) => p.foodType.toLowerCase() == 'non-veg' || p.foodType.toLowerCase() == 'non-vegetarian').toList();
    } else {
      filteredList = List.from(baseProducts);
      if (filterType != 'Archived') filterType = 'All Products';
    }

    // Step 2: Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredList = filteredList.where((p) => p.name.toLowerCase().contains(query)).toList();
    }

    // Step 3: Advanced filters
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      filteredList = filteredList.where((p) => p.category.toLowerCase() == _categoryFilter!.toLowerCase()).toList();
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
    }
    // 'Recently Added' keeps original order from Firebase

    // Counts are always based on activeBase (non-archived) except for archivedCount
    final activeBase = _allProducts.where((p) => !p.isArchived).toList();
    final allCount = activeBase.length;
    final activeCount = activeBase.where((p) => p.isActive).length;
    final inactiveCount = activeBase.where((p) => !p.isActive).length;
    final lowStockCount = activeBase.where((p) => p.status == ProductStatus.lowStock).length;
    final vegCount = activeBase.where((p) => p.foodType.toLowerCase() == 'veg' || p.foodType.toLowerCase() == 'vegetarian').length;
    final nonVegCount = activeBase.where((p) => p.foodType.toLowerCase() == 'non-veg' || p.foodType.toLowerCase() == 'non-vegetarian').length;
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
      lowStockCount: lowStockCount,
      vegCount: vegCount,
      nonVegCount: nonVegCount,
      archivedCount: archivedCount,
      averageRating: averageRating,
      totalRevenue: totalRevenue,
      sortBy: _sortBy,
      ratingFilter: _ratingFilter,
      categoryFilter: _categoryFilter,
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
