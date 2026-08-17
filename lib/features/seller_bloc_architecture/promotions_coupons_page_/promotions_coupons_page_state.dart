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
  final List<CouponModel> filteredCoupons;
  final List<Map<String, dynamic>> sellerProducts;
  final List<String> sellerCategories;
  final String searchQuery;
  final String statusFilter;
  final String scopeFilter;
  final String typeFilter;
  final Set<String> processingCouponIds;
  final bool isSaving;
  final bool isValidating;
  final CouponValidationResult? validationResult;
  final String? successMessage;
  final String? errorMessage;

  const PromotionsCouponsLoaded({
    required this.coupons,
    List<CouponModel>? filteredCoupons,
    this.sellerProducts = const [],
    this.sellerCategories = const [],
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.scopeFilter = 'All',
    this.typeFilter = 'All',
    this.processingCouponIds = const {},
    this.isSaving = false,
    this.isValidating = false,
    this.validationResult,
    this.successMessage,
    this.errorMessage,
  }) : filteredCoupons = filteredCoupons ?? coupons;

  // Real-time metric computations
  int get activeCouponsCount =>
      coupons.where((c) => c.isActive && !c.isExpired).length;

  int get expiredCouponsCount =>
      coupons.where((c) => c.isExpired).length;

  int get totalRedemptions =>
      coupons.fold(0, (sum, c) => sum + c.usedCount);

  PromotionsCouponsLoaded copyWith({
    List<CouponModel>? coupons,
    List<CouponModel>? filteredCoupons,
    List<Map<String, dynamic>>? sellerProducts,
    List<String>? sellerCategories,
    String? searchQuery,
    String? statusFilter,
    String? scopeFilter,
    String? typeFilter,
    Set<String>? processingCouponIds,
    bool? isSaving,
    bool? isValidating,
    CouponValidationResult? validationResult,
    bool clearValidationResult = false,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return PromotionsCouponsLoaded(
      coupons: coupons ?? this.coupons,
      filteredCoupons: filteredCoupons ?? this.filteredCoupons,
      sellerProducts: sellerProducts ?? this.sellerProducts,
      sellerCategories: sellerCategories ?? this.sellerCategories,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      scopeFilter: scopeFilter ?? this.scopeFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      processingCouponIds: processingCouponIds ?? this.processingCouponIds,
      isSaving: isSaving ?? this.isSaving,
      isValidating: isValidating ?? this.isValidating,
      validationResult: clearValidationResult ? null : (validationResult ?? this.validationResult),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        coupons,
        filteredCoupons,
        sellerProducts,
        sellerCategories,
        searchQuery,
        statusFilter,
        scopeFilter,
        typeFilter,
        processingCouponIds,
        isSaving,
        isValidating,
        validationResult,
        successMessage,
        errorMessage,
      ];
}

class PromotionsCouponsError extends PromotionsCouponsState {
  final String message;
  const PromotionsCouponsError(this.message);

  @override
  List<Object?> get props => [message];
}

