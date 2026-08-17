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
    on<MarkGoingToRestaurantEvent>(_onMarkGoingToRestaurant);
    on<MarkArrivedAtRestaurantEvent>(_onMarkArrivedAtRestaurant);
    on<ToggleItemVerificationEvent>(_onToggleItemVerification);
    on<OtpInputChangedEvent>(_onOtpInputChanged);
    on<VerifyPickupOtpEvent>(_onVerifyPickupOtp);
    on<ConfirmPickupEvent>(_onConfirmPickup);
    on<ToggleLanguageEvent>(_onToggleLanguage);
    on<CallCustomerEvent>(_onCallCustomer);
    on<CallMerchantEvent>(_onCallMerchant);
    on<CollectCodCashEvent>(_onCollectCodCash);
  }

  void _onFetchOrderDetails(
    FetchOrderDetailsEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: OrderDetailsStatus.loading));
    try {
      await emit.forEach<OrderModel>(
        repository.watchOrderDetails(event.orderId),
        onData: (order) {
          if (order.id.trim().isEmpty) {
            return state.copyWith(
              status: OrderDetailsStatus.error,
              errorMessage: 'Order not found or could not be loaded.',
            );
          }
          final updatedItems = order.items.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            final isItemVerified = state.verifiedItemIndices.contains(idx) || item.isVerified;
            return item.copyWith(isVerified: isItemVerified);
          }).toList();

          return state.copyWith(
            status: OrderDetailsStatus.success,
            order: order.copyWith(items: updatedItems),
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(
            status: OrderDetailsStatus.error,
            errorMessage: error.toString(),
          );
        },
      );
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

  void _onMarkGoingToRestaurant(
    MarkGoingToRestaurantEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) async {
    if (state.order == null) return;
    try {
      await repository.markGoingToRestaurant(event.orderId);
      final updatedOrder = state.order!.copyWith(
        pickupStatus: 'GOING_TO_RESTAURANT',
        status: 'GOING_TO_RESTAURANT',
      );
      emit(state.copyWith(order: updatedOrder));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onMarkArrivedAtRestaurant(
    MarkArrivedAtRestaurantEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) async {
    if (state.order == null) return;
    try {
      await repository.markArrivedAtRestaurant(event.orderId);
      final updatedOrder = state.order!.copyWith(
        pickupStatus: 'ARRIVED_AT_RESTAURANT',
        status: 'ARRIVED_AT_RESTAURANT',
      );
      emit(state.copyWith(order: updatedOrder));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onToggleItemVerification(
    ToggleItemVerificationEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) {
    if (state.order == null) return;
    final updatedIndices = Set<int>.from(state.verifiedItemIndices);
    if (updatedIndices.contains(event.itemIndex)) {
      updatedIndices.remove(event.itemIndex);
    } else {
      updatedIndices.add(event.itemIndex);
    }

    final updatedItems = state.order!.items.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      return item.copyWith(isVerified: updatedIndices.contains(idx));
    }).toList();

    final updatedOrder = state.order!.copyWith(items: updatedItems);
    emit(state.copyWith(
      order: updatedOrder,
      verifiedItemIndices: updatedIndices,
    ));
  }

  void _onOtpInputChanged(
    OtpInputChangedEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) {
    emit(state.copyWith(
      enteredOtp: event.otp,
      otpStatus: OtpVerificationStatus.initial,
    ));
  }

  void _onVerifyPickupOtp(
    VerifyPickupOtpEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) async {
    if (state.order == null) return;
    emit(state.copyWith(otpStatus: OtpVerificationStatus.verifying));
    try {
      final isValid = await repository.verifyPickupOtp(event.orderId, event.otp);
      if (isValid) {
        final updatedOrder = state.order!.copyWith(isOtpVerified: true);
        emit(state.copyWith(
          order: updatedOrder,
          otpStatus: OtpVerificationStatus.success,
        ));
      } else {
        emit(state.copyWith(
          otpStatus: OtpVerificationStatus.invalid,
          errorMessage: 'Invalid Pickup OTP. Please check with the restaurant seller.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        otpStatus: OtpVerificationStatus.invalid,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onConfirmPickup(
    ConfirmPickupEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) async {
    if (state.order == null) return;
    emit(state.copyWith(status: OrderDetailsStatus.loading));
    try {
      await repository.confirmPickup(event.orderId);
      final updatedOrder = state.order!.copyWith(
        pickupStatus: 'PICKED_UP',
        status: 'OutForDelivery',
        isOtpVerified: true,
      );
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

  void _onToggleLanguage(
    ToggleLanguageEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) {
    emit(state.copyWith(selectedLanguage: event.languageCode));
  }

  void _onCallCustomer(
    CallCustomerEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) {
    // Call dispatched
  }

  void _onCallMerchantEvent(
    CallMerchantEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) {
    // Call dispatched
  }

  void _onCallMerchant(
    CallMerchantEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) {
    // Merchant call dispatched
  }

  void _onCollectCodCash(
    CollectCodCashEvent event,
    Emitter<DeliveryOrderDetailsPageState> emit,
  ) async {
    if (state.order == null) return;
    emit(state.copyWith(
      codCollectionStatus: CodCollectionStatus.collecting,
      clearCodCollectionMessage: true,
    ));
    try {
      final result = await repository.collectCodCash(
        event.orderId,
        amountReceived: event.amountReceived,
      );
      if (result['success'] == true) {
        final updatedOrder = state.order!.copyWith(
          isCodCollected: true,
          collectedAmount:
              (result['collectedAmount'] as num?)?.toDouble() ?? 0.0,
          paymentStatus: 'COLLECTED',
          codReconciliationStatus: 'pending_submission',
        );
        emit(state.copyWith(
          order: updatedOrder,
          codCollectionStatus: CodCollectionStatus.success,
          codReceivedAmount: event.amountReceived,
          codChangeAmount: (result['changeAmount'] as num?)?.toDouble() ?? 0.0,
          codCollectionMessage: result['message']?.toString(),
        ));
      } else {
        emit(state.copyWith(
          codCollectionStatus: CodCollectionStatus.failed,
          codCollectionMessage: result['message']?.toString(),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        codCollectionStatus: CodCollectionStatus.failed,
        codCollectionMessage: e.toString(),
      ));
    }
  }
}
