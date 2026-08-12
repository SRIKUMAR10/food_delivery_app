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
        return _mapScheduleData(docSnapshot.data()!);
      }

      return {
        'isEmergencyClosed': false,
        'schedule': <BusinessDayModel>[],
      };
    } catch (e) {
      throw Exception('Failed to fetch schedule: $e');
    }
  }

  Stream<Map<String, dynamic>> watchSchedule(String sellerId) {
    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('settings')
        .doc('business_hours')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return _mapScheduleData(snapshot.data()!);
      }
      return {
        'isEmergencyClosed': false,
        'schedule': <BusinessDayModel>[],
      };
    });
  }

  Map<String, dynamic> _mapScheduleData(Map<String, dynamic> data) {
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
      'schedule': scheduleList ?? <BusinessDayModel>[],
    };
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

  Map<String, dynamic> _modelToMap(BusinessDayModel model) {
    return {
      'dayOfWeek': model.dayOfWeek,
      'openTime': model.openTime,
      'closeTime': model.closeTime,
      'isOpen': model.isOpen,
    };
  }
}
