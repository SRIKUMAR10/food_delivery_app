// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/inventory_item_model.dart';
import 'inventory_low_stock_page_event.dart';
import 'inventory_low_stock_page_state.dart';
import '../../../../core/repositories/i_inventory_repository.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final IInventoryRepository repository;
  StreamSubscription? _inventorySubscription;

  InventoryBloc({required this.repository}) : super(InventoryInitial()) {
    on<LoadInventoryStream>(_onLoadInventoryStream);
    on<SearchInventory>(_onSearchInventory);
    on<FilterInventory>(_onFilterInventory);
    on<UpdateStockEvent>(_onUpdateStockEvent);
    on<BulkUpdateStockEvent>(_onBulkUpdateStockEvent);
    on<AddProductEvent>(_onAddProductEvent);
    on<ClearInventoryMessage>(_onClearMessage);
    on<_InventoryDataReceived>(_onDataReceived);
    on<_InventoryErrorReceived>(_onInventoryError);
  }

  void _onLoadInventoryStream(LoadInventoryStream event, Emitter<InventoryState> emit) {
    emit(InventoryLoading());
    _inventorySubscription?.cancel();
    _inventorySubscription = repository.getInventoryStream(event.sellerId).listen(
      (items) {
        // If already loaded, we want to maintain filters/search.
        // But since we can't emit from a listen easily without adding another event,
        // we'll just handle it by emitting a new Loaded state.
        final currentState = state;
        String activeFilter = 'All';
        String searchQuery = '';
        Set<String> updatingIds = {};
        
        if (currentState is InventoryLoaded) {
          activeFilter = currentState.activeFilter;
          searchQuery = currentState.searchQuery;
          updatingIds = currentState.updatingItemIds;
        }

        final summary = _calculateSummary(items);
        final filteredItems = _applyFilters(items, activeFilter, searchQuery);

        // We use add() to push this safely, wait, we are inside a bloc.
        // It's better to add an internal event for data received.
        // I will just emit it if the listener is synchronous, but wait, emit is only valid inside the event handler.
        // So I should dispatch an internal event.
        add(_InventoryDataReceived(
          sellerId: event.sellerId,
          items: items,
          summary: summary,
          filteredItems: filteredItems,
          activeFilter: activeFilter,
          searchQuery: searchQuery,
          updatingIds: updatingIds,
        ));
      },
      onError: (error) {
        add(_InventoryErrorReceived(error.toString()));
      }
    );
  }

  // Internal event handler
  void _onInventoryError(_InventoryErrorReceived event, Emitter<InventoryState> emit) {
    if (state is InventoryLoading) {
      emit(InventoryError(message: event.message));
    } else if (state is InventoryLoaded) {
      emit((state as InventoryLoaded).copyWith(
        errorMessage: () => event.message,
      ));
    }
  }

  void _onDataReceived(_InventoryDataReceived event, Emitter<InventoryState> emit) {
    emit(InventoryLoaded(
      sellerId: event.sellerId,
      allItems: event.items,
      filteredItems: event.filteredItems,
      summary: event.summary,
      activeFilter: event.activeFilter,
      searchQuery: event.searchQuery,
      updatingItemIds: event.updatingIds,
    ));
  }

  void _onSearchInventory(SearchInventory event, Emitter<InventoryState> emit) {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      final filtered = _applyFilters(currentState.allItems, currentState.activeFilter, event.query);
      emit(currentState.copyWith(searchQuery: event.query, filteredItems: filtered));
    }
  }

  void _onFilterInventory(FilterInventory event, Emitter<InventoryState> emit) {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      final filtered = _applyFilters(currentState.allItems, event.status, currentState.searchQuery);
      emit(currentState.copyWith(activeFilter: event.status, filteredItems: filtered));
    }
  }

  Future<void> _onUpdateStockEvent(UpdateStockEvent event, Emitter<InventoryState> emit) async {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      
      final updatedIds = Set<String>.from(currentState.updatingItemIds)..add(event.productId);
      emit(currentState.copyWith(updatingItemIds: updatedIds));

      try {
        await repository.updateStock(
          sellerId: currentState.sellerId,
          productId: event.productId,
          quantityChange: event.quantityChange,
          reason: event.reason,
          note: event.note,
        );

        final newIds = Set<String>.from(currentState.updatingItemIds)..remove(event.productId);
        emit(currentState.copyWith(
          updatingItemIds: newIds,
          successMessage: () => 'Stock updated successfully.',
        ));
      } catch (e) {
        final newIds = Set<String>.from(currentState.updatingItemIds)..remove(event.productId);
        emit(currentState.copyWith(
          updatingItemIds: newIds,
          errorMessage: () => e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onBulkUpdateStockEvent(BulkUpdateStockEvent event, Emitter<InventoryState> emit) async {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      
      final updatedIds = Set<String>.from(currentState.updatingItemIds)..addAll(event.productIds);
      emit(currentState.copyWith(updatingItemIds: updatedIds));

      try {
        await repository.bulkUpdateStock(
          sellerId: currentState.sellerId,
          productIds: event.productIds,
          quantityChange: event.quantityChange,
          reason: event.reason,
          note: event.note,
        );

        final newIds = Set<String>.from(currentState.updatingItemIds)..removeAll(event.productIds);
        emit(currentState.copyWith(
          updatingItemIds: newIds,
          successMessage: () => '${event.productIds.length} products updated successfully.',
        ));
      } catch (e) {
        final newIds = Set<String>.from(currentState.updatingItemIds)..removeAll(event.productIds);
        emit(currentState.copyWith(
          updatingItemIds: newIds,
          errorMessage: () => e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  void _onClearMessage(ClearInventoryMessage event, Emitter<InventoryState> emit) {
    if (state is InventoryLoaded) {
      emit((state as InventoryLoaded).copyWith(
        successMessage: () => null,
        errorMessage: () => null,
      ));
    }
  }

  Future<void> _onAddProductEvent(AddProductEvent event, Emitter<InventoryState> emit) async {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      try {
        await repository.addProduct(
          sellerId: currentState.sellerId,
          item: event.item,
        );
        emit(currentState.copyWith(successMessage: () => 'Product added successfully'));
      } catch (e) {
        emit(currentState.copyWith(errorMessage: () => 'Failed to add product: ${e.toString()}'));
      }
    }
  }

  InventorySummary _calculateSummary(List<InventoryItemModel> items) {
    int normal = 0;
    int low = 0;
    int outOfStock = 0;
    int expSoon = 0;
    int expired = 0;

    for (var item in items) {
      if (item.isOutOfStock) {
        outOfStock++;
      } else if (item.isLowStock) {
        low++;
      } else {
        normal++;
      }

      if (item.isExpired) {
        expired++;
      } else if (item.isExpiringSoon) {
        expSoon++;
      }
    }

    return InventorySummary(
      totalItems: items.length,
      normalStock: normal,
      lowStock: low,
      outOfStock: outOfStock,
      expiringSoon: expSoon,
      expired: expired,
    );
  }

  List<InventoryItemModel> _applyFilters(List<InventoryItemModel> items, String filter, String query) {
    return items.where((item) {
      bool matchesSearch = item.name.toLowerCase().contains(query.toLowerCase());
      bool matchesFilter = true;

      switch (filter) {
        case 'Normal':
          matchesFilter = !item.isOutOfStock && !item.isLowStock;
          break;
        case 'Low Stock':
          matchesFilter = item.isLowStock;
          break;
        case 'Out of Stock':
          matchesFilter = item.isOutOfStock;
          break;
        case 'Expiring Soon':
          matchesFilter = item.isExpiringSoon || item.isExpired; // Let's include expired in this filter too for ease
          break;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Future<void> close() {
    _inventorySubscription?.cancel();
    return super.close();
  }
}

// Internal event for stream listener mapping
class _InventoryDataReceived extends InventoryEvent {
  final String sellerId;
  final List<InventoryItemModel> items;
  final InventorySummary summary;
  final List<InventoryItemModel> filteredItems;
  final String activeFilter;
  final String searchQuery;
  final Set<String> updatingIds;

  const _InventoryDataReceived({
    required this.sellerId,
    required this.items,
    required this.summary,
    required this.filteredItems,
    required this.activeFilter,
    required this.searchQuery,
    required this.updatingIds,
  });

  @override
  List<Object?> get props => [sellerId, items, summary, filteredItems, activeFilter, searchQuery, updatingIds];
}

class _InventoryErrorReceived extends InventoryEvent {
  final String message;
  const _InventoryErrorReceived(this.message);

  @override
  List<Object?> get props => [message];
}
