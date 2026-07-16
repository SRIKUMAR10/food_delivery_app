import 'business_hours_page_model.dart';

abstract class BusinessHoursEvent {}

class LoadBusinessHoursEvent extends BusinessHoursEvent {
  final String sellerId;
  LoadBusinessHoursEvent(this.sellerId);
}

class UpdateBusinessDayEvent extends BusinessHoursEvent {
  final BusinessDayModel updatedDay;
  UpdateBusinessDayEvent(this.updatedDay);
}

class ToggleEmergencyCloseEvent extends BusinessHoursEvent {
  final bool isEmergencyClosed;
  ToggleEmergencyCloseEvent(this.isEmergencyClosed);
}
