import 'package:flutter_bloc/flutter_bloc.dart';
import 'low_stock_alert_page__event.dart';
import 'low_stock_alert_page__state.dart';

class LowStockAlertBloc extends Bloc<LowStockAlertEvent, LowStockAlertState> {
  LowStockAlertBloc() : super(LowStockAlertInitial()) {
    on<LoadLowStockData>(_onLoadLowStockData);
    on<RefreshLowStockData>(_onRefreshLowStockData);
  }

  Future<void> _onLoadLowStockData(
    LoadLowStockData event,
    Emitter<LowStockAlertState> emit,
  ) async {
    emit(LowStockAlertLoading());
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock Data based on the provided UI Image
      final mockItems = [
        const LowStockItem(
          id: '1',
          name: 'Cheese',
          quantity: 2.5,
          unit: 'kg',
          iconPath: 'cheese_icon', // Usually from assets or network
          colorHex: 0xFFF59E0B, // Amber/Yellow
        ),
        const LowStockItem(
          id: '2',
          name: 'Chicken',
          quantity: 0.8,
          unit: 'kg',
          iconPath: 'chicken_icon',
          colorHex: 0xFFF59E0B, // Amber/Yellow
        ),
        const LowStockItem(
          id: '3',
          name: 'Capsicum',
          quantity: 0.5,
          unit: 'kg',
          iconPath: 'capsicum_icon',
          colorHex: 0xFF10B981, // Green
        ),
        const LowStockItem(
          id: '4',
          name: 'Olives',
          quantity: 0.3,
          unit: 'kg',
          iconPath: 'olives_icon',
          colorHex: 0xFF047857, // Dark Green
        ),
        const LowStockItem(
          id: '5',
          name: 'Tomatoes',
          quantity: 1.2,
          unit: 'kg',
          iconPath: 'tomatoes_icon',
          colorHex: 0xFFEF4444, // Red
        ),
      ];

      emit(LowStockAlertLoaded(items: mockItems, totalLowStockCount: mockItems.length));
    } catch (e) {
      emit(LowStockAlertError(message: 'Failed to load low stock items. Please try again.'));
    }
  }

  Future<void> _onRefreshLowStockData(
    RefreshLowStockData event,
    Emitter<LowStockAlertState> emit,
  ) async {
    // Just reload the data to simulate refresh
    add(LoadLowStockData());
  }
}
