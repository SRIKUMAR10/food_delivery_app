// Real-Time Firestore Stream Provider Standardized
import 'business_hours_page_model.dart';
import 'business_hours_page_service.dart';

class BusinessHoursRepository {
  final BusinessHoursService service;

  BusinessHoursRepository({required this.service});

  Stream<Map<String, dynamic>> watchSchedule(String sellerId) {
    return service.watchSchedule(sellerId);
  }

  Future<Map<String, dynamic>> getSchedule(String sellerId) {
    return service.fetchSchedule(sellerId);
  }

  Future<void> updateDay(String sellerId, BusinessDayModel day) {
    return service.updateSchedule(sellerId, day);
  }

  Future<void> toggleEmergencyClose(String sellerId, bool isEmergencyClosed) {
    return service.toggleEmergencyClose(sellerId, isEmergencyClosed);
  }

  Future<void> saveFullSchedule(
    String sellerId,
    List<BusinessDayModel> schedule, {
    bool isEmergencyClosed = false,
  }) {
    return service.saveFullSchedule(
      sellerId,
      schedule,
      isEmergencyClosed: isEmergencyClosed,
    );
  }
}
