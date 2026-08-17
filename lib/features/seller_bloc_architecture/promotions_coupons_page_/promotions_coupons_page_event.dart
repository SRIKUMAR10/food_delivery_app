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

class CouponsUpdatedEvent extends PromotionsCouponsEvent {
  final List<CouponModel> coupons;
  const CouponsUpdatedEvent(this.coupons);

  @override
  List<Object?> get props => [coupons];
}

class LoadSellerMetadataEvent extends PromotionsCouponsEvent {
  final String sellerId;
  const LoadSellerMetadataEvent(this.sellerId);

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

class FilterCouponsEvent extends PromotionsCouponsEvent {
  final String searchQuery;
  final String statusFilter; // 'All', 'Active', 'Inactive', 'Expired'
  final String scopeFilter; // 'All', 'restaurant', 'product', 'category'
  final String typeFilter; // 'All', 'Percentage', 'Fixed'

  const FilterCouponsEvent({
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.scopeFilter = 'All',
    this.typeFilter = 'All',
  });

  @override
  List<Object?> get props => [searchQuery, statusFilter, scopeFilter, typeFilter];
}

class ValidateCouponServerSideEvent extends PromotionsCouponsEvent {
  final String couponCode;
  final double orderTotal;
  final List<Map<String, dynamic>>? items;
  final String? customerId;

  const ValidateCouponServerSideEvent({
    required this.couponCode,
    required this.orderTotal,
    this.items,
    this.customerId,
  });

  @override
  List<Object?> get props => [couponCode, orderTotal, items, customerId];
}

class ClearCouponValidationEvent extends PromotionsCouponsEvent {
  const ClearCouponValidationEvent();
}

class ClearMessagesEvent extends PromotionsCouponsEvent {
  const ClearMessagesEvent();
}

