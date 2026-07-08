import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_dashboard_page_event.dart';
import 'seller_dashboard_page_state.dart';

class SellerDashboardPageBloc
    extends Bloc<SellerDashboardPageEvent, SellerDashboardPageState> {
  SellerDashboardPageBloc() : super(SellerDashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<SellerDashboardPageState> emit,
  ) async {
    emit(SellerDashboardLoading());
    try {
      // Simulating API call for dashboard data
      await Future.delayed(const Duration(seconds: 2));

      // Mock Data based on UI
      final mockData = DashboardData(
        totalRevenue: 45600.0,
        revenueChangePercentage: 12.5,
        pendingOrdersCount: 26,
        todaysOrdersCount: 128,
        lowStockCount: 8,
        rating: 4.8,
        todaysOrders: [
          DashboardOrder(
            id: '#11024',
            customerName: 'John Doe',
            status: 'New',
            price: 660.0,
            timeAgo: '10 min ago',
          ),
          DashboardOrder(
            id: '#11023',
            customerName: 'Jane Smith',
            status: 'Preparing',
            price: 450.0,
            timeAgo: '30 min ago',
          ),
        ],
      );

      emit(SellerDashboardLoaded(data: mockData));
    } catch (e) {
      emit(const SellerDashboardError(message: 'Failed to load dashboard data.'));
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<SellerDashboardPageState> emit,
  ) async {
    // Similar to load, but we might not want to show full loading state
    // if we are using RefreshIndicator.
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final mockData = DashboardData(
        totalRevenue: 45600.0,
        revenueChangePercentage: 12.5,
        pendingOrdersCount: 26,
        todaysOrdersCount: 128,
        lowStockCount: 8,
        rating: 4.8,
        todaysOrders: [
          DashboardOrder(
            id: '#11024',
            customerName: 'John Doe',
            status: 'New',
            price: 660.0,
            timeAgo: '10 min ago',
          ),
          DashboardOrder(
            id: '#11023',
            customerName: 'Jane Smith',
            status: 'Preparing',
            price: 450.0,
            timeAgo: '30 min ago',
          ),
        ],
      );

      emit(SellerDashboardLoaded(data: mockData));
    } catch (e) {
      emit(const SellerDashboardError(message: 'Failed to refresh dashboard.'));
    }
  }
}
