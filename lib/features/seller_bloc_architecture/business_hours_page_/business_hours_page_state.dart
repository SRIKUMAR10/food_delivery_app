import 'business_hours_page_model.dart';

abstract class BusinessHoursState {}

class BusinessHoursInitial extends BusinessHoursState {}

class BusinessHoursLoading extends BusinessHoursState {}

class BusinessHoursLoaded extends BusinessHoursState {
  final List<BusinessDayModel> schedule;
  final bool isEmergencyClosed;
  final String? successMessage;
  final String? errorMessage;
  final bool isUpdating;

  BusinessHoursLoaded({
    required this.schedule,
    required this.isEmergencyClosed,
    this.successMessage,
    this.errorMessage,
    this.isUpdating = false,
  });

  BusinessHoursLoaded copyWith({
    List<BusinessDayModel>? schedule,
    bool? isEmergencyClosed,
    String? successMessage,
    String? errorMessage,
    bool? isUpdating,
    bool clearMessages = false,
  }) {
    return BusinessHoursLoaded(
      schedule: schedule ?? this.schedule,
      isEmergencyClosed: isEmergencyClosed ?? this.isEmergencyClosed,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class BusinessHoursError extends BusinessHoursState {
  final String message;
  BusinessHoursError(this.message);
}
