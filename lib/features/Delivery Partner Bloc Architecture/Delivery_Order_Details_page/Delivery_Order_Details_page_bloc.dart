import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Order_Details_page_event.dart';
import 'Delivery_Order_Details_page_repository.dart';
import 'Delivery_Order_Details_page_state.dart';

class DeliveryOrderDetailsPageBloc
    extends Bloc<DeliveryOrderDetailsPageEvent, DeliveryOrderDetailsPageState> {
  final DeliveryOrderDetailsRepositoryBase repository;

  DeliveryOrderDetailsPageBloc({
    DeliveryOrderDetailsRepositoryBase? repository,
  })  : repository = repository ?? DeliveryOrderDetailsRepository(),
        super(const DeliveryOrderDetailsPageState()) {
    on<FetchOrderDetailsEvent>(_onFetchOrderDetails);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<CallCustomerEvent>(_onCallCustomer);
    on<CallMerchantEvent>(_onCallMerchant);
  }

  void _onFetchOrderDetails(
    FetchOrderDetailsEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: OrderDetailsStatus.loading));
    try {
      final order = await repository.fetchOrderDetails(event.orderId);
      emit(state.copyWith(
        status: OrderDetailsStatus.success,
        order: order,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderDetailsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) async {
    if (state.order == null) return;
    emit(state.copyWith(status: OrderDetailsStatus.loading));
    try {
      final updatedOrder =
          await repository.updateOrderStatus(event.orderId, event.status);
      emit(state.copyWith(
        status: OrderDetailsStatus.success,
        order: updatedOrder,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderDetailsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onCallCustomer(
    CallCustomerEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) {
    // Phone launch logic handled here or delegating to UI handler
  }

  void _onCallMerchant(
    CallMerchantEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) {
    // Phone launch logic handled here or delegating to UI handler
  }
}
