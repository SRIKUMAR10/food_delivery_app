import 'package:equatable/equatable.dart';
import '../../../../core/models/inventory_item_model.dart';
import '../../../../core/models/inventory_history_log_model.dart';

class InventorySummary extends Equatable {
  final int totalItems;
  final int normalStock;
  final int lowStock;
  final int outOfStock;
  final int expiringSoon;
  final int expired;

  const InventorySummary({
    this.totalItems = 0,
    this.normalStock = 0,
    this.lowStock = 0,
    this.outOfStock = 0,
    this.expiringSoon = 0,
    this.expired = 0,
  });

  double get healthScorePercentage {
    if (totalItems == 0) return 100.0;
    final unhealthy = (outOfStock * 2) + lowStock;
    final maxScore = totalItems * 2;
    final score = ((maxScore - unhealthy) / maxScore) * 100.0;
    return score.clamp(0.0, 100.0);
  }

  @override
  List<Object?> get props => [
    totalItems,
    normalStock,
    lowStock,
    outOfStock,
    expiringSoon,
    expired,
  ];
}

abstract class InventoryState extends Equatable {
  const InventoryState();
  
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryError extends InventoryState {
  final String message;
  const InventoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

class InventoryLoaded extends InventoryState {
  final String sellerId;
  final List<InventoryItemModel> allItems;
  final List<InventoryItemModel> filteredItems;
  final InventorySummary summary;
  
  final String activeFilter; // 'All', 'Normal', 'Low Stock', 'Out of Stock', 'Expiring Soon'
  final String searchQuery;

  final Set<String> updatingItemIds;
  final List<InventoryHistoryLogModel> historyLogs;
  final bool isLoadingHistory;
  final String? selectedHistoryProductId;
  final String? successMessage;
  final String? errorMessage;

  const InventoryLoaded({
    required this.sellerId,
    required this.allItems,
    required this.filteredItems,
    required this.summary,
    this.activeFilter = 'All',
    this.searchQuery = '',
    this.updatingItemIds = const {},
    this.historyLogs = const [],
    this.isLoadingHistory = false,
    this.selectedHistoryProductId,
    this.successMessage,
    this.errorMessage,
  });

  InventoryLoaded copyWith({
    String? sellerId,
    List<InventoryItemModel>? allItems,
    List<InventoryItemModel>? filteredItems,
    InventorySummary? summary,
    String? activeFilter,
    String? searchQuery,
    Set<String>? updatingItemIds,
    List<InventoryHistoryLogModel>? historyLogs,
    bool? isLoadingHistory,
    String? Function()? selectedHistoryProductId,
    String? Function()? successMessage,
    String? Function()? errorMessage,
  }) {
    return InventoryLoaded(
      sellerId: sellerId ?? this.sellerId,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      summary: summary ?? this.summary,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      updatingItemIds: updatingItemIds ?? this.updatingItemIds,
      historyLogs: historyLogs ?? this.historyLogs,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      selectedHistoryProductId: selectedHistoryProductId != null
          ? selectedHistoryProductId()
          : this.selectedHistoryProductId,
      successMessage: successMessage != null ? successMessage() : this.successMessage,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    sellerId,
    allItems,
    filteredItems,
    summary,
    activeFilter,
    searchQuery,
    updatingItemIds,
    historyLogs,
    isLoadingHistory,
    selectedHistoryProductId,
    successMessage,
    errorMessage,
  ];
}
