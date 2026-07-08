import 'package:flutter_bloc/flutter_bloc.dart';
import 'assign_delivery_page__event.dart';
import 'assign_delivery_page__state.dart';
import 'assign_delivery_page__repository.dart';

class AssignDeliveryBloc extends Bloc<AssignDeliveryEvent, AssignDeliveryState> {
  final AssignDeliveryRepository repository;
  final String orderId;

  AssignDeliveryBloc({required this.repository, required this.orderId}) : super(AssignDeliveryInitial()) {
    on<LoadRidersEvent>(_onLoadRiders);
    on<SelectRiderEvent>(_onSelectRider);
    on<UpdateInstructionsEvent>(_onUpdateInstructions);
    on<SubmitAssignDeliveryEvent>(_onSubmitAssignDelivery);
  }

  Future<void> _onLoadRiders(LoadRidersEvent event, Emitter<AssignDeliveryState> emit) async {
    emit(AssignDeliveryLoading());
    try {
      final riders = await repository.getAvailableRiders(event.orderId);
      emit(AssignDeliveryLoaded(riders: riders));
    } catch (e) {
      emit(AssignDeliveryError(message: e.toString()));
    }
  }

  void _onSelectRider(SelectRiderEvent event, Emitter<AssignDeliveryState> emit) {
    if (state is AssignDeliveryLoaded) {
      final currentState = state as AssignDeliveryLoaded;
      emit(currentState.copyWith(selectedRiderId: event.riderId));
    }
  }

  void _onUpdateInstructions(UpdateInstructionsEvent event, Emitter<AssignDeliveryState> emit) {
    if (state is AssignDeliveryLoaded) {
      final currentState = state as AssignDeliveryLoaded;
      emit(currentState.copyWith(deliveryInstructions: event.instructions));
    }
  }

  Future<void> _onSubmitAssignDelivery(SubmitAssignDeliveryEvent event, Emitter<AssignDeliveryState> emit) async {
    if (state is AssignDeliveryLoaded) {
      final currentState = state as AssignDeliveryLoaded;
      
      if (currentState.selectedRiderId == null) {
        emit(const AssignDeliveryError(message: 'Please select a rider first.'));
        // Re-emit the loaded state so the UI goes back to normal after showing error
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
}
