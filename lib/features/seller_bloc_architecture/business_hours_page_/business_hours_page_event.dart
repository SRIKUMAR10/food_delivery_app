import 'package:equatable/equatable.dart';
import 'business_hours_page_model.dart';

abstract class BusinessHoursEvent extends Equatable {
  const BusinessHoursEvent();

  @override
  List<Object?> get props => [];
}

class LoadBusinessHoursEvent extends BusinessHoursEvent {
  final String sellerId;
  const LoadBusinessHoursEvent(this.sellerId);

  @override
  List<Object?> get props => [sellerId];
}

class BusinessHoursUpdatedStreamEvent extends BusinessHoursEvent {
  final List<BusinessDayModel> schedule;
  final bool isEmergencyClosed;

  const BusinessHoursUpdatedStreamEvent({
    required this.schedule,
    required this.isEmergencyClosed,
  });

  @override
  List<Object?> get props => [schedule, isEmergencyClosed];
}

class UpdateBusinessDayEvent extends BusinessHoursEvent {
  final BusinessDayModel updatedDay;
  const UpdateBusinessDayEvent(this.updatedDay);

  @override
  List<Object?> get props => [updatedDay];
}

class ToggleEmergencyCloseEvent extends BusinessHoursEvent {
  final bool isEmergencyClosed;
  const ToggleEmergencyCloseEvent(this.isEmergencyClosed);

  @override
  List<Object?> get props => [isEmergencyClosed];
}

class SaveFullBusinessHoursEvent extends BusinessHoursEvent {
  final List<BusinessDayModel> schedule;
  final bool? isEmergencyClosed;

  const SaveFullBusinessHoursEvent({
    required this.schedule,
    this.isEmergencyClosed,
  });

  @override
  List<Object?> get props => [schedule, isEmergencyClosed];
}


