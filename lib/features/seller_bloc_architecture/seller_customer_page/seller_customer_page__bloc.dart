import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/seller_customer_repository.dart';
import 'seller_customer_page__event.dart';
import 'seller_customer_page__state.dart';

class SellerCustomerBloc extends Bloc<SellerCustomerEvent, SellerCustomerState> {
  final SellerCustomerRepository repository;
  StreamSubscription? _dataSubscription;

  SellerCustomerBloc({required this.repository}) : super(const SellerCustomerInitial()) {
    on<LoadCustomerData>(_onLoadCustomerData);
    on<CustomerDataStreamUpdated>(_onCustomerDataStreamUpdated);
    on<RefreshCustomerData>(_onRefreshCustomerData);
    on<LoadMoreCustomers>(_onLoadMoreCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<SortCustomers>(_onSortCustomers);
    on<SelectCustomer>(_onSelectCustomer);
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadCustomerData(
    LoadCustomerData event,
    Emitter<SellerCustomerState> emit,
  ) async {
    emit(const SellerCustomerLoading());

    // Cancel any existing subscription
    await _dataSubscription?.cancel();

    try {
      // First try to fetch immediate snapshot
      final stats = await repository.getCustomerStats();
      final customers = await repository.getCustomers(offset: 0, limit: 10);

      final filtered = _applyFilterAndSort(
        customers,
        '',
        CustomerSortOption.mostOrders,
      );

      emit(SellerCustomerLoaded(
        stats: stats,
        customers: customers,
        filteredCustomers: filtered,
        hasReachedMax: customers.length < 10,
      ));

      // Then subscribe to real-time updates
      _dataSubscription = repository.watchCustomerData().listen(
        (data) {
          add(CustomerDataStreamUpdated(
            stats: data.stats,
            customers: data.customers,
          ));
        },
        onError: (err) {
          // Log without interrupting loaded state if already present
        },
      );
    } catch (e) {
      emit(SellerCustomerError(e.toString()));
    }
  }

  void _onCustomerDataStreamUpdated(
    CustomerDataStreamUpdated event,
    Emitter<SellerCustomerState> emit,
  ) {
    final currentState = state;
    final query = currentState is SellerCustomerLoaded ? currentState.searchQuery : '';
    final sort = currentState is SellerCustomerLoaded
        ? currentState.selectedSort
        : CustomerSortOption.mostOrders;

    CustomerItem? updatedSelectedCustomer;
    if (currentState is SellerCustomerLoaded && currentState.selectedCustomer != null) {
      final match = event.customers.where((c) => c.id == currentState.selectedCustomer!.id);
      if (match.isNotEmpty) {
        updatedSelectedCustomer = match.first;
      }
    }

    final filtered = _applyFilterAndSort(event.customers, query, sort);

    emit(SellerCustomerLoaded(
      stats: event.stats,
      customers: event.customers,
      filteredCustomers: filtered,
      searchQuery: query,
      selectedSort: sort,
      selectedCustomer: updatedSelectedCustomer,
      hasReachedMax: true,
      isPaginatedLoading: false,
    ));
  }

  Future<void> _onRefreshCustomerData(
    RefreshCustomerData event,
    Emitter<SellerCustomerState> emit,
  ) async {
    try {
      final stats = await repository.getCustomerStats();
      final customers = await repository.getCustomers(offset: 0, limit: 10);

      final currentState = state;
      final query = currentState is SellerCustomerLoaded ? currentState.searchQuery : '';
      final sort = currentState is SellerCustomerLoaded
          ? currentState.selectedSort
          : CustomerSortOption.mostOrders;

      final filtered = _applyFilterAndSort(customers, query, sort);

      emit(SellerCustomerLoaded(
        stats: stats,
        customers: customers,
        filteredCustomers: filtered,
        searchQuery: query,
        selectedSort: sort,
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
    if (currentState is SellerCustomerLoaded &&
        !currentState.hasReachedMax &&
        !currentState.isPaginatedLoading) {
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
          final allCusts = List.of(currentState.customers)..addAll(newCustomers);
          final filtered = _applyFilterAndSort(
            allCusts,
            currentState.searchQuery,
            currentState.selectedSort,
          );
          emit(currentState.copyWith(
            customers: allCusts,
            filteredCustomers: filtered,
            hasReachedMax: newCustomers.length < 10,
            isPaginatedLoading: false,
          ));
        }
      } catch (e) {
        emit(SellerCustomerError(e.toString()));
      }
    }
  }

  void _onSearchCustomers(
    SearchCustomers event,
    Emitter<SellerCustomerState> emit,
  ) {
    final currentState = state;
    if (currentState is SellerCustomerLoaded) {
      final filtered = _applyFilterAndSort(
        currentState.customers,
        event.query,
        currentState.selectedSort,
      );
      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredCustomers: filtered,
      ));
    }
  }

  void _onSortCustomers(
    SortCustomers event,
    Emitter<SellerCustomerState> emit,
  ) {
    final currentState = state;
    if (currentState is SellerCustomerLoaded) {
      final filtered = _applyFilterAndSort(
        currentState.customers,
        currentState.searchQuery,
        event.sortOption,
      );
      emit(currentState.copyWith(
        selectedSort: event.sortOption,
        filteredCustomers: filtered,
      ));
    }
  }

  void _onSelectCustomer(
    SelectCustomer event,
    Emitter<SellerCustomerState> emit,
  ) {
    final currentState = state;
    if (currentState is SellerCustomerLoaded) {
      if (event.customer == null) {
        emit(currentState.copyWith(clearSelectedCustomer: true));
      } else {
        emit(currentState.copyWith(selectedCustomer: event.customer));
      }
    }
  }

  List<CustomerItem> _applyFilterAndSort(
    List<CustomerItem> customers,
    String query,
    CustomerSortOption sort,
  ) {
    var result = List<CustomerItem>.from(customers);

    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isNotEmpty) {
      result = result.where((c) {
        final nameMatch = c.name.toLowerCase().contains(cleanQuery);
        final phoneMatch = c.phone.toLowerCase().contains(cleanQuery) ||
            c.rawPhone.toLowerCase().contains(cleanQuery);
        final idMatch = c.id.toLowerCase().contains(cleanQuery);
        return nameMatch || phoneMatch || idMatch;
      }).toList();
    }

    switch (sort) {
      case CustomerSortOption.mostOrders:
        result.sort((a, b) => b.orderCount.compareTo(a.orderCount));
        break;
      case CustomerSortOption.highestSpending:
        result.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
        break;
      case CustomerSortOption.recentOrder:
        result.sort((a, b) {
          final timeA = a.lastOrderDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final timeB = b.lastOrderDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          return timeB.compareTo(timeA);
        });
        break;
      case CustomerSortOption.nameAsc:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
    }

    return result;
  }
}
