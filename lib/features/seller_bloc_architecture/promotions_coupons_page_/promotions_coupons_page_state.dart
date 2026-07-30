import 'package:equatable/equatable.dart';
import 'promotions_coupons_page_model.dart';

abstract class PromotionsCouponsState extends Equatable {
  const PromotionsCouponsState();

  @override
  List<Object?> get props => [];
}

class PromotionsCouponsInitial extends PromotionsCouponsState {
  const PromotionsCouponsInitial();
}

class PromotionsCouponsLoading extends PromotionsCouponsState {
  const PromotionsCouponsLoading();
}

class PromotionsCouponsLoaded extends PromotionsCouponsState {
  final List<CouponModel> coupons;
  final String? successMessage;
  final String? errorMessage;
  final Set<String> processingCouponIds;

  const PromotionsCouponsLoaded({
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

  @override
  List<Object?> get props => [coupons, successMessage, errorMessage, processingCouponIds];
}

class PromotionsCouponsError extends PromotionsCouponsState {
  final String message;
  const PromotionsCouponsError(this.message);

  @override
  List<Object?> get props => [message];
}
