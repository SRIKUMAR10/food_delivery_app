import 'package:cloud_firestore/cloud_firestore.dart';
import 'business_hours_page_model.dart';

class BusinessHoursService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchSchedule(String sellerId) async {
    try {
      final docSnapshot = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('settings')
          .doc('business_hours')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final scheduleList = (data['schedule'] as List<dynamic>?)?.map((s) {
          return BusinessDayModel(
            dayOfWeek: s['dayOfWeek'] ?? '',
            openTime: s['openTime'] ?? '',
            closeTime: s['closeTime'] ?? '',
            isOpen: s['isOpen'] ?? false,
          );
        }).toList();

        return {
          'isEmergencyClosed': data['isEmergencyClosed'] ?? false,
          'schedule': scheduleList ?? _getDefaultSchedule(),
        };
      }

      // Return default if document doesn't exist
      return {
        'isEmergencyClosed': false,
        'schedule': _getDefaultSchedule(),
      };
    } catch (e) {
      throw Exception('Failed to fetch schedule: $e');
    }
  }

  Future<void> updateSchedule(String sellerId, BusinessDayModel updatedDay) async {
    try {
      final docRef = _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('settings')
          .doc('business_hours');

      final doc = await docRef.get();
      List<dynamic> schedule = [];
      if (doc.exists && doc.data() != null && doc.data()!['schedule'] != null) {
        schedule = List.from(doc.data()!['schedule']);
      } else {
        schedule = _getDefaultSchedule().map((d) => _modelToMap(d)).toList();
      }

      final index = schedule.indexWhere((s) => s['dayOfWeek'] == updatedDay.dayOfWeek);
      if (index != -1) {
        schedule[index] = _modelToMap(updatedDay);
        await docRef.set({'schedule': schedule}, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  Future<void> toggleEmergencyClose(String sellerId, bool isEmergencyClosed) async {
    try {
      await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('settings')
          .doc('business_hours')
          .set({'isEmergencyClosed': isEmergencyClosed}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to toggle emergency close: $e');
    }
  }

  List<BusinessDayModel> _getDefaultSchedule() {
    return [
      BusinessDayModel(dayOfWeek: 'Monday', openTime: '09:00 AM', closeTime: '10:00 PM', isOpen: true),
      BusinessDayModel(dayOfWeek: 'Tuesday', openTime: '09:00 AM', closeTime: '10:00 PM', isOpen: true),
      BusinessDayModel(dayOfWeek: 'Wednesday', openTime: '09:00 AM', closeTime: '10:00 PM', isOpen: true),
      BusinessDayModel(dayOfWeek: 'Thursday', openTime: '09:00 AM', closeTime: '10:00 PM', isOpen: true),
      BusinessDayModel(dayOfWeek: 'Friday', openTime: '09:00 AM', closeTime: '11:00 PM', isOpen: true),
      BusinessDayModel(dayOfWeek: 'Saturday', openTime: '09:00 AM', closeTime: '11:00 PM', isOpen: true),
      BusinessDayModel(dayOfWeek: 'Sunday', openTime: '10:00 AM', closeTime: '09:00 PM', isOpen: false),
    ];
  }

  Map<String, dynamic> _modelToMap(BusinessDayModel model) {
    return {
      'dayOfWeek': model.dayOfWeek,
      'openTime': model.openTime,
      'closeTime': model.closeTime,
      'isOpen': model.isOpen,
    };
  }
}
