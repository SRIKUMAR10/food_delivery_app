import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Orders_page_event.dart';
import 'Delivery_Orders_page_repository.dart';
import 'Delivery_Orders_page_service.dart';
import 'Delivery_Orders_page_state.dart';

class DeliveryOrdersPageBloc
    extends Bloc<DeliveryOrdersPageEvent, DeliveryOrdersPageState> {
  final DeliveryOrdersRepositoryBase repository;
  final DeliveryOrdersServiceBase service;

  Timer? _autoRefreshTimer;

  DeliveryOrdersPageBloc({
    DeliveryOrdersRepositoryBase? repository,
    DeliveryOrdersServiceBase? service,
  }) : repository = repository ?? DeliveryOrdersRepository(),
       service = service ?? DeliveryOrdersService(),
       super(const DeliveryOrdersPageState()) {
    on<DeliveryOrdersInitEvent>(_onInit);
    on<DeliveryOrdersTabChangedEvent>(_onTabChanged);
    on<DeliveryOrdersSearchQueryChangedEvent>(_onSearchQueryChanged);
    on<DeliveryOrdersRefreshEvent>(_onRefresh);
    on<DeliveryOrdersUpdateStatusEvent>(_onUpdateStatus);
    on<DeliveryOrdersSortChangedEvent>(_onSortChanged);
    on<DeliveryOrdersPaymentFilterChangedEvent>(_onPaymentFilterChanged);
    on<DeliveryOrdersAutoRefreshToggledEvent>(_onAutoRefreshToggled);
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }

  List<DeliveryOrderCardModel> _applyFilters(DeliveryOrdersPageState source) {
    return service.filterOrders(
      orders: source.orders,
      tab: source.activeTab,
      query: source.searchQuery,
      paymentFilter: source.paymentFilter,
      sortBy: source.sortBy,
    );
  }

  Future<void> _onInit(
    DeliveryOrdersInitEvent event,
    Emitter<DeliveryOrdersPageState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DeliveryOrdersPageStatus.loading,
        errorMessage: null,
        clearError: true,
      ),
    );
    try {
      final orders = await repository.fetchOrders();
      if (orders.isEmpty) {
        emit(
          state.copyWith(
            status: DeliveryOrdersPageStatus.empty,
            orders: const [],
            filteredOrders: const [],
          ),
        );
        return;
      }
      final next = state.copyWith(orders: orders);
      emit(
        next.copyWith(
          status: DeliveryOrdersPageStatus.loaded,
          filteredOrders: _applyFilters(next),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryOrdersPageStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onTabChanged(
    DeliveryOrdersTabChangedEvent event,
    Emitter<DeliveryOrdersPageState> emit,
  ) {
    final next = state.copyWith(activeTab: event.tab);
    emit(next.copyWith(filteredOrders: _applyFilters(next)));
  }

  void _onSearchQueryChanged(
    DeliveryOrdersSearchQueryChangedEvent event,
    Emitter<DeliveryOrdersPageState> emit,
  ) {
    final next = state.copyWith(searchQuery: event.query);
    emit(next.copyWith(filteredOrders: _applyFilters(next)));
  }

  void _onSortChanged(
    DeliveryOrdersSortChangedEvent event,
    Emitter<DeliveryOrdersPageState> emit,
  ) {
    final next = state.copyWith(sortBy: event.sortBy);
    emit(next.copyWith(filteredOrders: _applyFilters(next)));
  }

  void _onPaymentFilterChanged(
    DeliveryOrdersPaymentFilterChangedEvent event,
    Emitter<DeliveryOrdersPageState> emit,
  ) {
    final next = state.copyWith(paymentFilter: event.paymentFilter);
    emit(next.copyWith(filteredOrders: _applyFilters(next)));
  }

  void _onAutoRefreshToggled(
    DeliveryOrdersAutoRefreshToggledEvent event,
    Emitter<DeliveryOrdersPageState> emit,
  ) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    if (event.enabled) {
      _autoRefreshTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => add(const DeliveryOrdersRefreshEvent()),
      );
    }
    emit(state.copyWith(autoRefresh: event.enabled));
  }

  Future<void> _onRefresh(
    DeliveryOrdersRefreshEvent event,
    Emitter<DeliveryOrdersPageState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryOrdersPageStatus.loading));
    try {
      final orders = await repository.fetchOrders();
      if (orders.isEmpty) {
        emit(
          state.copyWith(
            status: DeliveryOrdersPageStatus.empty,
            orders: const [],
            filteredOrders: const [],
          ),
        );
        return;
      }
      final next = state.copyWith(orders: orders);
      emit(
        next.copyWith(
          status: DeliveryOrdersPageStatus.loaded,
          filteredOrders: _applyFilters(next),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryOrdersPageStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onUpdateStatus(
    DeliveryOrdersUpdateStatusEvent event,
    Emitter<DeliveryOrdersPageState> emit,
  ) async {
    try {
      final updated = await repository.updateOrderStatus(
        event.orderId,
        event.status,
      );
      final orders = state.orders
          .map((o) => o.orderId == updated.orderId ? updated : o)
          .toList();
      final next = state.copyWith(orders: orders);
      emit(
        next.copyWith(
          filteredOrders: _applyFilters(next),
          errorMessage: null,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update order status. Please try again.',
        ),
      );
    }
  }
}
