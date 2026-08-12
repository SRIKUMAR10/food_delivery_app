// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'promotions_coupons_page_event.dart';
import 'promotions_coupons_page_state.dart';
import 'promotions_coupons_page_repository.dart';
import 'promotions_coupons_page_model.dart';

class _CouponsUpdatedEvent extends PromotionsCouponsEvent {
  final List<CouponModel> coupons;
  const _CouponsUpdatedEvent(this.coupons);

  @override
  List<Object?> get props => [coupons];
}

class PromotionsCouponsBloc extends Bloc<PromotionsCouponsEvent, PromotionsCouponsState> {
  final PromotionsCouponsRepository repository;
  String? _sellerId;
  StreamSubscription? _couponsSub;

  PromotionsCouponsBloc({required this.repository}) : super(const PromotionsCouponsInitial()) {
    on<LoadCouponsEvent>(_onLoadCoupons);
    on<_CouponsUpdatedEvent>(_onCouponsUpdated);
    on<AddCouponEvent>(_onAddCoupon);
    on<UpdateCouponEvent>(_onUpdateCoupon);
    on<DeleteCouponEvent>(_onDeleteCoupon);
    on<ToggleCouponStatusEvent>(_onToggleCouponStatus);
  }

  @override
  Future<void> close() {
    _couponsSub?.cancel();
    return super.close();
  }

  Future<void> _onLoadCoupons(LoadCouponsEvent event, Emitter<PromotionsCouponsState> emit) async {
    _sellerId = event.sellerId;
    emit(const PromotionsCouponsLoading());
    try {
      await _couponsSub?.cancel();
      final coupons = await repository.getCoupons(event.sellerId);
      emit(PromotionsCouponsLoaded(coupons: coupons));

      _couponsSub = repository.streamCoupons(event.sellerId).listen((liveCoupons) {
        if (!isClosed) {
          add(_CouponsUpdatedEvent(liveCoupons));
        }
      });
    } catch (e) {
      emit(PromotionsCouponsError('Failed to load coupons: $e'));
    }
  }

  void _onCouponsUpdated(_CouponsUpdatedEvent event, Emitter<PromotionsCouponsState> emit) {
    final currentState = state;
    if (currentState is PromotionsCouponsLoaded) {
      emit(currentState.copyWith(coupons: event.coupons));
    } else {
      emit(PromotionsCouponsLoaded(coupons: event.coupons));
    }
  }

  Future<void> _onAddCoupon(AddCouponEvent event, Emitter<PromotionsCouponsState> emit) async {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;

    // Simulate adding process by locking (not strictly necessary for add, but good for UX)
    emit(currentState.copyWith(clearMessages: true));

    try {
      if (_sellerId == null) throw Exception('Seller ID not initialized.');
      final newCoupon = await repository.addCoupon(_sellerId!, event.coupon);
      final updatedCoupons = List.of(currentState.coupons)..add(newCoupon);
      emit(currentState.copyWith(
        coupons: updatedCoupons,
        successMessage: 'Coupon added successfully.',
      ));
    } catch (e) {
      emit(currentState.copyWith(errorMessage: 'Failed to add coupon: $e'));
    }
  }

  Future<void> _onUpdateCoupon(UpdateCouponEvent event, Emitter<PromotionsCouponsState> emit) async {
    final currentState = state;
    if (currentState is! PromotionsCouponsLoaded) return;

    final newProcessingIds = Set<String>.from(currentState.processingCouponIds)..add(event.coupon.id);
    emit(currentState.copyWith(processingCouponIds: newProcessingIds, clearMessages: true));

    try {
      if (_sellerId == null) throw Exception('Seller ID not initialized.');
      final updatedCoupon = await repository.updateCoupon(_sellerId!, event.coupon);
      final updatedCoupons = currentState.coupons.map((c) {
        return c.id == updatedCoupon.id ? updatedCoupon : c;
      }).toList();
      
      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.coupon.id);
      emit(currentState.copyWith(
        coupons: updatedCoupons,
        processingCouponIds: nextProcessingIds,
        successMessage: 'Coupon updated successfully.',
      ));
    } catch (e) {
      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.coupon.id);
      emit(currentState.copyWith(
        processingCouponIds: nextProcessingIds,
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
      
      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.couponId);
      emit(currentState.copyWith(
        coupons: updatedCoupons,
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

  Future<void> _onToggleCouponStatus(ToggleCouponStatusEvent event, Emitter<PromotionsCouponsState> emit) async {
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
      
      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.couponId);
      emit(currentState.copyWith(
        coupons: updatedCoupons,
        processingCouponIds: nextProcessingIds,
        successMessage: 'Coupon status updated.',
      ));
    } catch (e) {
      final nextProcessingIds = Set<String>.from(currentState.processingCouponIds)..remove(event.couponId);
      emit(currentState.copyWith(
        processingCouponIds: nextProcessingIds,
        errorMessage: 'Failed to update status: $e',
      ));
    }
  }
}
