import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCollection {
  // Reference to the Firestore collection named 'products'
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'products',
  );

  /// Receives product details as a Map and 
  /// adds them as a new Document in Firestore.
  Future<DocumentReference> addProduct(Map<String, dynamic> productData) async {
    // Adds the document to Firestore and returns its reference
    return await _collection.add(productData);
  }
}
