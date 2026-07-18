import '../models/inventory_item_model.dart';
import '../models/inventory_history_log_model.dart';

abstract interface class IInventoryRepository {
  Stream<List<InventoryItemModel>> getInventoryStream(String sellerId);
  
  Future<void> updateStock({
    required String sellerId,
    required String productId,
    required double quantityChange,
    required String reason,
    String? note,
  });

  Future<void> bulkUpdateStock({
    required String sellerId,
    required List<String> productIds,
    required double quantityChange,
    required String reason,
    String? note,
  });

  Future<void> addProduct({
    required String sellerId,
    required InventoryItemModel item,
  });

  Future<List<InventoryHistoryLogModel>> getInventoryHistory(String productId);
}
