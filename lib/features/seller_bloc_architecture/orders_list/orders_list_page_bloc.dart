import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_list_page_event.dart';
import 'orders_list_page_state.dart';
import 'orders_list_page_repository.dart';

class OrdersListBloc extends Bloc<OrdersListEvent, OrdersListState> {
  final OrdersListRepository repository;
  
  List<OrderModel> _allOrders = [];
  String _activeFilter = 'New';

  OrdersListBloc({required this.repository}) : super(OrdersListInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<FilterOrders>(_onFilterOrders);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrdersListState> emit) async {
    emit(OrdersListLoading());
    try {
      _allOrders = await repository.getOrders();
      _emitFilteredState(emit);
    } catch (e) {
      emit(OrdersListError(e.toString()));
    }
  }

  void _onFilterOrders(FilterOrders event, Emitter<OrdersListState> emit) {
    if (state is OrdersListLoaded) {
      _activeFilter = event.status;
      _emitFilteredState(emit);
    }
  }

  void _emitFilteredState(Emitter<OrdersListState> emit) {
    final filtered = _allOrders.where((order) => order.status == _activeFilter).toList();
    emit(OrdersListLoaded(
      allOrders: _allOrders,
      filteredOrders: filtered,
      activeFilter: _activeFilter,
    ));
  }
}
