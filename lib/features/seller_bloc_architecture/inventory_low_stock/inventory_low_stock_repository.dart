import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/inventory_item_model.dart';
import '../../../../core/models/inventory_history_log_model.dart';
import '../../../../core/repositories/i_inventory_repository.dart';

class InventoryRepository implements IInventoryRepository {
  final FirebaseFirestore _firestore;

  InventoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Stream<List<InventoryItemModel>> getInventoryStream(String sellerId) {
    if (sellerId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return InventoryItemModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  @override
  Stream<List<InventoryHistoryLogModel>> watchInventoryHistory(String sellerId, {String? productId}) {
    if (sellerId.isEmpty) return Stream.value([]);

    Query query = _firestore.collection('inventory_logs').where('sellerId', isEqualTo: sellerId);

    if (productId != null && productId.isNotEmpty) {
      query = query.where('productId', isEqualTo: productId);
    }

    return query
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return InventoryHistoryLogModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
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

      final currentQuantity = _parseDoubleSafely(data['availableStock'] ?? data['quantity'] ?? data['stock']);
      final newQuantity = currentQuantity + quantityChange;

      if (newQuantity < 0) {
        throw Exception('Negative stock is not allowed.');
      }

      final actionType = quantityChange > 0 ? 'Increase' : 'Decrease';
      final status = newQuantity <= 0 ? 'outOfStock' : 'available';

      // Update product
      transaction.update(productRef, {
        'availableStock': newQuantity.toInt(),
        'quantity': newQuantity,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create log
      transaction.set(logRef, {
        'productId': productId,
        'productName': data['name'] ?? 'Product',
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
  Future<void> setAbsoluteStock({
    required String sellerId,
    required String productId,
    required double newQuantity,
    required String reason,
    String? note,
  }) async {
    if (newQuantity < 0) {
      throw Exception('Negative stock is not allowed.');
    }

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

      final currentQuantity = _parseDoubleSafely(data['availableStock'] ?? data['quantity'] ?? data['stock']);
      final quantityChanged = newQuantity - currentQuantity;
      final status = newQuantity <= 0 ? 'outOfStock' : 'available';

      // Update product
      transaction.update(productRef, {
        'availableStock': newQuantity.toInt(),
        'quantity': newQuantity,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create log
      transaction.set(logRef, {
        'productId': productId,
        'productName': data['name'] ?? 'Product',
        'sellerId': sellerId,
        'previousQuantity': currentQuantity,
        'newQuantity': newQuantity,
        'quantityChanged': quantityChanged,
        'actionType': 'Set',
        'reason': reason,
        'note': note,
        'timestamp': FieldValue.serverTimestamp(),
        'updatedBy': sellerId,
      });
    });
  }

  @override
  Future<void> updateLowStockThreshold({
    required String sellerId,
    required String productId,
    required int threshold,
  }) async {
    final productRef = _firestore.collection('products').doc(productId);
    final snapshot = await productRef.get();
    if (!snapshot.exists) throw Exception('Product not found');
    final data = snapshot.data()!;
    if (data['sellerId'] != sellerId) {
      throw Exception('Unauthorized to update this product');
    }

    await productRef.update({
      'lowStockThreshold': threshold,
      'minimumAlert': threshold,
      'updatedAt': FieldValue.serverTimestamp(),
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
    final snapshots = await Future.wait(
      productIds.map((id) => _firestore.collection('products').doc(id).get())
    );

    for (var snapshot in snapshots) {
      if (!snapshot.exists) continue;
      final data = snapshot.data()!;
      if (data['sellerId'] != sellerId) continue;

      final currentQuantity = _parseDoubleSafely(data['availableStock'] ?? data['quantity'] ?? data['stock']);
      final newQuantity = currentQuantity + quantityChange;

      if (newQuantity < 0) {
        throw Exception('Negative stock is not allowed for product: ${data['name']}');
      }

      final actionType = quantityChange > 0 ? 'Increase' : 'Decrease';
      final status = newQuantity <= 0 ? 'outOfStock' : 'available';

      final productRef = snapshot.reference;
      final logRef = _firestore.collection('inventory_logs').doc();

      batch.update(productRef, {
        'availableStock': newQuantity.toInt(),
        'quantity': newQuantity,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(logRef, {
        'productId': snapshot.id,
        'productName': data['name'] ?? 'Product',
        'sellerId': sellerId,
        'previousQuantity': currentQuantity,
        'newQuantity': newQuantity,
        'quantityChanged': quantityChange,
        'actionType': 'Bulk Update ($actionType)',
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
        'availableStock': item.quantity.toInt(),
        'quantity': item.quantity,
        'unit': item.unit,
        'category': item.category,
        'sku': item.sku,
        'lowStockThreshold': item.lowStockThreshold,
        'minimumAlert': item.lowStockThreshold,
        'price': item.price,
        'isActive': item.isActive,
        'status': item.isOutOfStock ? 'outOfStock' : 'available',
        'hasUnlimitedStock': item.hasUnlimitedStock,
        if (item.imagePath != null) 'imageUrl': item.imagePath,
        if (item.expiryDate != null) 'expiryDate': Timestamp.fromDate(item.expiryDate!),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(logRef, {
        'productId': productRef.id,
        'productName': item.name,
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
      return InventoryHistoryLogModel.fromMap(doc.id, doc.data());
    }).toList();
  }
}
