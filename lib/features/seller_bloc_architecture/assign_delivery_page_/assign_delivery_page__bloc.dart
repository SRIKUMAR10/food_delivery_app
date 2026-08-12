import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'assign_delivery_page__event.dart';
import 'assign_delivery_page__state.dart';
import 'assign_delivery_page__repository.dart';

class AssignDeliveryBloc extends Bloc<AssignDeliveryEvent, AssignDeliveryState> {
  final AssignDeliveryRepository repository;
  final String orderId;

  StreamSubscription<List<RiderModel>>? _ridersSubscription;

  AssignDeliveryBloc({required this.repository, required this.orderId})
      : super(AssignDeliveryInitial()) {
    on<LoadRidersEvent>(_onLoadRiders);
    on<RidersUpdatedEvent>(_onRidersUpdated);
    on<SelectRiderEvent>(_onSelectRider);
    on<UpdateInstructionsEvent>(_onUpdateInstructions);
    on<SubmitAssignDeliveryEvent>(_onSubmitAssignDelivery);
  }

  Future<void> _onLoadRiders(
    LoadRidersEvent event,
    Emitter<AssignDeliveryState> emit,
  ) async {
    await _ridersSubscription?.cancel();
    emit(AssignDeliveryLoading());
    _ridersSubscription = repository
        .watchAvailableRiders(event.orderId)
        .listen(
          (riders) {
            if (!isClosed) add(RidersUpdatedEvent(riders: riders));
          },
        );
  }

  void _onRidersUpdated(
    RidersUpdatedEvent event,
    Emitter<AssignDeliveryState> emit,
  ) {
    if (state is AssignDeliveryLoaded) {
      final currentState = state as AssignDeliveryLoaded;
      emit(currentState.copyWith(riders: event.riders));
    } else {
      emit(AssignDeliveryLoaded(riders: event.riders));
    }
  }

  void _onSelectRider(
    SelectRiderEvent event,
    Emitter<AssignDeliveryState> emit,
  ) {
    if (state is AssignDeliveryLoaded) {
      final currentState = state as AssignDeliveryLoaded;
      emit(currentState.copyWith(selectedRiderId: event.riderId));
    }
  }

  void _onUpdateInstructions(
    UpdateInstructionsEvent event,
    Emitter<AssignDeliveryState> emit,
  ) {
    if (state is AssignDeliveryLoaded) {
      final currentState = state as AssignDeliveryLoaded;
      emit(currentState.copyWith(deliveryInstructions: event.instructions));
    }
  }

  Future<void> _onSubmitAssignDelivery(
    SubmitAssignDeliveryEvent event,
    Emitter<AssignDeliveryState> emit,
  ) async {
    if (state is AssignDeliveryLoaded) {
      final currentState = state as AssignDeliveryLoaded;

      if (currentState.selectedRiderId == null) {
        emit(const AssignDeliveryError(message: 'Please select a rider first.'));
        emit(currentState);
        return;
      }

      emit(currentState.copyWith(isSubmitting: true));

      try {
        final success = await repository.assignRider(
          orderId,
          currentState.selectedRiderId!,
          currentState.deliveryInstructions,
        );

        if (success) {
          emit(AssignDeliverySuccess());
        } else {
          emit(const AssignDeliveryError(message: 'Failed to assign rider.'));
          emit(currentState.copyWith(isSubmitting: false));
        }
      } catch (e) {
        emit(AssignDeliveryError(message: e.toString()));
        emit(currentState.copyWith(isSubmitting: false));
      }
    }
  }

  @override
  Future<void> close() {
    _ridersSubscription?.cancel();
    return super.close();
  }
}
