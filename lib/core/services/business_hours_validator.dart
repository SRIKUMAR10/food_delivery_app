import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessHoursValidator {
  final FirebaseFirestore _firestore;

  BusinessHoursValidator({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  Future<BusinessHoursResult> validateSeller(String sellerId) async {
    try {
      final doc = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('settings')
          .doc('business_hours')
          .get();

      if (!doc.exists) {
        return BusinessHoursResult(isOpen: true);
      }

      final data = doc.data()!;
      final isEmergencyClosed = data['isEmergencyClosed'] as bool? ?? false;
      if (isEmergencyClosed) {
        return BusinessHoursResult(
          isOpen: false,
          message: 'Store is temporarily closed.',
        );
      }

      final schedule = (data['schedule'] as List<dynamic>?) ?? [];
      if (schedule.isEmpty) {
        return BusinessHoursResult(isOpen: true);
      }

      final now = DateTime.now();
      final currentDayName = _daysOfWeek[now.weekday - 1];
      final currentMinutes = now.hour * 60 + now.minute;

      for (final entry in schedule) {
        final dayName = entry['dayOfWeek'] as String? ?? '';
        if (dayName.toLowerCase() != currentDayName.toLowerCase()) continue;

        final isOpen = entry['isOpen'] as bool? ?? true;
        if (!isOpen) {
          final nextOpen = _findNextOpening(schedule, now, currentDayName);
          return BusinessHoursResult(
            isOpen: false,
            message: nextOpen,
          );
        }

        final openTimeStr = entry['openTime'] as String? ?? '09:00 AM';
        final closeTimeStr = entry['closeTime'] as String? ?? '10:00 PM';

        final openMinutes = _parseTime(openTimeStr);
        final closeMinutes = _parseTime(closeTimeStr);

        if (openMinutes == null || closeMinutes == null) {
          return BusinessHoursResult(isOpen: true);
        }

        if (closeMinutes < openMinutes) {
          if (currentMinutes >= openMinutes || currentMinutes < closeMinutes) {
            return BusinessHoursResult(isOpen: true);
          }
        } else if (currentMinutes >= openMinutes && currentMinutes < closeMinutes) {
          return BusinessHoursResult(isOpen: true);
        }

        final nextOpen = _findNextOpening(schedule, now, currentDayName);
        return BusinessHoursResult(
          isOpen: false,
          message: nextOpen,
        );
      }

      return BusinessHoursResult(isOpen: true);
    } catch (e) {
      return BusinessHoursResult(isOpen: true);
    }
  }

  String _findNextOpening(List<dynamic> schedule, DateTime now, String currentDayName) {
    for (int i = 0; i < 7; i++) {
      final checkDate = now.add(Duration(days: i));
      final checkDayName = _daysOfWeek[checkDate.weekday - 1];

      for (final entry in schedule) {
        final dayName = entry['dayOfWeek'] as String? ?? '';
        if (dayName.toLowerCase() != checkDayName.toLowerCase()) continue;
        final isOpen = entry['isOpen'] as bool? ?? true;
        if (!isOpen) continue;

        final openTimeStr = entry['openTime'] as String? ?? '09:00 AM';
        final openMinutes = _parseTime(openTimeStr);
        if (openMinutes == null) continue;

        if (i == 0) {
          final currentMinutes = now.hour * 60 + now.minute;
          if (openMinutes <= currentMinutes) continue;
        }

        final hour = openMinutes ~/ 60;
        final minute = openMinutes % 60;
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final timeStr = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

        if (i == 0) return 'Opens today at $timeStr';
        if (i == 1) return 'Opens tomorrow at $timeStr';
        return 'Opens $checkDayName at $timeStr';
      }
    }

    return 'Store is currently closed.';
  }

  int? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length != 2) return null;
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final period = parts[1].toUpperCase();

      int militaryHour = hour;
      if (period == 'PM' && hour != 12) militaryHour = hour + 12;
      if (period == 'AM' && hour == 12) militaryHour = 0;

      return militaryHour * 60 + minute;
    } catch (_) {
      return null;
    }
  }
}

class BusinessHoursResult {
  final bool isOpen;
  final String? message;

  const BusinessHoursResult({required this.isOpen, this.message});
}
