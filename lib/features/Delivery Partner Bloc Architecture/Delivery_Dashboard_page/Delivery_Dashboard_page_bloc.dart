import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Dashboard_page_event.dart';
import 'Delivery_Dashboard_page_repository.dart';
import 'Delivery_Dashboard_page_service.dart';
import 'Delivery_Dashboard_page_state.dart';

class DeliveryDashboardPageBloc
    extends Bloc<DeliveryDashboardPageEvent, DeliveryDashboardState> {
  final DeliveryDashboardRepositoryBase repository;
  final DeliveryDashboardServiceBase service;

  DeliveryDashboardPageBloc({
    DeliveryDashboardRepositoryBase? repository,
    DeliveryDashboardServiceBase? service,
  })  : repository = repository ?? DeliveryDashboardRepository(),
        service = service ?? DeliveryDashboardService(),
        super(const DeliveryDashboardState()) {
    on<DeliveryDashboardInitEvent>(_onInit);
    on<DeliveryDashboardToggleOnlineEvent>(_onToggleOnline);
    on<DeliveryDashboardRefreshEvent>(_onRefresh);
    on<DeliveryDashboardFilterActivityEvent>(_onFilterActivity);
    on<DeliveryDashboardQuickActionExecutedEvent>(_onQuickAction);
  }

  Future<void> _onInit(
    DeliveryDashboardInitEvent event,
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

  Future<void> _onToggleOnline(
    DeliveryDashboardToggleOnlineEvent event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    final newOnlineState = event.isOnline;
    emit(state.copyWith(isOnline: newOnlineState));
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
}
