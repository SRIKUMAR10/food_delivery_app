import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_list_page__event.dart';
import 'product_list_page__state.dart';
import 'product_model.dart';
import 'product_repository.dart';

class ProductListBloc extends Bloc<ProductListPageEvent, ProductListPageState> {
  final ProductRepository repository;
  
  // Store the full list in memory for quick filtering
  List<Product> _allProducts = [];

  ProductListBloc({required this.repository}) : super(ProductListInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<FilterProductsEvent>(_onFilterProducts);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<ToggleProductStatusEvent>(_onToggleProductStatus);
  }

  Future<void> _onLoadProducts(LoadProductsEvent event, Emitter<ProductListPageState> emit) async {
    emit(ProductListLoading());
    try {
      _allProducts = await repository.getProducts();
      _emitFilteredState(emit, 'All');
    } catch (e) {
      emit(ProductListError(e.toString()));
    }
  }

  void _onFilterProducts(FilterProductsEvent event, Emitter<ProductListPageState> emit) {
    if (state is ProductListLoaded || state is ProductListInitial) {
      _emitFilteredState(emit, event.filterType);
    }
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductListPageState> emit) async {
    if (state is ProductListLoaded) {
      final currentState = state as ProductListLoaded;
      final currentFilter = currentState.activeFilter;
      
      // Optimistic update could be done here, but let's re-fetch for simplicity/accuracy
      emit(ProductListLoading());
      try {
        await repository.deleteProduct(event.productId);
        _allProducts = await repository.getProducts();
        _emitFilteredState(emit, currentFilter);
      } catch (e) {
        emit(ProductListError(e.toString()));
      }
    }
  }

  Future<void> _onToggleProductStatus(ToggleProductStatusEvent event, Emitter<ProductListPageState> emit) async {
    if (state is ProductListLoaded) {
      final currentState = state as ProductListLoaded;
      final currentFilter = currentState.activeFilter;

      // Optimistic update could be done here, but let's re-fetch for simplicity/accuracy
      emit(ProductListLoading());
      try {
        await repository.toggleProductStatus(event.productId, event.isActive);
        _allProducts = await repository.getProducts();
        _emitFilteredState(emit, currentFilter);
      } catch (e) {
        emit(ProductListError(e.toString()));
      }
    }
  }

  void _emitFilteredState(Emitter<ProductListPageState> emit, String filterType) {
    List<Product> filteredList;
    
    if (filterType == 'Active') {
      filteredList = _allProducts.where((p) => p.isActive).toList();
    } else if (filterType == 'Inactive') {
      filteredList = _allProducts.where((p) => !p.isActive).toList();
    } else if (filterType == 'Low Stock') {
      filteredList = _allProducts.where((p) => p.status == ProductStatus.lowStock).toList();
    } else if (filterType == 'Veg') {
      filteredList = _allProducts.where((p) => p.foodType.toLowerCase() == 'veg' || p.foodType.toLowerCase() == 'vegetarian').toList();
    } else if (filterType == 'Non-Veg') {
      filteredList = _allProducts.where((p) => p.foodType.toLowerCase() == 'non-veg' || p.foodType.toLowerCase() == 'non-vegetarian').toList();
    } else {
      filteredList = List.from(_allProducts);
      filterType = 'All Products';
    }

    final allCount = _allProducts.length;
    final activeCount = _allProducts.where((p) => p.isActive).length;
    final inactiveCount = _allProducts.where((p) => !p.isActive).length;
    final lowStockCount = _allProducts.where((p) => p.status == ProductStatus.lowStock).length;
    final vegCount = _allProducts.where((p) => p.foodType.toLowerCase() == 'veg' || p.foodType.toLowerCase() == 'vegetarian').length;
    final nonVegCount = _allProducts.where((p) => p.foodType.toLowerCase() == 'non-veg' || p.foodType.toLowerCase() == 'non-vegetarian').length;

    emit(ProductListLoaded(
      products: filteredList,
      activeFilter: filterType,
      allCount: allCount,
      activeCount: activeCount,
      inactiveCount: inactiveCount,
      lowStockCount: lowStockCount,
      vegCount: vegCount,
      nonVegCount: nonVegCount,
    ));
  }
}
