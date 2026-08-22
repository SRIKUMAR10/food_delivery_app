import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Dashboard_page_event.dart';
import 'Delivery_Dashboard_page_repository.dart';
import 'Delivery_Dashboard_page_service.dart';
import 'Delivery_Dashboard_page_state.dart';
import '../../../core/repositories/delivery_active_order_session_repository.dart';

class DeliveryDashboardPageBloc
    extends Bloc<DeliveryDashboardPageEvent, DeliveryDashboardState> {
  final DeliveryDashboardRepositoryBase repository;
  final DeliveryDashboardServiceBase service;
  final DeliveryActiveOrderSessionRepository? _sessionRepo;
  StreamSubscription<DeliverySessionState>? _sessionSub;

  DeliveryDashboardPageBloc({
    DeliveryDashboardRepositoryBase? repository,
    DeliveryDashboardServiceBase? service,
    DeliveryActiveOrderSessionRepository? sessionRepo,
  })  : repository = repository ?? DeliveryDashboardRepository(),
        service = service ?? DeliveryDashboardService(),
        _sessionRepo = sessionRepo,
        super(const DeliveryDashboardState()) {
    on<DeliveryDashboardInitEvent>(_onInit);
    on<DeliveryDashboardToggleOnlineEvent>(_onToggleOnline);
    on<DeliveryDashboardChangeStatusEvent>(_onChangeStatus);
    on<DeliveryDashboardSetAvailableEvent>(_onSetAvailable);
    on<DeliveryDashboardSetBusyEvent>(_onSetBusy);
    on<DeliveryDashboardAutoOfflineEvent>(_onAutoOffline);
    on<DeliveryDashboardRefreshEvent>(_onRefresh);
    on<DeliveryDashboardFilterActivityEvent>(_onFilterActivity);
    on<DeliveryDashboardQuickActionExecutedEvent>(_onQuickAction);
    on<_DeliveryDashboardSessionUpdatedEvent>(_onSessionUpdated);

    _sessionSub = _sessionRepo?.sessionStream.listen((session) {
      if (!isClosed) add(_DeliveryDashboardSessionUpdatedEvent(session));
    });
  }

  Future<void> _onInit(
    DeliveryDashboardInitEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryDashboardStatus.loading));
    try {
      await emit.forEach<DeliveryDashboardState>(
        repository.watchDashboard(),
        onData: (dataState) {
          final s = _sessionRepo?.currentState;
          return dataState.copyWith(
            status: DeliveryDashboardStatus.loaded,
            isOnline: dataState.isOnline,
            isAvailable: dataState.isAvailable,
            isBusy: dataState.isBusy,
            partnerStatus: dataState.partnerStatus,
            currentOrderId: dataState.currentOrderId,
            lastActiveAt: dataState.lastActiveAt,
            walletBalance: s?.walletBalance ?? dataState.walletBalance,
            errorMessage: null,
            clearError: true,
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(
            status: DeliveryDashboardStatus.loaded,
            errorMessage: null,
            clearError: true,
          );
        },
      );
    } catch (e) {
      final fallbackData = await repository.loadDashboardData().catchError(
            (_) => const DeliveryDashboardState(),
          );
      emit(
        fallbackData.copyWith(
          status: DeliveryDashboardStatus.loaded,
          errorMessage: null,
          clearError: true,
        ),
      );
    }
  }

  Future<void> _onToggleOnline(
    DeliveryDashboardToggleOnlineEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    final newOnlineState = event.isOnline;
    final newPartnerStatus = newOnlineState
        ? DeliveryPartnerStatusType.available
        : DeliveryPartnerStatusType.offline;

    emit(state.copyWith(
      isOnline: newOnlineState,
      isAvailable: newOnlineState,
      isBusy: false,
      partnerStatus: newPartnerStatus,
    ));
    _sessionRepo?.setOnlineStatus(newOnlineState);
    try {
      await repository.updatePartnerStatus(
        isOnline: newOnlineState,
        isAvailable: newOnlineState,
        isBusy: false,
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update online status. Please try again.',
        ),
      );
    }
  }

  Future<void> _onChangeStatus(
    DeliveryDashboardChangeStatusEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    final targetStatus = event.status;
    final bool isOnline = targetStatus != DeliveryPartnerStatusType.offline;
    final bool isAvailable = targetStatus == DeliveryPartnerStatusType.available;
    final bool isBusy = targetStatus == DeliveryPartnerStatusType.busy;

    emit(state.copyWith(
      isOnline: isOnline,
      isAvailable: isAvailable,
      isBusy: isBusy,
      partnerStatus: targetStatus,
    ));
    _sessionRepo?.setOnlineStatus(isOnline);
    try {
      await repository.updatePartnerStatus(
        isOnline: isOnline,
        isAvailable: isAvailable,
        isBusy: isBusy,
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update status. Please try again.',
        ),
      );
    }
  }

  Future<void> _onSetAvailable(
    DeliveryDashboardSetAvailableEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    final available = event.isAvailable;
    final newStatus = state.isOnline
        ? (available ? DeliveryPartnerStatusType.available : DeliveryPartnerStatusType.busy)
        : DeliveryPartnerStatusType.offline;

    emit(state.copyWith(
      isAvailable: available,
      isBusy: !available,
      partnerStatus: newStatus,
    ));

    try {
      await repository.updatePartnerStatus(
        isOnline: state.isOnline,
        isAvailable: available,
        isBusy: !available,
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update availability status.',
        ),
      );
    }
  }

  Future<void> _onSetBusy(
    DeliveryDashboardSetBusyEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    final busy = event.isBusy;
    final newStatus = busy ? DeliveryPartnerStatusType.busy : DeliveryPartnerStatusType.available;

    emit(state.copyWith(
      isBusy: busy,
      isAvailable: !busy,
      partnerStatus: newStatus,
      currentOrderId: event.currentOrderId,
    ));

    try {
      await repository.updatePartnerStatus(
        isOnline: state.isOnline,
        isAvailable: !busy,
        isBusy: busy,
        currentOrderId: event.currentOrderId,
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update busy status.',
        ),
      );
    }
  }

  Future<void> _onAutoOffline(
    DeliveryDashboardAutoOfflineEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    emit(state.copyWith(
      isOnline: false,
      isAvailable: false,
      isBusy: false,
      partnerStatus: DeliveryPartnerStatusType.offline,
    ));
    _sessionRepo?.setOnlineStatus(false);
    try {
      await repository.updatePartnerStatus(
        isOnline: false,
        isAvailable: false,
        isBusy: false,
      );
    } catch (_) {}
  }

  Future<void> _onRefresh(
    DeliveryDashboardRefreshEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryDashboardStatus.loading));
    try {
      final dataState = await repository.loadDashboardData();
      emit(dataState.copyWith(
        status: DeliveryDashboardStatus.loaded,
        errorMessage: null,
        clearError: true,
      ));
    } catch (e) {
      debugPrint('DeliveryDashboardRefreshEvent error: $e');
      emit(
        state.copyWith(
          status: DeliveryDashboardStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onFilterActivity(
    DeliveryDashboardFilterActivityEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) {
    emit(state.copyWith(selectedFilter: event.filter));
  }

  void _onQuickAction(
    DeliveryDashboardQuickActionExecutedEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) {
    // Action trigger handler
  }

  void _onSessionUpdated(
    _DeliveryDashboardSessionUpdatedEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) {
    final session = event.session;
    emit(state.copyWith(
      isOnline: session.isOnline,
      walletBalance: session.walletBalance,
    ));
  }

  @override
  Future<void> close() {
    _sessionSub?.cancel();
    return super.close();
  }
}

class _DeliveryDashboardSessionUpdatedEvent extends DeliveryDashboardPageEvent {
  final DeliverySessionState session;

  const _DeliveryDashboardSessionUpdatedEvent(this.session);

  @override
  List<Object?> get props => [session];
}

/// Standardized Feature-Architecture Alias for DeliveryDashboardBloc
typedef DeliveryDashboardBloc = DeliveryDashboardPageBloc;


