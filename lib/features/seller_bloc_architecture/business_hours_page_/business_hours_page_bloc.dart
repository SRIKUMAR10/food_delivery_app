import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'business_hours_page_event.dart';
import 'business_hours_page_state.dart';
import 'business_hours_page_repository.dart';
import 'business_hours_page_model.dart';

class BusinessHoursBloc extends Bloc<BusinessHoursEvent, BusinessHoursState> {
  final BusinessHoursRepository repository;
  String? _sellerId;
  StreamSubscription<Map<String, dynamic>>? _scheduleSubscription;

  BusinessHoursBloc({required this.repository}) : super(const BusinessHoursInitial()) {
    on<LoadBusinessHoursEvent>(_onLoadBusinessHours);
    on<BusinessHoursUpdatedStreamEvent>(_onBusinessHoursUpdatedStream);
    on<UpdateBusinessDayEvent>(_onUpdateBusinessDay);
    on<ToggleEmergencyCloseEvent>(_onToggleEmergencyClose);
    on<SaveFullBusinessHoursEvent>(_onSaveFullBusinessHours);
  }

  String _getEffectiveSellerId() {
    if (_sellerId != null && _sellerId!.trim().isNotEmpty) {
      return _sellerId!.trim();
    }
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? 'seller1';
    } catch (_) {
      return 'seller1';
    }
  }

  Future<void> _onLoadBusinessHours(LoadBusinessHoursEvent event, Emitter<BusinessHoursState> emit) async {
    _sellerId = event.sellerId;
    emit(const BusinessHoursLoading());

    await _scheduleSubscription?.cancel();
    try {
      final targetId = _getEffectiveSellerId();
      final stream = repository.watchSchedule(targetId);
      _scheduleSubscription = stream.listen(
        (data) {
          final rawSchedule = data['schedule'];
          List<BusinessDayModel> scheduleList = [];
          if (rawSchedule is List<BusinessDayModel>) {
            scheduleList = rawSchedule;
          } else if (rawSchedule is List) {
            scheduleList = rawSchedule.cast<BusinessDayModel>();
          }
          add(BusinessHoursUpdatedStreamEvent(
            schedule: scheduleList,
            isEmergencyClosed: data['isEmergencyClosed'] == true,
          ));
        },
        onError: (_) {},
      );
    } catch (_) {}

    try {
      final targetId = _getEffectiveSellerId();
      final data = await repository.getSchedule(targetId);
      final rawSchedule = data['schedule'];
      List<BusinessDayModel> scheduleList = [];
      if (rawSchedule is List<BusinessDayModel>) {
        scheduleList = rawSchedule;
      } else if (rawSchedule is List) {
        scheduleList = rawSchedule.cast<BusinessDayModel>();
      }

      emit(BusinessHoursLoaded(
        schedule: scheduleList,
        isEmergencyClosed: data['isEmergencyClosed'] == true,
      ));
    } catch (e) {
      if (state is! BusinessHoursLoaded) {
        emit(BusinessHoursError('Failed to load schedule: $e'));
      }
    }
  }

  void _onBusinessHoursUpdatedStream(
    BusinessHoursUpdatedStreamEvent event,
    Emitter<BusinessHoursState> emit,
  ) {
    if (state is BusinessHoursLoaded) {
      final current = state as BusinessHoursLoaded;
      emit(current.copyWith(
        schedule: event.schedule,
        isEmergencyClosed: event.isEmergencyClosed,
      ));
    } else {
      emit(BusinessHoursLoaded(
        schedule: event.schedule,
        isEmergencyClosed: event.isEmergencyClosed,
      ));
    }
  }

  Future<void> _onUpdateBusinessDay(UpdateBusinessDayEvent event, Emitter<BusinessHoursState> emit) async {
    final currentState = state;
    if (currentState is! BusinessHoursLoaded) return;

    emit(currentState.copyWith(isUpdating: true, clearMessages: true));

    try {
      final targetSellerId = _getEffectiveSellerId();
      await repository.updateDay(targetSellerId, event.updatedDay);
      
      final newSchedule = currentState.schedule.map((day) {
        if (day.dayOfWeek.trim().toLowerCase() == event.updatedDay.dayOfWeek.trim().toLowerCase()) {
          return event.updatedDay;
        }
        return day;
      }).toList();

      emit(currentState.copyWith(
        schedule: newSchedule,
        isUpdating: false,
        successMessage: '${event.updatedDay.dayOfWeek} schedule updated.',
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
      final targetSellerId = _getEffectiveSellerId();
      await repository.toggleEmergencyClose(targetSellerId, event.isEmergencyClosed);
      
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

  Future<void> _onSaveFullBusinessHours(SaveFullBusinessHoursEvent event, Emitter<BusinessHoursState> emit) async {
    final currentState = state;
    if (currentState is! BusinessHoursLoaded) return;

    emit(currentState.copyWith(isUpdating: true, clearMessages: true));

    try {
      final targetSellerId = _getEffectiveSellerId();
      final emergencyClosed = event.isEmergencyClosed ?? currentState.isEmergencyClosed;
      await repository.saveFullSchedule(
        targetSellerId,
        event.schedule,
        isEmergencyClosed: emergencyClosed,
      );

      emit(currentState.copyWith(
        schedule: event.schedule,
        isEmergencyClosed: emergencyClosed,
        isUpdating: false,
        successMessage: 'Full weekly schedule successfully synchronized.',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to synchronize schedule: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _scheduleSubscription?.cancel();
    return super.close();
  }
}

