import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/order_status.dart';
import '../../../../core/services/audio_notification_service.dart';
import 'orders_list_page_event.dart';
import 'orders_list_page_state.dart';
import 'orders_list_page_repository.dart';

class OrdersListBloc extends Bloc<OrdersListEvent, OrdersListState> {
  final OrdersListRepository repository;
  final AudioNotificationService _audioService = AudioNotificationService();
  
  List<OrderModel> _allOrders = [];
  String _activeFilter = 'New';
  String _searchQuery = '';
  int _previousNewOrderCount = 0;

  OrdersListBloc({required this.repository}) : super(OrdersListInitial()) {
    on<LoadOrdersStream>(_onLoadOrdersStream);
    on<FilterOrders>(_onFilterOrders);
    on<SearchOrders>(_onSearchOrders);
    on<ClearMessages>(_onClearMessages);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
  }

  Future<void> _onLoadOrdersStream(LoadOrdersStream event, Emitter<OrdersListState> emit) async {
    emit(OrdersListLoading());
    await emit.forEach<List<OrderModel>>(
      repository.getOrdersStream(event.sellerId),
      onData: (orders) {
        _allOrders = orders;
        
        // Check for new orders to play sound
        int currentNewOrderCount = _allOrders.where((o) => o.status == OrderStatus.newOrder).length;
        if (currentNewOrderCount > _previousNewOrderCount) {
          _audioService.playNewOrderSound();
        }
        _previousNewOrderCount = currentNewOrderCount;

        return _createFilteredState();
      },
      onError: (error, stackTrace) => OrdersListError('Failed to load orders: $error'),
    );
  }

  void _onFilterOrders(FilterOrders event, Emitter<OrdersListState> emit) {
    if (state is OrdersListLoaded) {
      _activeFilter = event.status;
      emit(_createFilteredState());
    }
  }

  void _onSearchOrders(SearchOrders event, Emitter<OrdersListState> emit) {
    if (state is OrdersListLoaded) {
      _searchQuery = event.query;
      emit(_createFilteredState(
        updatingOrderIds: (state as OrdersListLoaded).updatingOrderIds,
      ));
    }
  }

  void _onClearMessages(ClearMessages event, Emitter<OrdersListState> emit) {
    if (state is OrdersListLoaded) {
      emit((state as OrdersListLoaded).copyWith(clearMessages: true));
    }
  }

  Future<void> _onUpdateOrderStatus(UpdateOrderStatusEvent event, Emitter<OrdersListState> emit) async {
    final currentState = state;
    if (currentState is! OrdersListLoaded) return;

    final order = _allOrders.firstWhere(
      (o) => o.id == event.orderId,
      orElse: () => _allOrders.first,
    );

    if (!order.canTransitionTo(event.newStatus)) {
      emit(currentState.copyWith(
        errorMessage: 'Invalid status transition.',
      ));
      return;
    }

    final newUpdating = Set<String>.from(currentState.updatingOrderIds)..add(event.orderId);
    emit(currentState.copyWith(updatingOrderIds: newUpdating));

    try {
      await repository.updateOrderStatus(event.orderId, event.newStatus);
      if (state is OrdersListLoaded) {
        final st = state as OrdersListLoaded;
        final nextUpdating = Set<String>.from(st.updatingOrderIds)..remove(event.orderId);
        emit(st.copyWith(
          updatingOrderIds: nextUpdating,
          successMessage: 'Order status updated successfully.',
        ));
      }
    } catch (e) {
      if (state is OrdersListLoaded) {
        final st = state as OrdersListLoaded;
        final nextUpdating = Set<String>.from(st.updatingOrderIds)..remove(event.orderId);
        emit(st.copyWith(
          updatingOrderIds: nextUpdating,
          errorMessage: 'Failed to update order status: $e',
        ));
      }
    }
  }

  OrdersListLoaded _createFilteredState({Set<String> updatingOrderIds = const {}}) {
    final filtered = _allOrders.where((order) {
      final matchesFilter = order.status.value == _activeFilter;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || 
                            order.id.toLowerCase().contains(query) || 
                            order.customerName.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    return OrdersListLoaded(
      allOrders: _allOrders,
      filteredOrders: filtered,
      activeFilter: _activeFilter,
      searchQuery: _searchQuery,
      updatingOrderIds: updatingOrderIds,
    );
  }

  @override
  Future<void> close() {
    _audioService.dispose();
    return super.close();
  }
}
