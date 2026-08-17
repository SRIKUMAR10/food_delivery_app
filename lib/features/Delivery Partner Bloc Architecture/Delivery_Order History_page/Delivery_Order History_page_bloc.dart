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
  })  : repository = repository ?? DeliveryOrderHistoryRepository(),
        service = service ?? DeliveryOrderHistoryService(),
        super(const DeliveryOrderHistoryPageState()) {
    on<DeliveryOrderHistoryInitEvent>(_onInit);
    on<DeliveryOrderHistorySearchChangedEvent>(_onSearchChanged);
    on<DeliveryOrderHistoryStatusFilterChangedEvent>(_onStatusFilterChanged);
    on<DeliveryOrderHistoryDatePresetChangedEvent>(_onDatePresetChanged);
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
      await emit.forEach<List<DeliveryOrderHistoryModel>>(
        repository.watchOrderHistory(),
        onData: (orders) {
          final stats = _computeStats(orders);
          if (orders.isEmpty) {
            return state.copyWith(
              status: DeliveryOrderHistoryPageStatus.empty,
              stats: stats,
              orders: const [],
              filteredOrders: const [],
              pageOrders: const [],
            );
          }
          final base = state.copyWith(orders: orders, stats: stats);
          return _applyPage(base).copyWith(
            status: DeliveryOrderHistoryPageStatus.loaded,
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(
            status: DeliveryOrderHistoryPageStatus.error,
            errorMessage: error.toString().replaceAll('Exception: ', ''),
          );
        },
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

  DeliveryOrderHistoryStats _computeStats(
    List<DeliveryOrderHistoryModel> orders,
  ) {
    final completed = orders
        .where((o) => o.status == DeliveryOrderHistoryStatus.completed)
        .length;
    final cancelled = orders
        .where((o) => o.status == DeliveryOrderHistoryStatus.cancelled)
        .length;
    final pending = orders
        .where((o) => o.status == DeliveryOrderHistoryStatus.pending)
        .length;
    final earnings = orders.fold<double>(
      0.0,
      (sum, o) => sum + (o.amount > 0 ? o.amount : 0.0),
    );
    return DeliveryOrderHistoryStats(
      totalOrders: orders.length,
      completedCount: completed,
      cancelledCount: cancelled,
      pendingCount: pending,
      totalEarnings: earnings,
    );
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

  void _onDatePresetChanged(
    DeliveryOrderHistoryDatePresetChangedEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) {
    final now = DateTime.now();
    int? startEpoch;
    int? endEpoch;
    String dateLabel = event.dateLabel;

    switch (event.preset) {
      case DeliveryOrderHistoryDatePreset.today:
        final startOfToday = DateTime(now.year, now.month, now.day);
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
        startEpoch = startOfToday.millisecondsSinceEpoch ~/ 1000;
        endEpoch = endOfToday.millisecondsSinceEpoch ~/ 1000;
        dateLabel = 'Today';
        break;

      case DeliveryOrderHistoryDatePreset.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        final startOfYesterday =
            DateTime(yesterday.year, yesterday.month, yesterday.day);
        final endOfYesterday =
            DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        startEpoch = startOfYesterday.millisecondsSinceEpoch ~/ 1000;
        endEpoch = endOfYesterday.millisecondsSinceEpoch ~/ 1000;
        dateLabel = 'Yesterday';
        break;

      case DeliveryOrderHistoryDatePreset.thisWeek:
        final currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day - (currentWeekday - 1),
        );
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
        startEpoch = startOfWeek.millisecondsSinceEpoch ~/ 1000;
        endEpoch = endOfToday.millisecondsSinceEpoch ~/ 1000;
        dateLabel = 'This Week';
        break;

      case DeliveryOrderHistoryDatePreset.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
        startEpoch = startOfMonth.millisecondsSinceEpoch ~/ 1000;
        endEpoch = endOfToday.millisecondsSinceEpoch ~/ 1000;
        dateLabel = 'This Month';
        break;

      case DeliveryOrderHistoryDatePreset.custom:
        startEpoch = event.startEpoch;
        endEpoch = event.endEpoch;
        dateLabel = event.dateLabel;
        break;

      case DeliveryOrderHistoryDatePreset.all:
        startEpoch = null;
        endEpoch = null;
        dateLabel = '';
        break;
    }

    final next = state.copyWith(
      datePreset: event.preset,
      startEpoch: startEpoch,
      endEpoch: endEpoch,
      clearDateRange: event.preset == DeliveryOrderHistoryDatePreset.all,
      dateLabel: dateLabel,
      page: 1,
    );
    emit(_applyPage(next));
  }

  void _onDateRangeChanged(
    DeliveryOrderHistoryDateRangeChangedEvent event,
    Emitter<DeliveryOrderHistoryPageState> emit,
  ) {
    final next = state.copyWith(
      datePreset: DeliveryOrderHistoryDatePreset.custom,
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
    final int target =
        event.page < 1 ? 1 : (event.page > totalPages ? totalPages : event.page);
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
      final stats = _computeStats(orders);
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
        _applyPage(base).copyWith(
          status: DeliveryOrderHistoryPageStatus.loaded,
        ),
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

/// Standardized Feature-Architecture Alias for DeliveryHistoryBloc
typedef DeliveryHistoryBloc = DeliveryOrderHistoryPageBloc;

