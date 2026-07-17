import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'product_model.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Stream<List<Product>> getProductsStream();
  Future<Product?> getProduct(String id);
  Future<void> deleteProduct(String id);
  Future<void> toggleProductStatus(String id, bool isActive);
  Future<void> archiveProduct(String id);
  Future<void> unarchiveProduct(String id);
  Future<void> duplicateProduct(String id);
  Future<void> addProduct(Product product, List<XFile> images);
  Future<void> updateProduct(Product product, List<XFile> newImages, List<String> existingImages);
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
  Future<Product?> getProduct(String id) async {
    if (_sellerId.isEmpty) return null;

    final doc = await _firestore.collection('products').doc(id).get();
    if (doc.exists && doc.data() != null) {
      if (doc.data()!['sellerId'] == _sellerId) {
        return Product.fromMap(doc.id, doc.data()!);
      }
    }
    return null;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  @override
  Future<void> toggleProductStatus(String id, bool isActive) async {
    await _firestore.collection('products').doc(id).update({
      'isActive': isActive,
    });
  }

  @override
  Future<void> archiveProduct(String id) async {
    await _firestore.collection('products').doc(id).update({
      'isArchived': true,
    });
  }

  @override
  Future<void> unarchiveProduct(String id) async {
    await _firestore.collection('products').doc(id).update({
      'isArchived': false,
    });
  }

  @override
  Future<void> duplicateProduct(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      data['name'] = '${data['name']} (Copy)';
      data['isArchived'] = false; // duplicated product is active by default
      data['createdAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('products').add(data);
    }
  }

  Future<List<String>> _uploadImages(List<XFile> images, String docId) async {
    final List<String> urls = [];
    final storageRef = FirebaseStorage.instance.ref().child('product_images/$docId');
    
    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final imageRef = storageRef.child('${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
      final bytes = await file.readAsBytes();
      final uploadTask = await imageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  @override
  Future<void> addProduct(Product product, List<XFile> images) async {
    if (_sellerId.isEmpty) return;
    
    final docRef = _firestore.collection('products').doc();
    final imageUrls = await _uploadImages(images, docRef.id);
    
    final productData = product.toMap();
    productData['sellerId'] = _sellerId;
    productData['imageUrls'] = imageUrls;
    productData['createdAt'] = FieldValue.serverTimestamp();
    
    await docRef.set(productData);
  }

  @override
  Future<void> updateProduct(Product product, List<XFile> newImages, List<String> existingImages) async {
    if (_sellerId.isEmpty) return;
    
    final newImageUrls = await _uploadImages(newImages, product.id);
    final allImageUrls = [...existingImages, ...newImageUrls];
    
    final productData = product.toMap();
    productData['sellerId'] = _sellerId;
    productData['imageUrls'] = allImageUrls;
    productData['updatedAt'] = FieldValue.serverTimestamp();
    
    await _firestore.collection('products').doc(product.id).update(productData);
  }
}
