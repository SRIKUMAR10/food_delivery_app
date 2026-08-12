import 'package:equatable/equatable.dart';
import 'assign_delivery_page__state.dart';

abstract class AssignDeliveryEvent extends Equatable {
  const AssignDeliveryEvent();

  @override
  List<Object?> get props => [];
}

class LoadRidersEvent extends AssignDeliveryEvent {
  final String orderId;

  const LoadRidersEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class SelectRiderEvent extends AssignDeliveryEvent {
  final String riderId;

  const SelectRiderEvent({required this.riderId});

  @override
  List<Object?> get props => [riderId];
}

class UpdateInstructionsEvent extends AssignDeliveryEvent {
  final String instructions;

  const UpdateInstructionsEvent({required this.instructions});

  @override
  List<Object?> get props => [instructions];
}

class RidersUpdatedEvent extends AssignDeliveryEvent {
  final List<RiderModel> riders;

  const RidersUpdatedEvent({required this.riders});

  @override
  List<Object?> get props => [riders];
}

class SubmitAssignDeliveryEvent extends AssignDeliveryEvent {
  const SubmitAssignDeliveryEvent();
}
