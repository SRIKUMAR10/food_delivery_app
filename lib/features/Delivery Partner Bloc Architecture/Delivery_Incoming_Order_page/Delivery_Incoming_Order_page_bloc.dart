import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Incoming_Order_page_event.dart';
import 'Delivery_Incoming_Order_page_repository.dart';
import 'Delivery_Incoming_Order_page_service.dart';
import 'Delivery_Incoming_Order_page_state.dart';

class DeliveryIncomingOrderBloc
    extends Bloc<DeliveryIncomingOrderEvent, DeliveryIncomingOrderState> {
  final DeliveryIncomingOrderRepositoryBase repository;
  final DeliveryIncomingOrderServiceBase service;
  Timer? _timer;
  static const int _totalSeconds = 15;

  DeliveryIncomingOrderBloc({
    DeliveryIncomingOrderRepositoryBase? repository,
    DeliveryIncomingOrderServiceBase? service,
  })  : repository = repository ?? DeliveryIncomingOrderRepository(),
        service = service ?? DeliveryIncomingOrderService(),
        super(const DeliveryIncomingOrderState()) {
    on<DeliveryIncomingOrderLoadEvent>(_onLoad);
    on<DeliveryIncomingOrderAcceptEvent>(_onAccept);
    on<DeliveryIncomingOrderDeclineEvent>(_onDecline);
    on<DeliveryIncomingOrderTimerTickEvent>(_onTimerTick);
    on<DeliveryIncomingOrderTimerExpiredEvent>(_onTimerExpired);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.remainingSeconds - 1;
      if (next <= 0) {
        _timer?.cancel();
        add(const DeliveryIncomingOrderTimerExpiredEvent());
      } else {
        add(DeliveryIncomingOrderTimerTickEvent(next));
      }
    });
  }

  Future<void> _onLoad(
    DeliveryIncomingOrderLoadEvent event,
    Emitter<DeliveryIncomingOrderState> emit,
  ) async {
    emit(state.copyWith(status: IncomingOrderStatus.loading));
    try {
      final orderData = await repository.fetchIncomingOrder();
      emit(orderData.copyWith(
        status: IncomingOrderStatus.loaded,
        remainingSeconds: _totalSeconds,
      ));
      _startTimer();
    } catch (e) {
      emit(state.copyWith(
        status: IncomingOrderStatus.expired,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAccept(
    DeliveryIncomingOrderAcceptEvent event,
    Emitter<DeliveryIncomingOrderState> emit,
  ) async {
    _timer?.cancel();
    try {
      await repository.acceptOrder(state.orderId);
      emit(state.copyWith(status: IncomingOrderStatus.accepted));
    } catch (e) {
      emit(state.copyWith(
        status: IncomingOrderStatus.accepted,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDecline(
    DeliveryIncomingOrderDeclineEvent event,
    Emitter<DeliveryIncomingOrderState> emit,
  ) async {
    _timer?.cancel();
    try {
      await repository.declineOrder(state.orderId);
      emit(state.copyWith(status: IncomingOrderStatus.declined));
    } catch (e) {
      emit(state.copyWith(status: IncomingOrderStatus.declined));
    }
  }

  void _onTimerTick(
    DeliveryIncomingOrderTimerTickEvent event,
    Emitter<DeliveryIncomingOrderState> emit,
  ) {
    emit(state.copyWith(remainingSeconds: event.remainingSeconds));
  }

  void _onTimerExpired(
    DeliveryIncomingOrderTimerExpiredEvent event,
    Emitter<DeliveryIncomingOrderState> emit,
  ) {
    _timer?.cancel();
    emit(state.copyWith(
      status: IncomingOrderStatus.expired,
      remainingSeconds: 0,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
