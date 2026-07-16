import 'package:cloud_firestore/cloud_firestore.dart';
import 'promotions_coupons_page_model.dart';

class PromotionsCouponsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CouponModel>> fetchCoupons(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('promotions')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CouponModel(
          id: doc.id,
          code: data['code'] ?? '',
          description: data['description'] ?? '',
          discountAmount: (data['discountAmount'] ?? 0).toDouble(),
          isPercentage: data['isPercentage'] ?? false,
          expiryDate: (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch coupons: $e');
    }
  }

  Future<CouponModel> addCoupon(String sellerId, CouponModel coupon) async {
    try {
      final docRef = _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('promotions')
          .doc();
          
      await docRef.set({
        'code': coupon.code,
        'description': coupon.description,
        'discountAmount': coupon.discountAmount,
        'isPercentage': coupon.isPercentage,
        'expiryDate': Timestamp.fromDate(coupon.expiryDate),
        'isActive': coupon.isActive,
      });
      
      return coupon.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to add coupon: $e');
    }
  }

  Future<CouponModel> updateCoupon(String sellerId, CouponModel coupon) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('promotions')
          .doc(coupon.id)
          .update({
        'code': coupon.code,
        'description': coupon.description,
        'discountAmount': coupon.discountAmount,
        'isPercentage': coupon.isPercentage,
        'expiryDate': Timestamp.fromDate(coupon.expiryDate),
        'isActive': coupon.isActive,
      });
      return coupon;
    } catch (e) {
      throw Exception('Failed to update coupon: $e');
    }
  }

  Future<void> deleteCoupon(String sellerId, String couponId) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('promotions')
          .doc(couponId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete coupon: $e');
    }
  }

  Future<void> toggleCouponStatus(String sellerId, String couponId, bool isActive) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('promotions')
          .doc(couponId)
          .update({'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to toggle coupon status: $e');
    }
  }
}

