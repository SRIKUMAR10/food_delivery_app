import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Incentives Dashboard_page_event.dart';
import 'Delivery_Incentives Dashboard_page_repository.dart';
import 'Delivery_Incentives Dashboard_page_service.dart';
import 'Delivery_Incentives Dashboard_page_state.dart';

class DeliveryIncentivesDashboardPageBloc
    extends Bloc<DeliveryIncentivesDashboardPageEvent,
        DeliveryIncentivesDashboardState> {
  final DeliveryIncentivesDashboardRepositoryBase repository;
  final DeliveryIncentivesDashboardServiceBase service;

  DeliveryIncentivesDashboardPageBloc({
    DeliveryIncentivesDashboardRepositoryBase? repository,
    DeliveryIncentivesDashboardServiceBase? service,
  }) : repository = repository ?? DeliveryIncentivesDashboardRepository(),
       service = service ?? DeliveryIncentivesDashboardService(),
       super(const DeliveryIncentivesDashboardInitialState()) {
    on<FetchIncentivesDataEvent>(_onFetch);
    on<RefreshIncentivesDataEvent>(_onRefresh);
    on<FilterRewardHistoryEvent>(_onFilter);
    on<ChangePageEvent>(_onChangePage);
    on<ExportRewardHistoryEvent>(_onExport);
    on<UpdateDateRangeEvent>(_onUpdateDateRange);
  }

  Future<void> _onFetch(
    FetchIncentivesDataEvent event,
    Emitter<DeliveryIncentivesDashboardState> emit,
  ) async {
    emit(
      DeliveryIncentivesDashboardLoadingState(
        selectedRange: state.selectedRange,
        localeCode: state.localeCode,
      ),
    );
    try {
      await emit.forEach<DeliveryIncentivesDashboardLoadedState>(
        repository.watchIncentivesData(),
        onData: (loaded) {
          return _withContext(
            _isDashboardEmpty(loaded)
                ? DeliveryIncentivesDashboardEmptyState()
                : loaded,
          );
        },
        onError: (e, stack) {
          return DeliveryIncentivesDashboardErrorState(
            errorMessage: e.toString(),
            selectedRange: state.selectedRange,
            localeCode: state.localeCode,
          );
        },
      );
    } catch (e) {
      try {
        final loaded = await repository.loadIncentivesData();
        emit(
          _withContext(
            _isDashboardEmpty(loaded)
                ? DeliveryIncentivesDashboardEmptyState()
                : loaded,
          ),
        );
      } catch (err) {
        emit(
          DeliveryIncentivesDashboardErrorState(
            errorMessage: err.toString(),
            selectedRange: state.selectedRange,
            localeCode: state.localeCode,
          ),
        );
      }
    }
  }

  Future<void> _onRefresh(
    RefreshIncentivesDataEvent event,
    Emitter<DeliveryIncentivesDashboardState> emit,
  ) async {
    emit(
      DeliveryIncentivesDashboardLoadingState(
        selectedRange: state.selectedRange,
        localeCode: state.localeCode,
      ),
    );
    try {
      final loaded = await repository.loadIncentivesData();
      emit(_withContext(loaded));
    } catch (e) {
      emit(
        DeliveryIncentivesDashboardErrorState(
          errorMessage: e.toString(),
          selectedRange: state.selectedRange,
          localeCode: state.localeCode,
        ),
      );
    }
  }

  void _onFilter(
    FilterRewardHistoryEvent event,
    Emitter<DeliveryIncentivesDashboardState> emit,
  ) {
    final current = state;
    if (current is! DeliveryIncentivesDashboardLoadedState) return;
    emit(
      current.copyWith(
        activeFilter: event.filter,
        currentPage: 0,
      ),
    );
  }

  void _onChangePage(
    ChangePageEvent event,
    Emitter<DeliveryIncentivesDashboardState> emit,
  ) {
    final current = state;
    if (current is! DeliveryIncentivesDashboardLoadedState) return;
    if (event.page < 0 || event.page >= current.totalPages) return;
    emit(current.copyWith(currentPage: event.page));
  }

  Future<void> _onExport(
    ExportRewardHistoryEvent event,
    Emitter<DeliveryIncentivesDashboardState> emit,
  ) async {
    final current = state;
    if (current is! DeliveryIncentivesDashboardLoadedState) return;
    if (current.isExporting) return;
    emit(current.copyWith(isExporting: true));
    try {
      await repository.exportRewardHistory(current.filteredRewards);
      emit(current.copyWith(isExporting: false));
    } catch (_) {
      emit(current.copyWith(isExporting: false));
    }
  }

  void _onUpdateDateRange(
    UpdateDateRangeEvent event,
    Emitter<DeliveryIncentivesDashboardState> emit,
  ) {
    final current = state;
    if (current is! DeliveryIncentivesDashboardLoadedState) return;
    emit(current.copyWith(selectedRange: event.range));
  }

  bool _isDashboardEmpty(DeliveryIncentivesDashboardLoadedState state) {
    return state.rewardHistory.isEmpty && state.donutSlices.isEmpty;
  }

  DeliveryIncentivesDashboardState _withContext(
    DeliveryIncentivesDashboardState next,
  ) {
    return next is DeliveryIncentivesDashboardLoadedState
        ? next.copyWith(
            selectedRange: state.selectedRange,
            localeCode: state.localeCode,
          )
        : next;
  }
}

/// Standardized Feature-Architecture Alias for IncentiveBloc
typedef IncentiveBloc = DeliveryIncentivesDashboardPageBloc;

