import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late InventoryRepository repository;
  const String sellerId = 'seller123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = InventoryRepository(firestore: fakeFirestore);
  });

  group('InventoryRepository', () {
    test('updateStock updates availableStock and creates log successfully', () async {
      // Create product
      final docRef = fakeFirestore.collection('products').doc('p1');
      await docRef.set({
        'sellerId': sellerId,
        'name': 'Test Product',
        'availableStock': 10,
        'quantity': 10,
      });

      // Execute
      await repository.updateStock(
        sellerId: sellerId,
        productId: 'p1',
        quantityChange: 5,
        reason: 'Supplier Restock',
      );

      // Verify Product
      final productSnap = await docRef.get();
      expect(productSnap.data()!['availableStock'], 15);
      expect(productSnap.data()!['status'], 'available');

      // Verify Log
      final logsSnap = await fakeFirestore.collection('inventory_logs').get();
      expect(logsSnap.docs.length, 1);
      final logData = logsSnap.docs.first.data();
      expect(logData['productId'], 'p1');
      expect(logData['previousQuantity'], 10);
      expect(logData['newQuantity'], 15);
      expect(logData['actionType'], 'Increase');
      expect(logData['reason'], 'Supplier Restock');
    });

    test('setAbsoluteStock sets stock value and status accurately', () async {
      final docRef = fakeFirestore.collection('products').doc('p1');
      await docRef.set({
        'sellerId': sellerId,
        'name': 'Test Product',
        'availableStock': 10,
      });

      await repository.setAbsoluteStock(
        sellerId: sellerId,
        productId: 'p1',
        newQuantity: 0,
        reason: 'Manual Adjustment',
      );

      final productSnap = await docRef.get();
      expect(productSnap.data()!['availableStock'], 0);
      expect(productSnap.data()!['status'], 'outOfStock');

      final logsSnap = await fakeFirestore.collection('inventory_logs').get();
      expect(logsSnap.docs.length, 1);
      final logData = logsSnap.docs.first.data();
      expect(logData['actionType'], 'Set');
      expect(logData['newQuantity'], 0);
    });

    test('updateLowStockThreshold modifies threshold in firestore', () async {
      final docRef = fakeFirestore.collection('products').doc('p1');
      await docRef.set({
        'sellerId': sellerId,
        'name': 'Test Product',
        'lowStockThreshold': 5,
      });

      await repository.updateLowStockThreshold(
        sellerId: sellerId,
        productId: 'p1',
        threshold: 15,
      );

      final productSnap = await docRef.get();
      expect(productSnap.data()!['lowStockThreshold'], 15);
      expect(productSnap.data()!['minimumAlert'], 15);
    });

    test('updateStock rejects negative resulting quantity', () async {
      final docRef = fakeFirestore.collection('products').doc('p2');
      await docRef.set({
        'sellerId': sellerId,
        'name': 'Test Product 2',
        'availableStock': 2,
      });

      expect(
        () => repository.updateStock(
          sellerId: sellerId,
          productId: 'p2',
          quantityChange: -5,
          reason: 'Damaged',
        ),
        throwsException,
      );

      // Verify no changes occurred
      final productSnap = await docRef.get();
      expect(productSnap.data()!['availableStock'], 2);
      final logsSnap = await fakeFirestore.collection('inventory_logs').get();
      expect(logsSnap.docs.length, 0);
    });

    test('bulkUpdateStock updates multiple and creates multiple logs', () async {
      await fakeFirestore.collection('products').doc('p1').set({'sellerId': sellerId, 'availableStock': 10});
      await fakeFirestore.collection('products').doc('p2').set({'sellerId': sellerId, 'availableStock': 20});

      await repository.bulkUpdateStock(
        sellerId: sellerId,
        productIds: ['p1', 'p2'],
        quantityChange: -2,
        reason: 'Expired',
      );

      final p1Snap = await fakeFirestore.collection('products').doc('p1').get();
      expect(p1Snap.data()!['availableStock'], 8);
      final p2Snap = await fakeFirestore.collection('products').doc('p2').get();
      expect(p2Snap.data()!['availableStock'], 18);

      final logsSnap = await fakeFirestore.collection('inventory_logs').get();
      expect(logsSnap.docs.length, 2);
    });
  });
}
