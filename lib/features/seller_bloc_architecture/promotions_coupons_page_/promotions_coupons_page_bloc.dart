// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'promotions_coupons_page_event.dart';
import 'promotions_coupons_page_state.dart';
import 'promotions_coupons_page_repository.dart';
import 'promotions_coupons_page_model.dart';

class PromotionsCouponsBloc extends Bloc<PromotionsCouponsEvent, PromotionsCouponsState> {
  final PromotionsCouponsRepository repository;
  String? _sellerId;
  StreamSubscription? _couponsSub;

  PromotionsCouponsBloc({required this.repository}) : super(const PromotionsCouponsInitial()) {
    on<LoadCouponsEvent>(_onLoadCoupons);
    on<CouponsUpdatedEvent>(_onCouponsUpdated);
    on<LoadSellerMetadataEvent>(_onLoadSellerMetadata);
    on<AddCouponEvent>(_onAddCoupon);
    on<UpdateCouponEvent>(_onUpdateCoupon);
    on<DeleteCouponEvent>(_onDeleteCoupon);
    on<ToggleCouponStatusEvent>(_onToggleCouponStatus);
    on<FilterCouponsEvent>(_onFilterCoupons);
    on<ValidateCouponServerSideEvent>(_onValidateCouponServerSide);
    on<ClearCouponValidationEvent>(_onClearCouponValidation);
    on<ClearMessagesEvent>(_onClearMessages);
  }

  @override
  Future<void> close() {
    _couponsSub?.cancel();
    return super.close();
  }

  List<CouponModel> _applyFilters(
    List<CouponModel> allCoupons,
    String query,
    String status,
    String scope,
    String type,
  ) {
    return allCoupons.where((c) {
      // Query
      if (query.isNotEmpty) {
        final q = query.toLowerCase().trim();
        final matchesCode = c.code.toLowerCase().contains(q);
        final matchesDesc = c.description.toLowerCase().contains(q);
        if (!matchesCode && !matchesDesc) return false;
      }

      // Status
      if (status == 'Active' && (!c.isActive || c.isExpired)) return false;
      if (status == 'Inactive' && c.isActive) return false;
      if (status == 'Expired' && !c.isExpired) return false;

      // Scope
      if (scope != 'All' && c.offerScope.toLowerCase() != scope.toLowerCase()) return false;

      // Type
      if (type == 'Percentage' && !c.isPercentage) return false;
      if (type == 'Fixed' && c.isPercentage) return false;

      return true;
    }).toList();
  }

  Future<void> _onLoadCoupons(LoadCouponsEvent event, Emitter<PromotionsCouponsState> emit) async {
    _sellerId = event.sellerId;
    emit(const PromotionsCouponsLoading());
    try {
      await _couponsSub?.cancel();

      // Fetch initial data & metadata in parallel
      final results = await Future.wait([
        repository.getCoupons(event.sellerId),
        repository.getSellerProducts(event.sellerId),
        repository.getSellerCategories(event.sellerId),
      ]);

      final coupons = results[0] as List<CouponModel>;
      final products = results[1] as List<Map<String, dynamic>>;
      final categories = results[2] as List<String>;

      final filtered = _applyFilters(coupons, '', 'All', 'All', 'All');

      emit(PromotionsCouponsLoaded(
        coupons: coupons,
        filteredCoupons: filtered,
        sellerProducts: products,
        sellerCategories: categories,
      ));

      _couponsSub = repository.streamCoupons(event.sellerId).listen((liveCoupons) {
        if (!isClosed) {
          add(CouponsUpdatedEvent(liveCoupons));
        }
      });
    } catch (e) {
      emit(PromotionsCouponsError('Failed to load coupons: $e'));
    }
  }

  void _onCouponsUpdated(CouponsUpdatedEvent event, Emitter<PromotionsCouponsState> emit) {
    final currentState = state;
    if (currentState is PromotionsCouponsLoaded) {
      final filtered = _applyFilters(
        event.coupons,
        currentState.searchQuery,
        currentState.statusFilter,
        currentState.scopeFilter,
        currentState.typeFilter,
      );
      emit(currentState.copyWith(
        coupons: event.coupons,
        filteredCoupons: filtered,
      ));
    } else {
      emit(PromotionsCouponsLoaded(
        coupons: event.coupons,
        filteredCoupons: event.coupons,
      ));
    }
  }

  Future<void> _onLoadSellerMetadata(
    LoadSellerMetadataEvent event,
    Emitter<PromotionsCouponsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;

    try {
      final results = await Future.wait([
        repository.getSellerProducts(event.sellerId),
        repository.getSellerCategories(event.sellerId),
      ]);

      emit(currentState.copyWith(
        sellerProducts: results[0] as List<Map<String, dynamic>>,
        sellerCategories: results[1] as List<String>,
      ));
    } catch (_) {}
  }

  Future<void> _onAddCoupon(AddCouponEvent event, Emitter<PromotionsCouponsState> emit) async {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;

    emit(currentState.copyWith(isSaving: true, clearMessages: true));

    try {
      final sId = _sellerId ?? event.coupon.sellerId;
      if (sId.isEmpty) throw Exception('Seller ID not initialized.');

      final newCoupon = await repository.addCoupon(sId, event.coupon);
      final updatedCoupons = List.of(currentState.coupons)..insert(0, newCoupon);
      final filtered = _applyFilters(
        updatedCoupons,
        currentState.searchQuery,
        currentState.statusFilter,
        currentState.scopeFilter,
        currentState.typeFilter,
      );

      emit(currentState.copyWith(
        coupons: updatedCoupons,
        filteredCoupons: filtered,
        isSaving: false,
        successMessage: 'Coupon "${newCoupon.code}" created successfully.',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSaving: false,
        errorMessage: 'Failed to create coupon: $e',
      ));
    }
  }

