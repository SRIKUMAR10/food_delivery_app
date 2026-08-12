// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/order_model.dart';
import 'new_order_notification_event.dart';
import 'new_order_notification_state.dart';
import 'new_order_notification_repository.dart';

class NewOrderNotificationBloc extends Bloc<NewOrderNotificationEvent, NewOrderNotificationState> {
  final NewOrderNotificationRepository repository;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  final List<OrderModel> _pendingOrders = [];
  OrderModel? _currentOrder;

  NewOrderNotificationBloc({required this.repository})
      : super(NewOrderNotificationInitial()) {
    on<StartListening>(_onStartListening);
    on<AcceptOrderEvent>(_onAcceptOrder);
    on<RejectOrderEvent>(_onRejectOrder);
    on<DismissCurrentOrder>(_onDismissCurrentOrder);
    on<OrdersUpdated>(_onOrdersUpdated);
    on<NewOrderNotificationErrorEvent>(_onErrorEvent);
  }

  void _onStartListening(StartListening event, Emitter<NewOrderNotificationState> emit) {
    emit(NewOrderNotificationLoading());
    _ordersSubscription?.cancel();
    _ordersSubscription = repository.streamNewOrders(event.sellerId).listen(
      (orders) {
        add(OrdersUpdated(orders));
      },
      onError: (error) {
        add(NewOrderNotificationErrorEvent(error.toString()));
      },
    );
  }

  void _onErrorEvent(NewOrderNotificationErrorEvent event, Emitter<NewOrderNotificationState> emit) {
    emit(NewOrderNotificationError(event.message));
  }

  void _onOrdersUpdated(OrdersUpdated event, Emitter<NewOrderNotificationState> emit) {
    final orders = event.orders;
    if (orders.isEmpty) {
      _pendingOrders.clear();
      _currentOrder = null;
      emit(NoNewOrders());
      return;
    }

    for (var order in orders) {
      if (_currentOrder != null && _currentOrder!.id == order.id) continue;
      if (_pendingOrders.any((o) => o.id == order.id)) continue;
      _pendingOrders.add(order);
    }

    if (_currentOrder == null) {
      _showNextOrder(emit);
    }
  }

  void _showNextOrder(Emitter<NewOrderNotificationState> emit) {
    if (_pendingOrders.isEmpty) {
      _currentOrder = null;
      emit(NoNewOrders());
      return;
    }

    _currentOrder = _pendingOrders.removeAt(0);
    emit(NewOrderLoaded(order: _currentOrder!, pendingCount: _pendingOrders.length + 1));
  }

  Future<void> _onAcceptOrder(AcceptOrderEvent event, Emitter<NewOrderNotificationState> emit) async {
    try {
      await repository.acceptOrder(event.orderId);
      _currentOrder = null;
      emit(OrderAcceptedState(event.orderId));
      _showNextOrder(emit);
    } catch (e) {
      emit(NewOrderNotificationError(e.toString()));
    }
  }

  Future<void> _onRejectOrder(RejectOrderEvent event, Emitter<NewOrderNotificationState> emit) async {
    try {
      await repository.rejectOrder(event.orderId);
      _currentOrder = null;
      emit(OrderRejectedState(event.orderId));
      _showNextOrder(emit);
    } catch (e) {
      emit(NewOrderNotificationError(e.toString()));
    }
  }

  void _onDismissCurrentOrder(DismissCurrentOrder event, Emitter<NewOrderNotificationState> emit) {
    _currentOrder = null;
    _showNextOrder(emit);
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
