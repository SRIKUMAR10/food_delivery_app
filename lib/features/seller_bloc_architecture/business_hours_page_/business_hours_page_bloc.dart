import 'package:flutter_bloc/flutter_bloc.dart';
import 'business_hours_page_event.dart';
import 'business_hours_page_state.dart';
import 'business_hours_page_repository.dart';

class BusinessHoursBloc extends Bloc<BusinessHoursEvent, BusinessHoursState> {
  final BusinessHoursRepository repository;
  String? _sellerId;

  BusinessHoursBloc({required this.repository}) : super(const BusinessHoursInitial()) {
    on<LoadBusinessHoursEvent>(_onLoadBusinessHours);
    on<UpdateBusinessDayEvent>(_onUpdateBusinessDay);
    on<ToggleEmergencyCloseEvent>(_onToggleEmergencyClose);
  }

  Future<void> _onLoadBusinessHours(LoadBusinessHoursEvent event, Emitter<BusinessHoursState> emit) async {
    _sellerId = event.sellerId;
    emit(BusinessHoursLoading());
    try {
      final data = await repository.getSchedule(event.sellerId);
      emit(BusinessHoursLoaded(
        schedule: data['schedule'],
        isEmergencyClosed: data['isEmergencyClosed'],
      ));
    } catch (e) {
      emit(BusinessHoursError('Failed to load schedule: $e'));
    }
  }

  Future<void> _onUpdateBusinessDay(UpdateBusinessDayEvent event, Emitter<BusinessHoursState> emit) async {
    final currentState = state;
    if (currentState is! BusinessHoursLoaded) return;

    emit(currentState.copyWith(isUpdating: true, clearMessages: true));

    try {
      if (_sellerId == null) throw Exception('Seller ID not initialized.');
      await repository.updateDay(_sellerId!, event.updatedDay);
      
      final newSchedule = currentState.schedule.map((day) {
        if (day.dayOfWeek == event.updatedDay.dayOfWeek) {
          return event.updatedDay;
        }
        return day;
      }).toList();

      emit(currentState.copyWith(
        schedule: newSchedule,
        isUpdating: false,
        successMessage: 'Schedule updated successfully.',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to update schedule: $e',
      ));
    }
  }

  Future<void> _onToggleEmergencyClose(ToggleEmergencyCloseEvent event, Emitter<BusinessHoursState> emit) async {
    final currentState = state;
    if (currentState is! BusinessHoursLoaded) return;

    emit(currentState.copyWith(isUpdating: true, clearMessages: true));

    try {
      if (_sellerId == null) throw Exception('Seller ID not initialized.');
      await repository.toggleEmergencyClose(_sellerId!, event.isEmergencyClosed);
      
      emit(currentState.copyWith(
        isEmergencyClosed: event.isEmergencyClosed,
        isUpdating: false,
        successMessage: event.isEmergencyClosed ? 'Store temporarily closed.' : 'Store is now open.',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to update store status: $e',
      ));
    }
  }
}
