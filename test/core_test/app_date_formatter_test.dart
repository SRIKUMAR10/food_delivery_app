import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/utils/app_date_formatter.dart';

void main() {
  group('AppDateFormatter Unit Tests', () {
    final testDate = DateTime(2026, 8, 30, 15, 45); // 30 Aug 2026, 03:45 PM

    test('formatSystemDate correctly formats to yyyy-MM-dd', () {
      expect(AppDateFormatter.formatSystemDate(testDate), '2026-08-30');
      expect(AppDateFormatter.formatSystemDate(null), '');
      expect(AppDateFormatter.formatSystemDate('2026-08-30T15:45:00.000Z'), isNotEmpty);
    });

    test('formatDisplayDate correctly formats to dd MMM, yyyy', () {
      expect(AppDateFormatter.formatDisplayDate(testDate), '30 Aug, 2026');
      expect(AppDateFormatter.formatDisplayDate(null), '');
    });

    test('formatDisplayDateTime correctly formats to dd MMM, yyyy • hh:mm a', () {
      expect(AppDateFormatter.formatDisplayDateTime(testDate), '30 Aug, 2026 • 03:45 PM');
      expect(AppDateFormatter.formatDisplayDateTime(null), '');
    });

    test('formatDisplayDateTimeWithComma correctly formats to dd MMM, yyyy, hh:mm a', () {
      expect(AppDateFormatter.formatDisplayDateTimeWithComma(testDate), '30 Aug, 2026, 03:45 PM');
      expect(AppDateFormatter.formatDisplayDateTimeWithComma(null), '');
    });

    test('formatTime correctly formats to hh:mm a', () {
      expect(AppDateFormatter.formatTime(testDate), '03:45 PM');
      expect(AppDateFormatter.formatTime(null), '');
    });

    test('formatTime24 correctly formats to HH:mm', () {
      expect(AppDateFormatter.formatTime24(testDate), '15:45');
      expect(AppDateFormatter.formatTime24(null), '');
    });

    test('formatShortDate correctly formats to dd MMM', () {
      expect(AppDateFormatter.formatShortDate(testDate), '30 Aug');
      expect(AppDateFormatter.formatShortDate(null), '');
    });

    test('formatMonthYear correctly formats to MMM yyyy', () {
      expect(AppDateFormatter.formatMonthYear(testDate), 'Aug 2026');
      expect(AppDateFormatter.formatMonthYear(null), '');
    });

    test('formatDateRange correctly formats date range', () {
      final endDate = DateTime(2026, 9, 5);
      expect(
        AppDateFormatter.formatDateRange(testDate, endDate),
        '30 Aug, 2026 - 05 Sep, 2026',
      );
      expect(AppDateFormatter.formatDateRange(testDate, null), '30 Aug, 2026');
      expect(AppDateFormatter.formatDateRange(null, null), '');
    });

    test('parseToDateTime correctly parses various formats', () {
      // DateTime
      expect(AppDateFormatter.parseToDateTime(testDate), testDate);

      // Firestore Timestamp
      final ts = Timestamp.fromDate(testDate);
      expect(AppDateFormatter.parseToDateTime(ts), testDate);

      // Epoch millis
      expect(
        AppDateFormatter.parseToDateTime(testDate.millisecondsSinceEpoch),
        testDate,
      );

      // ISO String
      expect(
        AppDateFormatter.parseToDateTime('2026-08-30T15:45:00.000'),
        DateTime(2026, 8, 30, 15, 45),
      );

      // Invalid / null
      expect(AppDateFormatter.parseToDateTime(null), isNull);
      expect(AppDateFormatter.parseToDateTime(''), isNull);
      expect(AppDateFormatter.parseToDateTime('invalid-date'), isNull);
    });

    test('formatTimeAgo returns relative or formatted date', () {
      final now = DateTime.now();
      expect(AppDateFormatter.formatTimeAgo(now), 'Just now');
      expect(
        AppDateFormatter.formatTimeAgo(now.subtract(const Duration(minutes: 5))),
        '5m ago',
      );
      expect(
        AppDateFormatter.formatTimeAgo(now.subtract(const Duration(hours: 3))),
        '3h ago',
      );
      expect(
        AppDateFormatter.formatTimeAgo(now.subtract(const Duration(days: 2))),
        '2d ago',
      );
      final oldDate = now.subtract(const Duration(days: 20));
      expect(AppDateFormatter.formatTimeAgo(oldDate), AppDateFormatter.formatDisplayDate(oldDate));
    });
  });
}
