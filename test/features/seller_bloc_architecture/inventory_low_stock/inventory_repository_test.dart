import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late InventoryRepository repository;
  final String sellerId = 'seller123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = InventoryRepository(firestore: fakeFirestore);
  });

  group('InventoryRepository', () {
    test('updateStock updates quantity and creates log successfully', () async {
      // Create product
      final docRef = fakeFirestore.collection('products').doc('p1');
      await docRef.set({
        'sellerId': sellerId,
        'name': 'Test Product',
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
      expect(productSnap.data()!['quantity'], 15);

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

    test('updateStock rejects negative resulting quantity', () async {
      final docRef = fakeFirestore.collection('products').doc('p2');
      await docRef.set({
        'sellerId': sellerId,
        'name': 'Test Product 2',
        'quantity': 2,
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
      expect(productSnap.data()!['quantity'], 2); // Quantity unchanged
      final logsSnap = await fakeFirestore.collection('inventory_logs').get();
      expect(logsSnap.docs.length, 0); // No log created
    });

    test('bulkUpdateStock updates multiple and creates multiple logs', () async {
      await fakeFirestore.collection('products').doc('p1').set({'sellerId': sellerId, 'quantity': 10});
      await fakeFirestore.collection('products').doc('p2').set({'sellerId': sellerId, 'quantity': 20});

      await repository.bulkUpdateStock(
        sellerId: sellerId,
        productIds: ['p1', 'p2'],
        quantityChange: -2,
        reason: 'Expired',
      );

      final p1Snap = await fakeFirestore.collection('products').doc('p1').get();
      expect(p1Snap.data()!['quantity'], 8);
      final p2Snap = await fakeFirestore.collection('products').doc('p2').get();
      expect(p2Snap.data()!['quantity'], 18);

      final logsSnap = await fakeFirestore.collection('inventory_logs').get();
      expect(logsSnap.docs.length, 2);
    });

    test('bulkUpdateStock throws and rolls back if any product results in negative quantity', () async {
      await fakeFirestore.collection('products').doc('p1').set({'sellerId': sellerId, 'quantity': 10});
      await fakeFirestore.collection('products').doc('p2').set({'sellerId': sellerId, 'quantity': 1}); // This will go negative

      expect(
        () => repository.bulkUpdateStock(
          sellerId: sellerId,
          productIds: ['p1', 'p2'],
          quantityChange: -2,
          reason: 'Wastage',
        ),
        throwsException,
      );

      // Because it throws BEFORE commit, p1 should also remain unchanged
      final p1Snap = await fakeFirestore.collection('products').doc('p1').get();
      expect(p1Snap.data()!['quantity'], 10);
      final logsSnap = await fakeFirestore.collection('inventory_logs').get();
      expect(logsSnap.docs.length, 0);
    });
  });
}
