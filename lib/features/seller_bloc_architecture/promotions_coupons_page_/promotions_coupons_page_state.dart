import 'promotions_coupons_page_model.dart';

abstract class PromotionsCouponsState {}

class PromotionsCouponsInitial extends PromotionsCouponsState {}

class PromotionsCouponsLoading extends PromotionsCouponsState {}

class PromotionsCouponsLoaded extends PromotionsCouponsState {
  final List<CouponModel> coupons;
  final String? successMessage;
  final String? errorMessage;
  final Set<String> processingCouponIds;

  PromotionsCouponsLoaded({
    required this.coupons,
    this.successMessage,
    this.errorMessage,
    this.processingCouponIds = const {},
  });

  PromotionsCouponsLoaded copyWith({
    List<CouponModel>? coupons,
    String? successMessage,
    String? errorMessage,
    Set<String>? processingCouponIds,
    bool clearMessages = false,
  }) {
    return PromotionsCouponsLoaded(
      coupons: coupons ?? this.coupons,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      processingCouponIds: processingCouponIds ?? this.processingCouponIds,
    );
  }
}

class PromotionsCouponsError extends PromotionsCouponsState {
  final String message;
  PromotionsCouponsError(this.message);
}
