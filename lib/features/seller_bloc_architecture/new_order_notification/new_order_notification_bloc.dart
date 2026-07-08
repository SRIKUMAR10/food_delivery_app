import 'package:flutter_bloc/flutter_bloc.dart';
import 'new_order_notification_event.dart';
import 'new_order_notification_state.dart';
import 'new_order_notification_repository.dart';

class NewOrderNotificationBloc extends Bloc<NewOrderNotificationEvent, NewOrderNotificationState> {
  final NewOrderNotificationRepository repository;

  NewOrderNotificationBloc({required this.repository}) : super(NewOrderNotificationInitial()) {
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<AcceptOrderEvent>(_onAcceptOrder);
    on<RejectOrderEvent>(_onRejectOrder);
  }

  Future<void> _onLoadOrderDetails(LoadOrderDetails event, Emitter<NewOrderNotificationState> emit) async {
    emit(NewOrderNotificationLoading());
    try {
      final orderDetails = await repository.getOrderDetails(event.orderId);
      emit(NewOrderNotificationLoaded(orderDetails));
    } catch (e) {
      emit(NewOrderNotificationError(e.toString()));
    }
  }

  Future<void> _onAcceptOrder(AcceptOrderEvent event, Emitter<NewOrderNotificationState> emit) async {
    emit(NewOrderNotificationLoading());
    try {
      await repository.acceptOrder(event.orderId);
      emit(OrderAcceptedState());
    } catch (e) {
      emit(NewOrderNotificationError(e.toString()));
    }
  }

  Future<void> _onRejectOrder(RejectOrderEvent event, Emitter<NewOrderNotificationState> emit) async {
    emit(NewOrderNotificationLoading());
    try {
      await repository.rejectOrder(event.orderId);
      emit(OrderRejectedState());
    } catch (e) {
      emit(NewOrderNotificationError(e.toString()));
    }
  }
}
