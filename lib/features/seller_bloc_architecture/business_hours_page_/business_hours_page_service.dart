import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'business_hours_page_model.dart';

class BusinessHoursService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BusinessHoursService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

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

  String _resolveSellerId(String sellerId) {
    if (sellerId.trim().isNotEmpty) {
      return sellerId.trim();
    }
    return _auth.currentUser?.uid ?? '';
  }

  Future<Map<String, dynamic>> fetchSchedule(String sellerId) async {
    try {
      final targetSellerId = _resolveSellerId(sellerId);
      if (targetSellerId.isEmpty) {
        return {
          'isEmergencyClosed': false,
          'schedule': defaultSchedule(),
        };
      }

      final docSnapshot = await _firestore
          .collection('sellers')
          .doc(targetSellerId)
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

      // Check root seller document fallback if settings subcollection is empty
      final sellerDoc = await _firestore.collection('sellers').doc(targetSellerId).get();
      if (sellerDoc.exists && sellerDoc.data() != null) {
        final rootData = sellerDoc.data()!;
        if (rootData['businessHours'] is Map<String, dynamic>) {
          final mapped = _mapScheduleData(rootData['businessHours'] as Map<String, dynamic>);
          if ((mapped['schedule'] as List<BusinessDayModel>).isNotEmpty) {
            return mapped;
          }
        }
      }

      final defaultList = defaultSchedule();
      final initialData = {
        'isEmergencyClosed': false,
        'isOpen': true,
        'schedule': defaultList.map((d) => d.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore
            .collection('sellers')
            .doc(targetSellerId)
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
    final targetSellerId = _resolveSellerId(sellerId);
    if (targetSellerId.isEmpty) {
      return Stream.value({
        'isEmergencyClosed': false,
        'schedule': defaultSchedule(),
      });
    }

    return _firestore
        .collection('sellers')
        .doc(targetSellerId)
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

    final isEmergencyClosed = data['isEmergencyClosed'] == true || data['isOpen'] == false;

    return {
      'isEmergencyClosed': isEmergencyClosed,
      'schedule': scheduleList,
    };
  }

  Future<void> updateSchedule(String sellerId, BusinessDayModel updatedDay) async {
    try {
      final targetSellerId = _resolveSellerId(sellerId);
      if (targetSellerId.isEmpty) return;

      final docRef = _firestore
          .collection('sellers')
          .doc(targetSellerId)
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

      // 1. Update settings/business_hours subcollection document
      await docRef.set({
        'schedule': schedule,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Coordinated sync with root seller document
      final weeklyHolidays = <String>[];
      String? primaryOpen;
      String? primaryClose;

      for (final item in schedule) {
        final dayName = item['dayOfWeek']?.toString() ?? '';
        final isOpen = item['isOpen'] == true;
        if (!isOpen && dayName.isNotEmpty) {
          weeklyHolidays.add(dayName);
        } else if (isOpen && primaryOpen == null) {
          primaryOpen = item['openTime']?.toString();
          primaryClose = item['closeTime']?.toString();
        }
      }

      final rootSellerRef = _firestore.collection('sellers').doc(targetSellerId);
      await rootSellerRef.set({
        'weeklyHoliday': weeklyHolidays,
        'isBusinessHoursCompleted': true,
        if (primaryOpen != null) 'openingHours': primaryOpen,
        if (primaryClose != null) 'closingTime': primaryClose,
        'businessHours': {
          'schedule': schedule,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  Future<void> saveFullSchedule(
    String sellerId,
    List<BusinessDayModel> scheduleList, {
    bool isEmergencyClosed = false,
  }) async {
    try {
      final targetSellerId = _resolveSellerId(sellerId);
      if (targetSellerId.isEmpty) return;

      final serializedSchedule = scheduleList.map((d) => d.toMap()).toList();

      final docRef = _firestore
          .collection('sellers')
          .doc(targetSellerId)
          .collection('settings')
          .doc('business_hours');

      await docRef.set({
        'schedule': serializedSchedule,
        'isEmergencyClosed': isEmergencyClosed,
        'isOpen': !isEmergencyClosed,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final weeklyHolidays = scheduleList
          .where((d) => !d.isOpen)
          .map((d) => d.dayOfWeek)
          .toList();

      final firstOpenDay = scheduleList.firstWhere(
        (d) => d.isOpen,
        orElse: () => scheduleList.first,
      );

      final rootSellerRef = _firestore.collection('sellers').doc(targetSellerId);
      await rootSellerRef.set({
        'weeklyHoliday': weeklyHolidays,
        'isBusinessHoursCompleted': true,
        'openingHours': firstOpenDay.openTime,
        'closingTime': firstOpenDay.closeTime,
        'isOpen': !isEmergencyClosed,
        'isAcceptingOrders': !isEmergencyClosed,
        'businessHours': {
          'schedule': serializedSchedule,
          'isEmergencyClosed': isEmergencyClosed,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save full schedule: $e');
    }
  }

  Future<void> toggleEmergencyClose(String sellerId, bool isEmergencyClosed) async {
    try {
      final targetSellerId = _resolveSellerId(sellerId);
      if (targetSellerId.isEmpty) return;

      // 1. Update settings/business_hours
      await _firestore
          .collection('sellers')
          .doc(targetSellerId)
          .collection('settings')
          .doc('business_hours')
          .set({
        'isEmergencyClosed': isEmergencyClosed,
        'isOpen': !isEmergencyClosed,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Update root sellers document
      await _firestore.collection('sellers').doc(targetSellerId).set({
        'isOpen': !isEmergencyClosed,
        'isAcceptingOrders': !isEmergencyClosed,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to toggle emergency close: $e');
    }
  }
}

