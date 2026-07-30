import 'package:equatable/equatable.dart';
import 'promotions_coupons_page_model.dart';

abstract class PromotionsCouponsEvent extends Equatable {
  const PromotionsCouponsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCouponsEvent extends PromotionsCouponsEvent {
  final String sellerId;
  const LoadCouponsEvent(this.sellerId);

  @override
  List<Object?> get props => [sellerId];
}

class AddCouponEvent extends PromotionsCouponsEvent {
  final CouponModel coupon;
  const AddCouponEvent(this.coupon);

  @override
  List<Object?> get props => [coupon];
}

class UpdateCouponEvent extends PromotionsCouponsEvent {
  final CouponModel coupon;
  const UpdateCouponEvent(this.coupon);

  @override
  List<Object?> get props => [coupon];
}

class DeleteCouponEvent extends PromotionsCouponsEvent {
  final String couponId;
  const DeleteCouponEvent(this.couponId);

  @override
  List<Object?> get props => [couponId];
}

class ToggleCouponStatusEvent extends PromotionsCouponsEvent {
  final String couponId;
  final bool isActive;
  const ToggleCouponStatusEvent(this.couponId, this.isActive);

  @override
  List<Object?> get props => [couponId, isActive];
}
