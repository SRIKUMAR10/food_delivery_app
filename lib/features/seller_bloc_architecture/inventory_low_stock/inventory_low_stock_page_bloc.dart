// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/inventory_item_model.dart';
import '../../../../core/models/inventory_history_log_model.dart';
import 'inventory_low_stock_page_event.dart';
import 'inventory_low_stock_page_state.dart';
import '../../../../core/repositories/i_inventory_repository.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final IInventoryRepository repository;
  StreamSubscription? _inventorySubscription;
  StreamSubscription? _historySubscription;

  InventoryBloc({required this.repository}) : super(InventoryInitial()) {
    on<LoadInventoryStream>(_onLoadInventoryStream);
    on<SearchInventory>(_onSearchInventory);
    on<FilterInventory>(_onFilterInventory);
    on<UpdateStockEvent>(_onUpdateStockEvent);
    on<SetAbsoluteStockEvent>(_onSetAbsoluteStockEvent);
    on<UpdateLowStockThresholdEvent>(_onUpdateLowStockThresholdEvent);
    on<BulkUpdateStockEvent>(_onBulkUpdateStockEvent);
    on<LoadInventoryHistoryEvent>(_onLoadInventoryHistoryEvent);
    on<AddProductEvent>(_onAddProductEvent);
    on<ClearInventoryMessage>(_onClearMessage);
    on<InventoryDataReceived>(_onDataReceived);
    on<InventoryHistoryReceived>(_onHistoryReceived);
    on<InventoryErrorReceived>(_onInventoryError);
  }

  void _onLoadInventoryStream(LoadInventoryStream event, Emitter<InventoryState> emit) {
    emit(InventoryLoading());
    _inventorySubscription?.cancel();
    _inventorySubscription = repository.getInventoryStream(event.sellerId).listen(
      (items) {
        add(InventoryDataReceived(
          sellerId: event.sellerId,
          items: items,
        ));
      },
      onError: (error) {
        add(InventoryErrorReceived(error.toString()));
      },
    );
  }

  void _onDataReceived(InventoryDataReceived event, Emitter<InventoryState> emit) {
    final currentState = state;
    String activeFilter = 'All';
    String searchQuery = '';
    Set<String> updatingIds = {};
    List<InventoryHistoryLogModel> existingHistory = [];
    bool isLoadingHistory = false;
    String? selectedHistoryProdId;

    if (currentState is InventoryLoaded) {
      activeFilter = currentState.activeFilter;
      searchQuery = currentState.searchQuery;
      updatingIds = currentState.updatingItemIds;
      existingHistory = currentState.historyLogs;
      isLoadingHistory = currentState.isLoadingHistory;
      selectedHistoryProdId = currentState.selectedHistoryProductId;
    }

    final summary = _calculateSummary(event.items);
    final filteredItems = _applyFilters(event.items, activeFilter, searchQuery);

    emit(InventoryLoaded(
      sellerId: event.sellerId,
      allItems: event.items,
      filteredItems: filteredItems,
      summary: summary,
      activeFilter: activeFilter,
      searchQuery: searchQuery,
      updatingItemIds: updatingIds,
      historyLogs: existingHistory,
      isLoadingHistory: isLoadingHistory,
      selectedHistoryProductId: selectedHistoryProdId,
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

  Future<void> _onSetAbsoluteStockEvent(SetAbsoluteStockEvent event, Emitter<InventoryState> emit) async {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      
      final updatedIds = Set<String>.from(currentState.updatingItemIds)..add(event.productId);
      emit(currentState.copyWith(updatingItemIds: updatedIds));

      try {
        await repository.setAbsoluteStock(
          sellerId: currentState.sellerId,
          productId: event.productId,
          newQuantity: event.newQuantity,
          reason: event.reason,
          note: event.note,
        );

        final newIds = Set<String>.from(currentState.updatingItemIds)..remove(event.productId);
        emit(currentState.copyWith(
          updatingItemIds: newIds,
          successMessage: () => 'Stock level set successfully.',
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

  Future<void> _onUpdateLowStockThresholdEvent(UpdateLowStockThresholdEvent event, Emitter<InventoryState> emit) async {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      try {
        await repository.updateLowStockThreshold(
          sellerId: currentState.sellerId,
          productId: event.productId,
          threshold: event.threshold,
        );
        emit(currentState.copyWith(
          successMessage: () => 'Low stock threshold updated to ${event.threshold}',
        ));
      } catch (e) {
        emit(currentState.copyWith(
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

  void _onLoadInventoryHistoryEvent(LoadInventoryHistoryEvent event, Emitter<InventoryState> emit) {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      emit(currentState.copyWith(
        isLoadingHistory: true,
        selectedHistoryProductId: () => event.productId,
      ));

      _historySubscription?.cancel();
      _historySubscription = repository.watchInventoryHistory(
        currentState.sellerId,
        productId: event.productId,
      ).listen(
        (logs) {
          add(InventoryHistoryReceived(logs));
        },
        onError: (error) {
          add(InventoryErrorReceived(error.toString()));
        },
      );
    }
  }

  void _onHistoryReceived(InventoryHistoryReceived event, Emitter<InventoryState> emit) {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      emit(currentState.copyWith(
        historyLogs: event.historyLogs,
        isLoadingHistory: false,
      ));
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

  void _onInventoryError(InventoryErrorReceived event, Emitter<InventoryState> emit) {
    if (state is InventoryLoading) {
      emit(InventoryError(message: event.message));
    } else if (state is InventoryLoaded) {
      emit((state as InventoryLoaded).copyWith(
        isLoadingHistory: false,
        errorMessage: () => event.message,
      ));
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
      bool matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.sku.toLowerCase().contains(query.toLowerCase()) ||
          item.category.toLowerCase().contains(query.toLowerCase());
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
          matchesFilter = item.isExpiringSoon || item.isExpired;
          break;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Future<void> close() {
    _inventorySubscription?.cancel();
    _historySubscription?.cancel();
    return super.close();
  }
}
