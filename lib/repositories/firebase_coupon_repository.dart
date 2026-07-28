import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/coupon_model.dart';
import '../core/repositories/i_coupon_repository.dart';

class FirebaseCouponRepository implements ICouponRepository {
  final FirebaseFirestore _firestore;

  FirebaseCouponRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<CouponModel>> getActiveCouponsBySellers(List<String> sellerIds) {
    if (sellerIds.isEmpty) return Stream.value([]);

    final now = Timestamp.now();
    return _firestore
        .collectionGroup('coupons')
        .where('isActive', isEqualTo: true)
        .where('expiryDate', isGreaterThan: now)
        .snapshots()
        .map((snapshot) {
      final coupons = snapshot.docs
          .map((doc) => CouponModel.fromMap(doc.data(), doc.id))
          .where((c) => sellerIds.contains(c.sellerId))
          .toList();
      return coupons;
    });
  }

  @override
  Future<CouponModel?> validateAndApplyCoupon(
      String couponCode, String sellerId, double orderTotal) async {
    final snapshot = await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('coupons')
        .where('code', isEqualTo: couponCode)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final coupon = CouponModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);

    if (!coupon.isValidForOrder(orderTotal)) return null;

    return coupon;
  }
}