  Future<void> _onUpdateCoupon(UpdateCouponEvent event, Emitter<PromotionsCouponsState> emit) async {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;

    final newProcessingIds = Set<String>.from(currentState.processingCouponIds)..add(event.coupon.id);
    emit(currentState.copyWith(
      processingCouponIds: newProcessingIds,
      isSaving: true,
      clearMessages: true,
    ));

    try {
      final sId = _sellerId ?? event.coupon.sellerId;
      if (sId.isEmpty) throw Exception('Seller ID not initialized.');

      final updatedCoupon = await repository.updateCoupon(sId, event.coupon);
      final updatedCoupons = currentState.coupons.map((c) {
        return c.id == updatedCoupon.id ? updatedCoupon : c;
      }).toList();

      final filtered = _applyFilters(
        updatedCoupons,
        currentState.searchQuery,
        currentState.statusFilter,
        currentState.scopeFilter,
        currentState.typeFilter,
      );

      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.coupon.id);
      emit(currentState.copyWith(
        coupons: updatedCoupons,
        filteredCoupons: filtered,
        processingCouponIds: nextProcessingIds,
        isSaving: false,
        successMessage: 'Coupon "${updatedCoupon.code}" updated successfully.',
      ));
    } catch (e) {
      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.coupon.id);
      emit(currentState.copyWith(
        processingCouponIds: nextProcessingIds,
        isSaving: false,
        errorMessage: 'Failed to update coupon: $e',
      ));
    }
  }

  Future<void> _onDeleteCoupon(DeleteCouponEvent event, Emitter<PromotionsCouponsState> emit) async {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;

    final newProcessingIds = Set<String>.from(currentState.processingCouponIds)..add(event.couponId);
    emit(currentState.copyWith(processingCouponIds: newProcessingIds, clearMessages: true));

    try {
      if (_sellerId == null) throw Exception('Seller ID not initialized.');
      await repository.deleteCoupon(_sellerId!, event.couponId);
      final updatedCoupons = currentState.coupons.where((c) => c.id != event.couponId).toList();
      final filtered = _applyFilters(
        updatedCoupons,
        currentState.searchQuery,
        currentState.statusFilter,
        currentState.scopeFilter,
        currentState.typeFilter,
      );

      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.couponId);
      emit(currentState.copyWith(
        coupons: updatedCoupons,
        filteredCoupons: filtered,
        processingCouponIds: nextProcessingIds,
        successMessage: 'Coupon deleted successfully.',
      ));
    } catch (e) {
      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.couponId);
      emit(currentState.copyWith(
        processingCouponIds: nextProcessingIds,
        errorMessage: 'Failed to delete coupon: $e',
      ));
    }
  }

  Future<void> _onToggleCouponStatus(
    ToggleCouponStatusEvent event,
    Emitter<PromotionsCouponsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;

    final newProcessingIds = Set<String>.from(currentState.processingCouponIds)..add(event.couponId);
    emit(currentState.copyWith(processingCouponIds: newProcessingIds, clearMessages: true));

    try {
      if (_sellerId == null) throw Exception('Seller ID not initialized.');
      await repository.toggleCouponStatus(_sellerId!, event.couponId, event.isActive);

      final updatedCoupons = currentState.coupons.map((c) {
        if (c.id == event.couponId) {
          return c.copyWith(isActive: event.isActive);
        }
        return c;
      }).toList();

      final filtered = _applyFilters(
        updatedCoupons,
        currentState.searchQuery,
        currentState.statusFilter,
        currentState.scopeFilter,
        currentState.typeFilter,
      );

      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.couponId);
      emit(currentState.copyWith(
        coupons: updatedCoupons,
        filteredCoupons: filtered,
        processingCouponIds: nextProcessingIds,
        successMessage: 'Coupon status changed to ${event.isActive ? 'Active' : 'Inactive'}.',
      ));
    } catch (e) {
      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.couponId);
      emit(currentState.copyWith(
        processingCouponIds: nextProcessingIds,
        errorMessage: 'Failed to update status: $e',
      ));
    }
  }

  void _onFilterCoupons(FilterCouponsEvent event, Emitter<PromotionsCouponsState> emit) {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;

    final filtered = _applyFilters(
      currentState.coupons,
      event.searchQuery,
      event.statusFilter,
      event.scopeFilter,
      event.typeFilter,
    );

    emit(currentState.copyWith(
      searchQuery: event.searchQuery,
      statusFilter: event.statusFilter,
      scopeFilter: event.scopeFilter,
      typeFilter: event.typeFilter,
      filteredCoupons: filtered,
    ));
  }

  Future<void> _onValidateCouponServerSide(
    ValidateCouponServerSideEvent event,
    Emitter<PromotionsCouponsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;

    emit(currentState.copyWith(isValidating: true, clearValidationResult: true));

    try {
      final sId = _sellerId ?? '';
      final result = await repository.validateCouponServerSide(
        sellerId: sId,
        couponCode: event.couponCode,
        orderTotal: event.orderTotal,
        items: event.items,
        customerId: event.customerId,
      );

      emit(currentState.copyWith(
        isValidating: false,
        validationResult: result,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isValidating: false,
        validationResult: CouponValidationResult.invalid(
          reason: 'Validation Exception',
          message: 'Error during validation: $e',
        ),
      ));
    }
  }

  void _onClearCouponValidation(
    ClearCouponValidationEvent event,
    Emitter<PromotionsCouponsState> emit,
  ) {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;
    emit(currentState.copyWith(clearValidationResult: true));
  }

  void _onClearMessages(
    ClearMessagesEvent event,
    Emitter<PromotionsCouponsState> emit,
  ) {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;
    emit(currentState.copyWith(clearMessages: true));
  }
}

