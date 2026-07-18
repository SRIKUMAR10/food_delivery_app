import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/inventory_item_model.dart';
import '../core/models/inventory_history_log_model.dart';
import '../core/repositories/i_inventory_repository.dart';

class FirebaseInventoryRepository implements IInventoryRepository {
  final FirebaseFirestore _firestore;

  FirebaseInventoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<InventoryItemModel>> getInventoryStream(String sellerId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return InventoryItemModel(
          id: doc.id,
          name: data['name'] as String? ?? 'Unknown Product',
          quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
          unit: data['unit'] as String? ?? 'pcs',
          lowStockThreshold: (data['lowStockThreshold'] as num?)?.toInt() ?? 5,
          imagePath: data['imageUrl'] as String?,
          category: data['category'] as String? ?? 'General',
          sku: data['sku'] as String? ?? 'SKU-${doc.id.substring(0, 4)}',
          expiryDate: data['expiryDate'] != null 
              ? (data['expiryDate'] as Timestamp).toDate() 
              : null,
        );
      }).toList();
    });
  }

  @override
  Future<void> updateStock({
    required String sellerId,
    required String productId,
    required double quantityChange,
    required String reason,
    String? note,
  }) async {
    if (quantityChange == 0) return;

    final productRef = _firestore.collection('products').doc(productId);
    final logRef = _firestore.collection('inventory_logs').doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);
      if (!snapshot.exists) {
        throw Exception('Product not found');
      }

      final data = snapshot.data()!;
      if (data['sellerId'] != sellerId) {
        throw Exception('Unauthorized to update this product');
      }

      final currentQuantity = (data['quantity'] as num?)?.toDouble() ?? 0.0;
      final newQuantity = currentQuantity + quantityChange;

      if (newQuantity < 0) {
        throw Exception('Negative stock is not allowed.');
      }

      final actionType = quantityChange > 0 ? 'Increase' : 'Decrease';

      // Update product
      transaction.update(productRef, {'quantity': newQuantity});

      // Create log
      transaction.set(logRef, {
        'productId': productId,
        'sellerId': sellerId,
        'previousQuantity': currentQuantity,
        'newQuantity': newQuantity,
        'quantityChanged': quantityChange,
        'actionType': actionType,
        'reason': reason,
        'note': note,
        'timestamp': FieldValue.serverTimestamp(),
        'updatedBy': sellerId,
      });
    });
  }

  @override
  Future<void> bulkUpdateStock({
    required String sellerId,
    required List<String> productIds,
    required double quantityChange,
    required String reason,
    String? note,
  }) async {
    if (productIds.isEmpty || quantityChange == 0) return;

    final batch = _firestore.batch();
    
    // We must read the current quantities to log them accurately.
    // Batch doesn't allow reads, so we fetch them first, then batch write.
    // For extreme concurrent safety, we could use runTransaction on multiple docs,
    // but Firestore limits transactions to 500 reads. Batch is safer here for bulk.
    // If strict serializability is needed for bulk, we'll fetch then batch.
    
    final snapshots = await Future.wait(
      productIds.map((id) => _firestore.collection('products').doc(id).get())
    );

    for (var snapshot in snapshots) {
      if (!snapshot.exists) continue;
      final data = snapshot.data()!;
      if (data['sellerId'] != sellerId) continue;

      final currentQuantity = (data['quantity'] as num?)?.toDouble() ?? 0.0;
      final newQuantity = currentQuantity + quantityChange;
      
      if (newQuantity < 0) {
        throw Exception('Negative stock is not allowed for product: ${data['name']}');
      }

      final actionType = quantityChange > 0 ? 'Increase' : 'Decrease';
      
      final productRef = snapshot.reference;
      final logRef = _firestore.collection('inventory_logs').doc();

      batch.update(productRef, {'quantity': newQuantity});
      batch.set(logRef, {
        'productId': snapshot.id,
        'sellerId': sellerId,
        'previousQuantity': currentQuantity,
        'newQuantity': newQuantity,
        'quantityChanged': quantityChange,
        'actionType': actionType,
        'reason': reason,
        'note': note,
        'timestamp': FieldValue.serverTimestamp(),
        'updatedBy': sellerId,
      });
    }

    await batch.commit();
  }

  @override
  Future<void> addProduct({
    required String sellerId,
    required InventoryItemModel item,
  }) async {
    final productRef = _firestore.collection('products').doc();
    final logRef = _firestore.collection('inventory_logs').doc();

    await _firestore.runTransaction((transaction) async {
      transaction.set(productRef, {
        'sellerId': sellerId,
        'name': item.name,
        'quantity': item.quantity,
        'unit': item.unit,
        'category': item.category,
        'sku': item.sku,
        'lowStockThreshold': item.lowStockThreshold,
        if (item.imagePath != null) 'imageUrl': item.imagePath,
        if (item.expiryDate != null) 'expiryDate': Timestamp.fromDate(item.expiryDate!),
      });

      transaction.set(logRef, {
        'productId': productRef.id,
        'sellerId': sellerId,
        'previousQuantity': 0.0,
        'newQuantity': item.quantity,
        'quantityChanged': item.quantity,
        'actionType': 'Initial Stock',
        'reason': 'Added new product',
        'timestamp': FieldValue.serverTimestamp(),
        'updatedBy': sellerId,
      });
    });
  }

  @override
  Future<List<InventoryHistoryLogModel>> getInventoryHistory(String productId) async {
    final snapshot = await _firestore
        .collection('inventory_logs')
        .where('productId', isEqualTo: productId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return InventoryHistoryLogModel(
        id: doc.id,
        productId: data['productId'] ?? '',
        previousQuantity: (data['previousQuantity'] as num?)?.toDouble() ?? 0.0,
        newQuantity: (data['newQuantity'] as num?)?.toDouble() ?? 0.0,
        quantityChanged: (data['quantityChanged'] as num?)?.toDouble() ?? 0.0,
        actionType: data['actionType'] ?? 'Update',
        reason: data['reason'] ?? 'Manual Adjustment',
        timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedBy: data['updatedBy'] ?? '',
        note: data['note'],
      );
    }).toList();
  }
}
