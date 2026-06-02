/// Date formatting utility helpers for ScanPro.
///
/// Provides static methods for common date formatting operations
/// that don't belong as extensions (e.g., when working with
/// timestamps or needing locale-aware formatting).
library;

import '../extensions/date_extensions.dart';

/// Utility class for date formatting operations.
class DateUtils {
  DateUtils._();

  /// Formats a [DateTime] as a relative time string (e.g., "2 hours ago").
  ///
  /// Delegates to the [DateExtensions.timeAgo] extension method.
  static String timeAgo(DateTime date, {DateTime? from}) {
    return date.timeAgo(from: from);
  }

  /// Formats a [DateTime] as "Jan 15, 2025".
  static String toDateString(DateTime date) => date.toDateString();

  /// Formats a [DateTime] as "Jan 15, 2025 at 3:45 PM".
  static String toDateTimeString(DateTime date) => date.toDateTimeString();

  /// Formats a [DateTime] as "3:45 PM".
  static String toTimeString(DateTime date) => date.toTimeString();

  /// Formats a [DateTime] as "15/01/2025".
  static String toShortDateString(DateTime date) => date.toShortDateString();

  /// Formats a [DateTime] as "2025-01-15" (ISO date).
  static String toIsoDateString(DateTime date) => date.toIsoDateString();

  /// Formats a [DateTime] as a file-name-safe string "2025_01_15_154500".
  static String toFileNameSafe(DateTime date) => date.toFileNameSafeString();

  /// Returns a smart date label based on recency.
  ///
  /// - "Today" for today
  /// - "Yesterday" for yesterday
  /// - Relative time for dates within the last week
  /// - "Jan 15, 2025" for older dates
  static String smartLabel(DateTime date) {
    if (date.isToday) return 'Today';
    if (date.isYesterday) return 'Yesterday';
    if (date.isThisWeek) return date.timeAgo();
    return date.toDateString();
  }

  /// Returns a grouping label for list section headers.
  ///
  /// - "Today"
  /// - "Yesterday"
  /// - "This Week"
  /// - "This Month"
  /// - "January 2025"
  static String groupLabel(DateTime date) {
    if (date.isToday) return 'Today';
    if (date.isYesterday) return 'Yesterday';
    if (date.isThisWeek) return 'This Week';
    if (date.isThisMonth) return 'This Month';
    return _monthYear(date);
  }

  /// Formats a [DateTime] as "January 2025".
  static String _monthYear(DateTime date) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month]} ${date.year}';
  }

  /// Parses an ISO 8601 date string, returning null on failure.
  static DateTime? tryParseIso(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    return DateTime.tryParse(isoString);
  }

  /// Parses a milliseconds-since-epoch timestamp into a [DateTime].
  static DateTime fromMilliseconds(int milliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  /// Returns the current timestamp in milliseconds since epoch.
  static int currentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Returns the start of the current day.
  static DateTime today() {
    return DateTime.now().startOfDay;
  }

  /// Returns a [DateTime] representing [daysAgo] days in the past.
  static DateTime daysAgo(int days) {
    return DateTime.now().subtract(Duration(days: days));
  }

  /// Formats a duration as "1h 23m" or "45s".
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }
}
