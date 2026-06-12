import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCollection {
  // 'products' என்ற பெயரில் Firestore collection-க்கான reference
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'products',
  );

  /// தயாரிப்பு விவரங்களை (Product details) ஒரு Map ஆகப் பெற்று,
  /// அதை Firestore-இல் புதிய ஆவணமாக (Document) சேர்க்கும் செயல்பாடு.
  Future<DocumentReference> addProduct(Map<String, dynamic> productData) async {
    // Firestore-இல் ஆவணத்தைச் சேர்த்து அதன் reference-ஐத் திருப்பி அளிக்கும்
    return await _collection.add(productData);
  }
}
