import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Centralized Date & Time Formatter Utility for the application.
/// Provides uniform system date (YYYY-MM-DD), standard display date (dd MMM, yyyy),
/// standard date & time (dd MMM, yyyy • hh:mm a), and time-only (hh:mm a) formats.
class AppDateFormatter {
  AppDateFormatter._();

  /// System date format: 'yyyy-MM-dd' (e.g., '2026-08-30')
  static final DateFormat _systemDateFormat = DateFormat('yyyy-MM-dd');

  /// Standard display date format: 'dd MMM, yyyy' (e.g., '30 Aug, 2026')
  static final DateFormat _displayDateFormat = DateFormat('dd MMM, yyyy');

  /// Standard display date & time format: 'dd MMM, yyyy • hh:mm a' (e.g., '30 Aug, 2026 • 03:55 AM')
  static final DateFormat _displayDateTimeFormat = DateFormat('dd MMM, yyyy • hh:mm a');

  /// Standard display date & time with comma: 'dd MMM, yyyy, hh:mm a' (e.g., '30 Aug, 2026, 03:55 AM')
  static final DateFormat _displayDateTimeCommaFormat = DateFormat('dd MMM, yyyy, hh:mm a');

  /// Standard 12-hour time format: 'hh:mm a' (e.g., '03:55 AM')
  static final DateFormat _time12HourFormat = DateFormat('hh:mm a');

  /// Standard 24-hour time format: 'HH:mm' (e.g., '15:55')
  static final DateFormat _time24HourFormat = DateFormat('HH:mm');

  /// Short month & day format: 'dd MMM' (e.g., '30 Aug')
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');

  /// Month & year format: 'MMM yyyy' (e.g., 'Aug 2026')
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');

  /// Safely parses [value] into a [DateTime] object.
  /// Supports [DateTime], [Timestamp], [int] (milliseconds or seconds epoch), and [String].
  static DateTime? parseToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) {
      // If epoch is in seconds (10 digits), multiply by 1000
      if (value < 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return DateTime.tryParse(trimmed);
    }
    return null;
  }

  /// Formats date to system format 'yyyy-MM-dd' (e.g. '2026-08-30').
  /// Returns empty string if parsing fails or input is null.
  static String formatSystemDate(dynamic value) {
    final dt = parseToDateTime(value);
    if (dt == null) return '';
    return _systemDateFormat.format(dt.toLocal());
  }

  /// Formats date to display format 'dd MMM, yyyy' (e.g. '30 Aug, 2026').
  /// Returns empty string if parsing fails or input is null.
  static String formatDisplayDate(dynamic value) {
    final dt = parseToDateTime(value);
    if (dt == null) return '';
    return _displayDateFormat.format(dt.toLocal());
  }

  /// Formats date and time to 'dd MMM, yyyy • hh:mm a' (e.g. '30 Aug, 2026 • 03:55 AM').
  /// Returns empty string if parsing fails or input is null.
  static String formatDisplayDateTime(dynamic value) {
    final dt = parseToDateTime(value);
    if (dt == null) return '';
    return _displayDateTimeFormat.format(dt.toLocal());
  }

  /// Formats date and time with comma 'dd MMM, yyyy, hh:mm a' (e.g. '30 Aug, 2026, 03:55 AM').
  /// Returns empty string if parsing fails or input is null.
  static String formatDisplayDateTimeWithComma(dynamic value) {
    final dt = parseToDateTime(value);
    if (dt == null) return '';
    return _displayDateTimeCommaFormat.format(dt.toLocal());
  }

  /// Formats time only to 'hh:mm a' (e.g. '03:55 AM').
  /// Returns empty string if parsing fails or input is null.
  static String formatTime(dynamic value) {
    final dt = parseToDateTime(value);
    if (dt == null) return '';
    return _time12HourFormat.format(dt.toLocal());
  }

  /// Formats time in 24-hour format 'HH:mm' (e.g. '15:55').
  static String formatTime24(dynamic value) {
    final dt = parseToDateTime(value);
    if (dt == null) return '';
    return _time24HourFormat.format(dt.toLocal());
  }

  /// Formats short date to 'dd MMM' (e.g. '30 Aug').
  static String formatShortDate(dynamic value) {
    final dt = parseToDateTime(value);
    if (dt == null) return '';
    return _shortDateFormat.format(dt.toLocal());
  }

  /// Formats month and year to 'MMM yyyy' (e.g. 'Aug 2026').
  static String formatMonthYear(dynamic value) {
    final dt = parseToDateTime(value);
    if (dt == null) return '';
    return _monthYearFormat.format(dt.toLocal());
  }

  /// Formats a date range e.g. '30 Aug, 2026 - 05 Sep, 2026'.
  static String formatDateRange(dynamic start, dynamic end) {
    final dtStart = parseToDateTime(start);
    final dtEnd = parseToDateTime(end);
    if (dtStart == null && dtEnd == null) return '';
    if (dtStart != null && dtEnd == null) return formatDisplayDate(dtStart);
    if (dtStart == null && dtEnd != null) return formatDisplayDate(dtEnd);
    return '${formatDisplayDate(dtStart)} - ${formatDisplayDate(dtEnd)}';
  }

  /// Relative human-readable time e.g. "Just now", "5m ago", "2h ago", "3d ago", or 'dd MMM, yyyy'.
  static String formatTimeAgo(dynamic value) {
    final dt = parseToDateTime(value);
    if (dt == null) return '';
    final now = DateTime.now();
    final local = dt.toLocal();
    final diff = now.difference(local);

    if (diff.inSeconds < 60 && diff.inSeconds >= 0) return 'Just now';
    if (diff.inMinutes < 60 && diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24 && diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inDays < 7 && diff.inDays > 0) return '${diff.inDays}d ago';
    return formatDisplayDate(local);
  }
}
