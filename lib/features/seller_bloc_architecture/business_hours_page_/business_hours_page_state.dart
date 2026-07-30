import 'package:equatable/equatable.dart';
import 'business_hours_page_model.dart';

abstract class BusinessHoursState extends Equatable {
  const BusinessHoursState();

  @override
  List<Object?> get props => [];
}

class BusinessHoursInitial extends BusinessHoursState {
  const BusinessHoursInitial();
}

class BusinessHoursLoading extends BusinessHoursState {
  const BusinessHoursLoading();
}

class BusinessHoursLoaded extends BusinessHoursState {
  final List<BusinessDayModel> schedule;
  final bool isEmergencyClosed;
  final String? successMessage;
  final String? errorMessage;
  final bool isUpdating;

  const BusinessHoursLoaded({
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

  @override
  List<Object?> get props => [schedule, isEmergencyClosed, successMessage, errorMessage, isUpdating];
}

class BusinessHoursError extends BusinessHoursState {
  final String message;
  const BusinessHoursError(this.message);

  @override
  List<Object?> get props => [message];
}
