import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Order History_page_event.dart';
import 'Delivery_Order History_page_repository.dart';
import 'Delivery_Order History_page_service.dart';
import 'Delivery_Order History_page_state.dart';

class DeliveryOrderHistoryPageBloc
    extends Bloc<DeliveryOrderHistoryPageEvent, DeliveryOrderHistoryPageState> {
  final DeliveryOrderHistoryRepositoryBase repository;
  final DeliveryOrderHistoryServiceBase service;

  DeliveryOrderHistoryPageBloc({
    DeliveryOrderHistoryRepositoryBase? repository,
    DeliveryOrderHistoryServiceBase? service,
  }) : repository = repository ?? DeliveryOrderHistoryRepository(),
       service = service ?? DeliveryOrderHistoryService(),
       super(const DeliveryOrderHistoryPageState()) {
    on<DeliveryOrderHistoryInitEvent>(_onInit);
    on<DeliveryOrderHistorySearchChangedEvent>(_onSearchChanged);
    on<DeliveryOrderHistoryStatusFilterChangedEvent>(_onStatusFilterChanged);
    on<DeliveryOrderHistoryDateRangeChangedEvent>(_onDateRangeChanged);
    on<DeliveryOrderHistoryPaymentFilterChangedEvent>(_onPaymentFilterChanged);
    on<DeliveryOrderHistoryPageChangedEvent>(_onPageChanged);
    on<DeliveryOrderHistoryPageSizeChangedEvent>(_onPageSizeChanged);
    on<DeliveryOrderHistoryRefreshEvent>(_onRefresh);
    on<DeliveryOrderHistoryToggleSidebarEvent>(_onToggleSidebar);
  }

  List<DeliveryOrderHistoryModel> _applyFilters(
    DeliveryOrderHistoryPageState source,
  ) {
    return service.filterOrderHistory(
      orders: source.orders,
      query: source.searchQuery,
      statusFilter: source.statusFilter,
      paymentFilter: source.paymentFilter,
      startEpoch: source.startEpoch,
      endEpoch: source.endEpoch,
    );
  }

  DeliveryOrderHistoryPageState _applyPage(
    DeliveryOrderHistoryPageState source,
  ) {
    final filtered = _applyFilters(source);
    final result = service.paginate(
      orders: filtered,
      page: source.page,
      pageSize: source.pageSize,
    );
    return source.copyWith(
      filteredOrders: filtered,
      pageOrders: result.items,
    );
  }

  Future<void> _onInit(
    DeliveryOrderHistoryInitEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DeliveryOrderHistoryPageStatus.loading,
        errorMessage: null,
        clearError: true,
      ),
    );
    try {
      final orders = await repository.fetchOrderHistory();
      final stats = await repository.fetchStats();
      if (orders.isEmpty) {
        emit(
          state.copyWith(
            status: DeliveryOrderHistoryPageStatus.empty,
            stats: stats,
            orders: const [],
            filteredOrders: const [],
            pageOrders: const [],
          ),
        );
        return;
      }
      final base = state.copyWith(orders: orders, stats: stats);
      emit(
        _applyPage(base).copyWith(status: DeliveryOrderHistoryPageStatus.loaded),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryOrderHistoryPageStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onSearchChanged(
    DeliveryOrderHistorySearchChangedEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) {
    final next = state.copyWith(
      searchQuery: event.query,
      page: 1,
    );
    emit(_applyPage(next));
  }

  void _onStatusFilterChanged(
    DeliveryOrderHistoryStatusFilterChangedEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) {
    final next = state.copyWith(
      statusFilter: event.filter,
      page: 1,
    );
    emit(_applyPage(next));
  }

  void _onDateRangeChanged(
    DeliveryOrderHistoryDateRangeChangedEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) {
    final next = state.copyWith(
      startEpoch: event.startEpoch,
      endEpoch: event.endEpoch,
      dateLabel: event.dateLabel,
      page: 1,
    );
    emit(_applyPage(next));
  }

  void _onPaymentFilterChanged(
    DeliveryOrderHistoryPaymentFilterChangedEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) {
    final next = state.copyWith(
      paymentFilter: event.filter,
      page: 1,
    );
    emit(_applyPage(next));
  }

  void _onPageChanged(
    DeliveryOrderHistoryPageChangedEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) {
    final int totalPages = state.totalPages;
    final int target = event.page < 1 ? 1 : (event.page > totalPages ? totalPages : event.page);
    final next = state.copyWith(page: target);
    emit(_applyPage(next));
  }

  void _onPageSizeChanged(
    DeliveryOrderHistoryPageSizeChangedEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) {
    final next = state.copyWith(
      pageSize: event.pageSize,
      page: 1,
    );
    emit(_applyPage(next));
  }

  Future<void> _onRefresh(
    DeliveryOrderHistoryRefreshEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryOrderHistoryPageStatus.loading));
    try {
      final orders = await repository.fetchOrderHistory();
      final stats = await repository.fetchStats();
      if (orders.isEmpty) {
        emit(
          state.copyWith(
            status: DeliveryOrderHistoryPageStatus.empty,
            stats: stats,
            orders: const [],
            filteredOrders: const [],
            pageOrders: const [],
          ),
        );
        return;
      }
      final base = state.copyWith(orders: orders, stats: stats);
      emit(
        _applyPage(base).copyWith(status: DeliveryOrderHistoryPageStatus.loaded),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryOrderHistoryPageStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onToggleSidebar(
    DeliveryOrderHistoryToggleSidebarEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) {
    emit(state.copyWith(sidebarOpen: !state.sidebarOpen));
  }
}
