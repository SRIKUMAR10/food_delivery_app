import 'promotions_coupons_page_model.dart';

abstract class PromotionsCouponsEvent {}

class LoadCouponsEvent extends PromotionsCouponsEvent {
  final String sellerId;
  LoadCouponsEvent(this.sellerId);
}

class AddCouponEvent extends PromotionsCouponsEvent {
  final CouponModel coupon;
  AddCouponEvent(this.coupon);
}

class UpdateCouponEvent extends PromotionsCouponsEvent {
  final CouponModel coupon;
  UpdateCouponEvent(this.coupon);
}

class DeleteCouponEvent extends PromotionsCouponsEvent {
  final String couponId;
  DeleteCouponEvent(this.couponId);
}

class ToggleCouponStatusEvent extends PromotionsCouponsEvent {
  final String couponId;
  final bool isActive;
  ToggleCouponStatusEvent(this.couponId, this.isActive);
}
