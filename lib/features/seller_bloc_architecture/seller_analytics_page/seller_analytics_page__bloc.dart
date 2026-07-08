import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_analytics_page__event.dart';
import 'seller_analytics_page__state.dart';
import 'seller_analytics_repository.dart';

class SellerAnalyticsBloc extends Bloc<SellerAnalyticsEvent, SellerAnalyticsState> {
  final SellerAnalyticsRepository repository;

  SellerAnalyticsBloc({required this.repository}) : super(AnalyticsInitial()) {
    on<LoadSellerAnalytics>(_onLoadSellerAnalytics);
  }

  Future<void> _onLoadSellerAnalytics(
    LoadSellerAnalytics event,
    Emitter<SellerAnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final data = await repository.fetchAnalyticsData(event.timeRange);
      emit(AnalyticsLoaded(data: data, selectedTimeRange: event.timeRange));
    } catch (e) {
      emit(AnalyticsError(message: e.toString()));
    }
  }
}
