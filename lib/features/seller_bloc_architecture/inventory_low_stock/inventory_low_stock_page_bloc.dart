import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventory_low_stock_page_event.dart';
import 'inventory_low_stock_page_state.dart';

class InventoryLowStockPageBloc extends Bloc<InventoryLowStockPageEvent, InventoryLowStockPageState> {
  // Store the master list of all items for search/filtering
  List<InventoryItem> _allItems = [];
  String _currentQuery = '';
  String _currentStatus = 'All';
  List<String> _currentCategories = [];
  String _currentSort = 'Default';

  InventoryLowStockPageBloc() : super(InventoryInitial()) {
    on<LoadInventoryData>(_onLoadInventoryData);
    on<RefreshInventoryData>(_onRefreshInventoryData);
    on<SearchInventory>(_onSearchInventory);
    on<UpdateFilters>(_onUpdateFilters);
    on<UpdateStockQuantity>(_onUpdateStockQuantity);
    on<AddNewProduct>(_onAddNewProduct);
  }

  Future<void> _onLoadInventoryData(
    LoadInventoryData event,
    Emitter<InventoryLowStockPageState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock Data 
      _allItems = [
        const InventoryItem(
          id: '1',
          name: 'Cheese',
          quantity: 2.5,
          unit: 'kg',
          isLowStock: false,
          imagePath: 'assets/images/cheese.png',
          category: 'Dairy',
          sku: 'SKU-1001',
        ),
        const InventoryItem(
          id: '2',
          name: 'Tomato',
          quantity: 1.2,
          unit: 'kg',
          isLowStock: true,
          imagePath: 'assets/images/tomato.png',
          category: 'Vegetables',
          sku: 'SKU-1002',
        ),
        const InventoryItem(
          id: '3',
          name: 'Chicken',
          quantity: 0.8,
          unit: 'kg',
          isLowStock: true,
          imagePath: 'assets/images/chicken.png',
          category: 'Meat',
          sku: 'SKU-1003',
        ),
        const InventoryItem(
          id: '4',
          name: 'Dough',
          quantity: 5.0,
          unit: 'kg',
          isLowStock: false,
          imagePath: 'assets/images/dough.png',
          category: 'General',
          sku: 'SKU-1004',
        ),
        const InventoryItem(
          id: '5',
          name: 'Milk',
          quantity: 0.0,
          unit: 'L',
          isLowStock: true,
          imagePath: 'assets/images/milk.png',
          category: 'Dairy',
          sku: 'SKU-1005',
        ),
      ];

      _emitFilteredState(emit);
    } catch (e) {
      emit(const InventoryError('Failed to load inventory data'));
    }
  }

  Future<void> _onRefreshInventoryData(
    RefreshInventoryData event,
    Emitter<InventoryLowStockPageState> emit,
  ) async {
    // Reset filters and reload
    _currentQuery = '';
    _currentStatus = 'All';
    _currentCategories = [];
    _currentSort = 'Default';
    add(LoadInventoryData());
  }

  void _onSearchInventory(
    SearchInventory event,
    Emitter<InventoryLowStockPageState> emit,
  ) {
    _currentQuery = event.query.toLowerCase();
    _emitFilteredState(emit);
  }

  void _onUpdateFilters(
    UpdateFilters event,
    Emitter<InventoryLowStockPageState> emit,
  ) {
    if (event.status != null) _currentStatus = event.status!;
    if (event.categories != null) _currentCategories = event.categories!;
    if (event.sortOption != null) _currentSort = event.sortOption!;
    _emitFilteredState(emit);
  }

  void _onUpdateStockQuantity(
    UpdateStockQuantity event,
    Emitter<InventoryLowStockPageState> emit,
  ) {
    final itemIndex = _allItems.indexWhere((item) => item.id == event.id);
    if (itemIndex != -1) {
      final item = _allItems[itemIndex];
      // Basic rule for mock: if quantity <= 2, it's low stock
      final isLowStock = event.newQuantity > 0 && event.newQuantity <= 2;
      
      final updatedItem = InventoryItem(
        id: item.id,
        name: item.name,
        quantity: event.newQuantity,
        unit: item.unit,
        isLowStock: isLowStock,
        imagePath: item.imagePath,
        category: item.category,
        sku: item.sku,
      );

      _allItems[itemIndex] = updatedItem;
      _emitFilteredState(emit);
    }
  }

  void _onAddNewProduct(
    AddNewProduct event,
    Emitter<InventoryLowStockPageState> emit,
  ) {
    _allItems.insert(0, event.item); // Add to top of list
    _emitFilteredState(emit);
  }

  void _emitFilteredState(Emitter<InventoryLowStockPageState> emit) {
    // Apply search filter (Name, Category, SKU)
    var filteredList = _allItems.where((item) {
      final query = _currentQuery.toLowerCase();
      return item.name.toLowerCase().contains(query) ||
             item.category.toLowerCase().contains(query) ||
             item.sku.toLowerCase().contains(query);
    }).toList();

    // Apply category filter
    if (_currentCategories.isNotEmpty) {
      filteredList = filteredList.where((item) => _currentCategories.contains(item.category)).toList();
    }

    // Apply status filter
    if (_currentStatus == 'Low Stock') {
      filteredList = filteredList.where((item) => item.isLowStock && item.quantity > 0).toList();
    } else if (_currentStatus == 'Out of Stock') {
      filteredList = filteredList.where((item) => item.quantity == 0).toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case 'A-Z':
        filteredList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Z-A':
        filteredList.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Quantity (Low to High)':
        filteredList.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'Quantity (High to Low)':
        filteredList.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      default:
        break; // Default order
    }

    // Calculate Summary dynamically based on ALL items (or filtered items depending on UX needs. Usually summary reflects all items).
    // I will reflect all items in the summary.
    final totalItems = _allItems.length;
    final lowStockCount = _allItems.where((i) => i.isLowStock && i.quantity > 0).length;
    final outOfStockCount = _allItems.where((i) => i.quantity == 0).length;

    final summary = InventorySummary(
      totalItems: totalItems,
      lowStock: lowStockCount,
      outOfStock: outOfStockCount,
    );

    emit(InventoryLoaded(
      summary: summary,
      items: filteredList,
      activeStatus: _currentStatus,
      activeCategories: _currentCategories,
      activeSort: _currentSort,
      searchQuery: _currentQuery,
    ));
  }
}
