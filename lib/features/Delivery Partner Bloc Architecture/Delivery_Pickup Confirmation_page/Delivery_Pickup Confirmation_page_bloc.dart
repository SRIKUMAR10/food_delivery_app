import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Pickup Confirmation_page_event.dart';
import 'Delivery_Pickup Confirmation_page_repository.dart';
import 'Delivery_Pickup Confirmation_page_service.dart';
import 'Delivery_Pickup Confirmation_page_state.dart';
import '../../../core/repositories/delivery_active_order_session_repository.dart';

class DeliveryPickupConfirmationPageBloc
    extends Bloc<DeliveryPickupConfirmationPageEvent,
        DeliveryPickupConfirmationPageState> {
  final DeliveryPickupConfirmationRepositoryBase repository;
  final DeliveryPickupConfirmationServiceBase service;
  final DeliveryActiveOrderSessionRepository? _sessionRepo;

  DeliveryPickupConfirmationPageBloc({
    DeliveryPickupConfirmationRepositoryBase? repository,
    DeliveryPickupConfirmationServiceBase? service,
    DeliveryActiveOrderSessionRepository? sessionRepo,
  })  : repository = repository ?? DeliveryPickupConfirmationRepository(),
        service = service ?? DeliveryPickupConfirmationService(),
        _sessionRepo = sessionRepo,
        super(const DeliveryPickupConfirmationPageState()) {
    on<FetchPickupConfirmationDetailsEvent>(_onFetchDetails);
    on<StartDeliveryEvent>(_onStartDelivery);
    on<CallCustomerEvent>(_onCallCustomer);
    on<OpenWhatsAppEvent>(_onOpenWhatsApp);
    on<CallStoreEvent>(_onCallStore);
  }

  Future<void> _onFetchDetails(
    FetchPickupConfirmationDetailsEvent event,
    Emitter<DeliveryPickupConfirmationPageState> emit,
  ) async {
    emit(state.copyWith(status: PickupConfirmationStatus.loading));
    try {
      final model =
          await repository.fetchPickupConfirmationDetails(event.orderId);
      emit(state.copyWith(
        status: PickupConfirmationStatus.success,
        model: model,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PickupConfirmationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStartDelivery(
    StartDeliveryEvent event,
    Emitter<DeliveryPickupConfirmationPageState> emit,
  ) async {
    if (state.model == null) return;
    emit(state.copyWith(status: PickupConfirmationStatus.loading));
    try {
      final model = await repository.startDelivery(event.orderId);
      _sessionRepo?.confirmPickup();
      emit(state.copyWith(
        status: PickupConfirmationStatus.deliveryStarted,
        model: model,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PickupConfirmationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onCallCustomer(
    CallCustomerEvent event,
    Emitter<DeliveryPickupConfirmationPageState> emit,
  ) {
    // Launch handling is delegated to the UI so platform calls stay out of tests.
  }

  void _onOpenWhatsApp(
    OpenWhatsAppEvent event,
    Emitter<DeliveryPickupConfirmationPageState> emit,
  ) {
    // WhatsApp deep link handling is delegated to the UI layer.
  }

  void _onCallStore(
    CallStoreEvent event,
    Emitter<DeliveryPickupConfirmationPageState> emit,
  ) {
    // Store phone launch handling is delegated to the UI layer.
  }
}
