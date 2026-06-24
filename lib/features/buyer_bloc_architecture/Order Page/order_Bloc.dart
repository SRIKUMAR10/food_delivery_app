import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_Event.dart';
import 'order_State.dart';
import 'order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repository;

  OrderBloc({required OrderRepository repository}) 
      : _repository = repository,
        super(OrderInitial()) {
    on<LoadOrdersRequested>(_onLoadOrdersRequested);
  }

  Future<void> _onLoadOrdersRequested(
    LoadOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    await emit.forEach<List<dynamic>>(
      _repository.getOrdersStream(),
      onData: (orders) {
        return OrderLoaded(orders.cast());
      },
      onError: (error, stackTrace) => OrderError(error.toString()),
    );
  }
}
