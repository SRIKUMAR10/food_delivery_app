import '../models/coupon_model.dart';

abstract interface class ICouponRepository {
  Stream<List<CouponModel>> getActiveCouponsBySellers(List<String> sellerIds);
  Future<CouponModel?> validateAndApplyCoupon(String couponCode, String sellerId, double orderTotal);
}
