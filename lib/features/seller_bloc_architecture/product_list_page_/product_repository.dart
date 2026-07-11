import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_model.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Stream<List<Product>> getProductsStream();
  Future<void> deleteProduct(String id);
  Future<void> toggleProductStatus(String id, bool isActive);
}

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _sellerId => _auth.currentUser?.uid ?? '';

  @override
  Future<List<Product>> getProducts() async {
    if (_sellerId.isEmpty) return [];
    
    final snapshot = await _firestore
        .collection('products')
        .where('sellerId', isEqualTo: _sellerId)
        .get();
        
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Stream<List<Product>> getProductsStream() {
    if (_sellerId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: _sellerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  @override
  Future<void> toggleProductStatus(String id, bool isActive) async {
    await _firestore.collection('products').doc(id).update({'isActive': isActive});
  }
}
