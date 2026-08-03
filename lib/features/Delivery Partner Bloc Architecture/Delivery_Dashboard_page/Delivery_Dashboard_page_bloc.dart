import 'dart:async';
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
      final dataState = await repository.loadDashboardData();
      final session = _sessionRepo?.currentState;
      emit(dataState.copyWith(
        isOnline: dataState.isOnline,
        walletBalance: session?.walletBalance ?? dataState.walletBalance,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryDashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleOnline(
    DeliveryDashboardToggleOnlineEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    final newOnlineState = event.isOnline;
    emit(state.copyWith(isOnline: newOnlineState));
    _sessionRepo?.setOnlineStatus(newOnlineState);
    try {
      await repository.saveOnlineStatus(newOnlineState);
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update online status. Please try again.',
        ),
      );
    }
  }

  Future<void> _onRefresh(
    DeliveryDashboardRefreshEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryDashboardStatus.loading));
    try {
      final dataState = await repository.loadDashboardData();
      emit(dataState);
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryDashboardStatus.error,
          errorMessage: e.toString(),
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
