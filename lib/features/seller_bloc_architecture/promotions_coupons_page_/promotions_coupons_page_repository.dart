import 'promotions_coupons_page_model.dart';
import 'promotions_coupons_page_service.dart';

class PromotionsCouponsRepository {
  final PromotionsCouponsService service;

  PromotionsCouponsRepository({required this.service});

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
}
