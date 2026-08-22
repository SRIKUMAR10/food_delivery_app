import 'package:cloud_firestore/cloud_firestore.dart';
import 'business_hours_page_model.dart';

class BusinessHoursService {
  final FirebaseFirestore _firestore;

  BusinessHoursService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static List<BusinessDayModel> defaultSchedule() {
    return BusinessDayModel.defaultWeeklySchedule();
  }

  Future<Map<String, dynamic>> fetchSchedule(String sellerId) async {
    try {
      if (sellerId.isEmpty) {
        return {
          'isEmergencyClosed': false,
          'schedule': defaultSchedule(),
        };
      }

      final docSnapshot = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('settings')
          .doc('business_hours')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final mapped = _mapScheduleData(docSnapshot.data()!);
        final schedule = mapped['schedule'] as List<BusinessDayModel>;
        if (schedule.isNotEmpty) {
          return mapped;
        }
      }

      final defaultList = defaultSchedule();
      final initialData = {
        'isEmergencyClosed': false,
        'schedule': defaultList.map((d) => d.toMap()).toList(),
      };

      try {
        await _firestore
            .collection('sellers')
            .doc(sellerId)
            .collection('settings')
            .doc('business_hours')
            .set(initialData, SetOptions(merge: true));
      } catch (_) {}

      return {
        'isEmergencyClosed': false,
        'schedule': defaultList,
      };
    } catch (e) {
      throw Exception('Failed to fetch schedule: $e');
    }
  }

  Stream<Map<String, dynamic>> watchSchedule(String sellerId) {
    if (sellerId.isEmpty) {
      return Stream.value({
        'isEmergencyClosed': false,
        'schedule': defaultSchedule(),
      });
    }

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
        'schedule': defaultSchedule(),
      };
    });
  }

  Map<String, dynamic> _mapScheduleData(Map<String, dynamic> data) {
    final rawList = data['schedule'] as List<dynamic>?;
    List<BusinessDayModel> scheduleList = [];

    if (rawList != null && rawList.isNotEmpty) {
      scheduleList = rawList.map((s) {
        if (s is Map<String, dynamic>) {
          return BusinessDayModel.fromMap(s);
        } else if (s is Map) {
          return BusinessDayModel.fromMap(Map<String, dynamic>.from(s));
        }
        return BusinessDayModel(
          dayOfWeek: s['dayOfWeek']?.toString() ?? '',
          openTime: s['openTime']?.toString() ?? '09:00 AM',
          closeTime: s['closeTime']?.toString() ?? '10:00 PM',
          isOpen: s['isOpen'] == true,
        );
      }).toList();
    }

    if (scheduleList.length < 7) {
      final existingDaysMap = {
        for (var d in scheduleList) d.dayOfWeek.trim().toLowerCase(): d
      };
      final completeSchedule = <BusinessDayModel>[];
      for (final day in daysOfWeek) {
        final key = day.toLowerCase();
        if (existingDaysMap.containsKey(key)) {
          completeSchedule.add(existingDaysMap[key]!);
        } else {
          completeSchedule.add(BusinessDayModel(
            dayOfWeek: day,
            openTime: '09:00 AM',
            closeTime: '10:00 PM',
            isOpen: true,
          ));
        }
      }
      scheduleList = completeSchedule;
    }

    return {
      'isEmergencyClosed': data['isEmergencyClosed'] == true,
      'schedule': scheduleList,
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

      if (schedule.isEmpty) {
        schedule = defaultSchedule().map((d) => d.toMap()).toList();
      }

      final index = schedule.indexWhere((s) =>
          s['dayOfWeek'].toString().trim().toLowerCase() ==
          updatedDay.dayOfWeek.trim().toLowerCase());

      if (index != -1) {
        schedule[index] = updatedDay.toMap();
      } else {
        schedule.add(updatedDay.toMap());
      }

      await docRef.set({'schedule': schedule}, SetOptions(merge: true));
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
}

