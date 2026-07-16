import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_dashboard_page_event.dart';
import 'seller_dashboard_page_state.dart';
import 'seller_dashboard_repository.dart';

class SellerDashboardPageBloc
    extends Bloc<SellerDashboardPageEvent, SellerDashboardPageState> {
  final SellerDashboardRepository repository;

  SellerDashboardPageBloc({required this.repository})
      : super(SellerDashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<SellerDashboardPageState> emit,
  ) async {
    emit(SellerDashboardLoading());
    try {
      await emit.forEach<DashboardData>(
        repository.getDashboardDataStream(),
        onData: (data) => SellerDashboardLoaded(data: data),
        onError: (error, stackTrace) =>
            const SellerDashboardError(message: 'Failed to load dashboard data.'),
      );
    } catch (e) {
      emit(const SellerDashboardError(message: 'Failed to load dashboard data.'));
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<SellerDashboardPageState> emit,
  ) async {
    // With stream based approach, manual refresh might just fetch the current state 
    // or re-trigger the stream. The stream already keeps it fresh. 
    // But for UI feedback (like Pull to Refresh), we can manually get one snapshot.
    try {
      final data = await repository.getDashboardData();
      emit(SellerDashboardLoaded(data: data));
    } catch (e) {
      emit(const SellerDashboardError(message: 'Failed to refresh dashboard.'));
    }
  }
}
