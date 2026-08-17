// Real-Time Firestore Stream Provider Standardized
import 'promotions_coupons_page_model.dart';
import 'promotions_coupons_page_service.dart';

class PromotionsCouponsRepository {
  final PromotionsCouponsService service;

  PromotionsCouponsRepository({required this.service});

  Stream<List<CouponModel>> streamCoupons(String sellerId) {
    return service.streamCoupons(sellerId);
  }

  Future<List<CouponModel>> getCoupons(String sellerId) {
    return service.fetchCoupons(sellerId);
  }

  Future<CouponModel> addCoupon(String sellerId, CouponModel coupon) {
    return service.addCoupon(sellerId, coupon);
  }

  Future<CouponModel> updateCoupon(String sellerId, CouponModel coupon) {
    return service.updateCoupon(sellerId, coupon);
  }

  Future<void> deleteCoupon(String sellerId, String couponId) {
    return service.deleteCoupon(sellerId, couponId);
  }

  Future<void> toggleCouponStatus(String sellerId, String couponId, bool isActive) {
    return service.toggleCouponStatus(sellerId, couponId, isActive);
  }

  Future<List<Map<String, dynamic>>> getSellerProducts(String sellerId) {
    return service.fetchSellerProducts(sellerId);
  }

  Future<List<String>> getSellerCategories(String sellerId) {
    return service.fetchSellerCategories(sellerId);
  }

  Future<CouponValidationResult> validateCouponServerSide({
    required String sellerId,
    required String couponCode,
    required double orderTotal,
    List<Map<String, dynamic>>? items,
    String? customerId,
  }) {
    return service.validateCouponServerSide(
      sellerId: sellerId,
      couponCode: couponCode,
      orderTotal: orderTotal,
      items: items,
      customerId: customerId,
    );
  }
}

