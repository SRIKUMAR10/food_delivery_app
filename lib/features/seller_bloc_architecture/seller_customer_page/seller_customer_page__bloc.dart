import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/seller_customer_repository.dart';
import 'seller_customer_page__event.dart';
import 'seller_customer_page__state.dart';

class SellerCustomerBloc extends Bloc<SellerCustomerEvent, SellerCustomerState> {
  final SellerCustomerRepository repository;

  SellerCustomerBloc({required this.repository}) : super(const SellerCustomerInitial()) {
    on<LoadCustomerData>(_onLoadCustomerData);
    on<RefreshCustomerData>(_onRefreshCustomerData);
    on<LoadMoreCustomers>(_onLoadMoreCustomers);
  }

  Future<void> _onLoadCustomerData(
    LoadCustomerData event,
    Emitter<SellerCustomerState> emit,
  ) async {
    emit(const SellerCustomerLoading());
    try {
      final stats = await repository.getCustomerStats();
      final customers = await repository.getCustomers(offset: 0, limit: 10);
      emit(SellerCustomerLoaded(
        stats: stats,
        customers: customers,
        hasReachedMax: customers.length < 10,
      ));
    } catch (e) {
      emit(SellerCustomerError(e.toString()));
    }
  }

  Future<void> _onRefreshCustomerData(
    RefreshCustomerData event,
    Emitter<SellerCustomerState> emit,
  ) async {
    try {
      final stats = await repository.getCustomerStats();
      final customers = await repository.getCustomers(offset: 0, limit: 10);
      emit(SellerCustomerLoaded(
        stats: stats,
        customers: customers,
        hasReachedMax: customers.length < 10,
      ));
    } catch (e) {
      emit(SellerCustomerError(e.toString()));
    }
  }

  Future<void> _onLoadMoreCustomers(
    LoadMoreCustomers event,
    Emitter<SellerCustomerState> emit,
  ) async {
    final currentState = state;
    if (currentState is SellerCustomerLoaded && !currentState.hasReachedMax && !currentState.isPaginatedLoading) {
      emit(currentState.copyWith(isPaginatedLoading: true));
      try {
        final newCustomers = await repository.getCustomers(
          offset: currentState.customers.length,
          limit: 10,
        );
        if (newCustomers.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isPaginatedLoading: false,
          ));
        } else {
          emit(currentState.copyWith(
            customers: List.of(currentState.customers)..addAll(newCustomers),
            hasReachedMax: newCustomers.length < 10,
            isPaginatedLoading: false,
          ));
        }
      } catch (e) {
        emit(SellerCustomerError(e.toString()));
      }
    }
  }
}
