/// DateTime extension methods for formatting and relative time display.
///
/// Provides consistent date formatting across the app and
/// human-readable relative time strings (e.g., "2 hours ago").
library;

extension DateExtensions on DateTime {
  // ── Absolute Formatting ───────────────────────────────────────

  /// Formats as "Jan 15, 2025".
  String toDateString() {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month]} $day, $year';
  }

  /// Formats as "Jan 15, 2025 at 3:45 PM".
  String toDateTimeString() {
    return '${toDateString()} at ${toTimeString()}';
  }

  /// Formats as "3:45 PM".
  String toTimeString() {
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $amPm';
  }

  /// Formats as "15/01/2025".
  String toShortDateString() {
    final dayStr = day.toString().padLeft(2, '0');
    final monthStr = month.toString().padLeft(2, '0');
    return '$dayStr/$monthStr/$year';
  }

  /// Formats as "2025-01-15" (ISO date only).
  String toIsoDateString() {
    final dayStr = day.toString().padLeft(2, '0');
    final monthStr = month.toString().padLeft(2, '0');
    return '$year-$monthStr-$dayStr';
  }

  /// Formats as "2025-01-15T15:45:00" (ISO-ish for file names).
  String toFileNameSafeString() {
    final dayStr = day.toString().padLeft(2, '0');
    final monthStr = month.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    final secondStr = second.toString().padLeft(2, '0');
    return '${year}_$monthStr\_$dayStr\_$hourStr$minuteStr$secondStr';
  }

  // ── Relative Time ─────────────────────────────────────────────

  /// Returns a human-readable relative time string (e.g., "2 hours ago").
  String timeAgo({DateTime? from}) {
    final reference = from ?? DateTime.now();
    final diff = reference.difference(this);

    if (diff.isNegative) return 'just now';

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return '$mins ${mins == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      final days = diff.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
    final years = (diff.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }

  // ── Date Comparisons ──────────────────────────────────────────

  /// Whether this date is the same calendar day as [other].
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Whether this date is today.
  bool get isToday => isSameDay(DateTime.now());

  /// Whether this date was yesterday.
  bool get isYesterday => isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Whether this date is in the current week.
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }

  /// Whether this date is in the current month.
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Whether this date is in the current year.
  bool get isThisYear => year == DateTime.now().year;

  /// Returns a copy with the time set to midnight (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns a copy with the time set to the end of the day (23:59:59).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}
