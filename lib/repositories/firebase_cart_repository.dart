import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/repositories/i_cart_repository.dart';
import '../features/buyer_bloc_architecture/Cart Page/cart_models.dart';

class FirebaseCartRepository implements ICartRepository {
  final FirebaseFirestore _firestore;

  FirebaseCartRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCartCollection(String buyerId) {
    return _firestore.collection('users').doc(buyerId).collection('cart');
  }

  @override
  Stream<List<CartItem>> getCartItemsStream(String buyerId) {
    if (buyerId.isEmpty) return Stream.value([]);
    
    return _getCartCollection(buyerId).snapshots(includeMetadataChanges: true).map((snapshot) {
      return snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addItem(String buyerId, CartItem item) async {
    if (buyerId.isEmpty) return;

    final docRef = _getCartCollection(buyerId).doc(item.id);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);

      if (docSnapshot.exists) {
        final currentQuantity = (docSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
        transaction.update(docRef, {
          'quantity': currentQuantity + item.quantity,
        });
      } else {
        transaction.set(docRef, item.toMap());
      }
    });
  }

  @override
  Future<void> removeItem(String buyerId, String itemId) async {
    if (buyerId.isEmpty) return;
    await _getCartCollection(buyerId).doc(itemId).delete();
  }

  @override
  Future<void> updateQuantity(String buyerId, String itemId, int delta) async {
    if (buyerId.isEmpty) return;

    final docRef = _getCartCollection(buyerId).doc(itemId);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);

      if (docSnapshot.exists) {
        final currentQuantity = (docSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
        final newQuantity = currentQuantity + delta;

        if (newQuantity <= 0) {
          transaction.delete(docRef);
        } else {
          transaction.update(docRef, {'quantity': newQuantity});
        }
      }
    });
  }

  @override
  Future<void> toggleSelection(String buyerId, String itemId, bool isSelected) async {
    if (buyerId.isEmpty) return;
    await _getCartCollection(buyerId).doc(itemId).update({'isSelected': isSelected});
  }

  @override
  Future<void> clearCart(String buyerId) async {
    if (buyerId.isEmpty) return;

    final snapshots = await _getCartCollection(buyerId).get();
    final batch = _firestore.batch();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Future<void> updateItemPrice(String buyerId, String itemId, double newPrice) async {
    if (buyerId.isEmpty) return;
    await _getCartCollection(buyerId).doc(itemId).update({'price': newPrice});
  }

  @override
  Future<void> checkoutCart(String buyerId, List<CartItem> selectedItems, String customerName, String deliveryAddress, {AppliedCoupon? appliedCoupon}) async {
    if (buyerId.isEmpty || selectedItems.isEmpty) return;

    final selectedCartItemsPayload = selectedItems.map((item) => {
      'id': item.id,
      'quantity': item.quantity,
      'sellerId': item.sellerId,
    }).toList();

    final payload = <String, dynamic>{
      'selectedCartItems': selectedCartItemsPayload,
      'customerName': customerName,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': 'Wallet',
    };

    if (appliedCoupon != null) {
      payload['coupon'] = appliedCoupon.toMap();
    }

    final httpsCallable = FirebaseFunctions.instance.httpsCallable('createSecureOrder');
    await httpsCallable.call(payload);
  }
}
