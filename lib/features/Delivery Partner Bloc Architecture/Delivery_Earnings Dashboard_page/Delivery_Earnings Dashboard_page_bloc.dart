import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Earnings Dashboard_page_event.dart';
import 'Delivery_Earnings Dashboard_page_repository.dart';
import 'Delivery_Earnings Dashboard_page_service.dart';
import 'Delivery_Earnings Dashboard_page_state.dart';

class DeliveryEarningsDashboardPageBloc
    extends Bloc<DeliveryEarningsDashboardPageEvent,
        DeliveryEarningsDashboardState> {
  final DeliveryEarningsDashboardRepositoryBase repository;
  final DeliveryEarningsDashboardServiceBase service;

  DeliveryEarningsDashboardPageBloc({
    DeliveryEarningsDashboardRepositoryBase? repository,
    DeliveryEarningsDashboardServiceBase? service,
  }) : repository = repository ?? DeliveryEarningsDashboardRepository(),
       service = service ?? DeliveryEarningsDashboardService(),
       super(const DeliveryEarningsDashboardState()) {
    on<DeliveryEarningsInitEvent>(_onInit);
    on<DeliveryEarningsRefreshEvent>(_onRefresh);
    on<DeliveryEarningsRangeChangedEvent>(_onRangeChanged);
    on<DeliveryEarningsTabChangedEvent>(_onTabChanged);
    on<DeliveryEarningsWithdrawEvent>(_onWithdraw);
    on<DeliveryEarningsMediaUploadStartedEvent>(_onMediaUploadStarted);
    on<DeliveryEarningsMediaUploadProgressEvent>(_onMediaUploadProgress);
    on<DeliveryEarningsMediaUploadCompletedEvent>(_onMediaUploadCompleted);
  }

  Future<void> _onInit(
    DeliveryEarningsInitEvent event,
    Emitter<DeliveryEarningsDashboardState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryEarningsStatus.loading));
    try {
      final dataState = await repository.loadEarningsData();
      emit(dataState);
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryEarningsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefresh(
    DeliveryEarningsRefreshEvent event,
    Emitter<DeliveryEarningsDashboardState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryEarningsStatus.refreshing));
    try {
      final dataState = await repository.loadEarningsData();
      emit(dataState);
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryEarningsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onRangeChanged(
    DeliveryEarningsRangeChangedEvent event,
    Emitter<DeliveryEarningsDashboardState> emit,
  ) {
    emit(state.copyWith(selectedRange: event.range));
  }

  void _onTabChanged(
    DeliveryEarningsTabChangedEvent event,
    Emitter<DeliveryEarningsDashboardState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.tab));
  }

  Future<void> _onWithdraw(
    DeliveryEarningsWithdrawEvent event,
    Emitter<DeliveryEarningsDashboardState> emit,
  ) async {
    if (event.amount <= 0) {
      emit(
        state.copyWith(
          errorMessage: 'Please enter a valid withdrawal amount.',
        ),
      );
      return;
    }
    if (event.amount > state.walletBalance) {
      emit(
        state.copyWith(
          errorMessage:
              'Withdrawal amount exceeds your available wallet balance.',
        ),
      );
      return;
    }

    emit(state.copyWith(isWithdrawing: true));
    try {
      final updatedState = await repository.withdraw(event.amount);
      emit(
        updatedState.copyWith(
          isWithdrawing: false,
          selectedRange: state.selectedRange,
          selectedTab: state.selectedTab,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isWithdrawing: false,
          errorMessage: 'Withdrawal failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onMediaUploadStarted(
    DeliveryEarningsMediaUploadStartedEvent event,
    Emitter<DeliveryEarningsDashboardState> emit,
  ) async {
    if (state.isMediaUploading) return;
    emit(state.copyWith(isMediaUploading: true, mediaUploadProgress: 0.0));
    try {
      await for (final progress in repository.mediaUploadStream()) {
        emit(
          state.copyWith(
            mediaUploadProgress: progress,
            isMediaUploading: progress < 1.0,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(isMediaUploading: false, mediaUploadProgress: 1.0));
    }
  }

  void _onMediaUploadProgress(
    DeliveryEarningsMediaUploadProgressEvent event,
    Emitter<DeliveryEarningsDashboardState> emit,
  ) {
    emit(
      state.copyWith(
        mediaUploadProgress: event.progress,
        isMediaUploading: event.progress < 1.0,
      ),
    );
  }

  void _onMediaUploadCompleted(
    DeliveryEarningsMediaUploadCompletedEvent event,
    Emitter<DeliveryEarningsDashboardState> emit,
  ) {
    emit(state.copyWith(isMediaUploading: false, mediaUploadProgress: 1.0));
  }
}
