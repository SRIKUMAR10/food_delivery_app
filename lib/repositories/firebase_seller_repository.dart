import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/seller_model.dart';
import '../core/repositories/i_seller_repository.dart';

class FirebaseSellerRepository implements ISellerRepository {
  final FirebaseFirestore firestore;

  FirebaseSellerRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<double> getGstPercentage(String sellerId) async {
    final doc = await firestore.collection('sellers').doc(sellerId).get();
    if (doc.exists) {
      final data = doc.data();
      return (data?['gstPercentage'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  @override
  Future<SellerModel?> getSeller(String sellerId) async {
    final doc = await firestore.collection('sellers').doc(sellerId).get();
    if (doc.exists) {
      return SellerModel.fromFirestore(doc);
    }
    return null;
  }
}
