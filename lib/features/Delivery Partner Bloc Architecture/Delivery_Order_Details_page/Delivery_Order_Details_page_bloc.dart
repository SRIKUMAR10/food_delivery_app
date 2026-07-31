import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Order_Details_page_event.dart';
import 'Delivery_Order_Details_page_state.dart';

class DeliveryOrderDetailsPageBloc
    extends Bloc<DeliveryOrderDetailsPageEvent, DeliveryOrderDetailsPageState> {
  DeliveryOrderDetailsPageBloc() : super(const DeliveryOrderDetailsPageState()) {
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
      // Mock loading delay and fetch database logic
      await Future.delayed(const Duration(milliseconds: 500));
      
      const mockOrder = OrderModel(
        id: '#ORD12345',
        pickupAddress: 'Green Mart, 24, Anna Salai, Chennai',
        dropoffAddress: 'Mike Residence, 12, Beach Road, Chennai',
        earnings: 120.0,
        distance: 2.4,
        status: 'Pending',
        customerPhone: '+919876543210',
        merchantPhone: '+919876543211',
        orderValue: 620.0,
      );

      emit(state.copyWith(
        status: OrderDetailsStatus.success,
        order: mockOrder,
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
      await Future.delayed(const Duration(milliseconds: 300));
      final updatedOrder = state.order!.copyWith(status: event.status);
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
