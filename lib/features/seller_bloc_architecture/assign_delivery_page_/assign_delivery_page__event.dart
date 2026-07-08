import 'package:equatable/equatable.dart';

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

class SubmitAssignDeliveryEvent extends AssignDeliveryEvent {
  const SubmitAssignDeliveryEvent();
}
