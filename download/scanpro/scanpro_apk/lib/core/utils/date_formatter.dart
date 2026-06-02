import 'package:intl/intl.dart';

/// Centralised date formatting utilities for ScanPro.
///
/// All formatters are stateless and can be called from anywhere
/// without needing a [BuildContext].
class DateFormatter {
  DateFormatter._();

  // ── Pre-configured formatters (cached for performance) ──────────

  static final DateFormat _displayDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayTime = DateFormat('hh:mm a');
  static final DateFormat _displayDateTime = DateFormat('MMM dd, yyyy hh:mm a');
  static final DateFormat _fileDate = DateFormat('yyyy-MM-dd_HH-mm-ss');
  static final DateFormat _syncDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
  static final DateFormat _shortDate = DateFormat('MMM dd');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _dayMonthYear = DateFormat('dd MMM yyyy');
  static final DateFormat _fullDate = DateFormat('EEEE, MMMM dd, yyyy');
  static final DateFormat _relativeAnchor = DateFormat('yyyy-MM-dd');

  // ── Display Formatters ──────────────────────────────────────────

  /// Formats a [DateTime] as **"Jan 15, 2025"**.
  static String displayDate(DateTime date) => _displayDate.format(date);

  /// Formats a [DateTime] as **"02:30 PM"**.
  static String displayTime(DateTime date) => _displayTime.format(date);

  /// Formats a [DateTime] as **"Jan 15, 2025 02:30 PM"**.
  static String displayDateTime(DateTime date) =>
      _displayDateTime.format(date);

  /// Formats a [DateTime] as **"Jan 15"** (no year).
  static String shortDate(DateTime date) => _shortDate.format(date);

  /// Formats a [DateTime] as **"January 2025"**.
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// Formats a [DateTime] as **"15 Jan 2025"**.
  static String dayMonthYear(DateTime date) => _dayMonthYear.format(date);

  /// Formats a [DateTime] as **"Wednesday, January 15, 2025"**.
  static String fullDate(DateTime date) => _fullDate.format(date);

  // ── File / Sync Formatters ──────────────────────────────────────

  /// Formats a [DateTime] for safe use in file names: **"2025-01-15_14-30-00"**.
  static String fileDate(DateTime date) => _fileDate.format(date);

  /// Formats a [DateTime] for API / sync timestamps (ISO-8601 with Z).
  static String syncDate(DateTime date) => _syncDate.format(date.toUtc());

  // ── Relative Time ───────────────────────────────────────────────

  /// Returns a human-readable relative time string.
  ///
  /// Examples:
  /// - "Just now"
  /// - "5 min ago"
  /// - "2 hours ago"
  /// - "Yesterday"
  /// - "3 days ago"
  /// - "Jan 15, 2025"  (falls back to absolute date for older dates)
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    if (difference.inDays < 365) {
      return shortDate(date);
    }

    return displayDate(date);
  }

  /// Returns a relative time string optimised for chat / activity feeds.
  ///
  /// - Today → "2:30 PM"
  /// - Yesterday → "Yesterday"
  /// - This week → day name ("Monday")
  /// - Older → "Jan 15" or "Jan 15, 2024"
  static String smartRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return displayTime(date);
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    if (date.year == now.year) return shortDate(date);
    return displayDate(date);
  }

  // ── Document-Specific Formatters ────────────────────────────────

  /// Formats the date for a document card / list tile.
  ///
  /// Shows relative time for recent documents and a full date for older ones.
  static String documentDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) return relativeTime(date);
    if (difference.inDays < 7) return smartRelative(date);
    return displayDate(date);
  }

  /// Formats a date for the file naming convention.
  ///
  /// Example: **"ScanPro_2025-01-15_14-30-00.pdf"**
  static String generateFileName({String? prefix, String? extension}) {
    final now = DateTime.now();
    final name = '${prefix ?? 'ScanPro'}_${fileDate(now)}';
    return '$name${extension ?? '.pdf'}';
  }

  // ── Parsing ─────────────────────────────────────────────────────

  /// Parses an ISO-8601 date string, returning `null` on failure.
  static DateTime? tryParse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }

  /// Parses an ISO-8601 date string, returning [fallback] on failure.
  static DateTime parseOr(String? dateStr, {required DateTime fallback}) {
    return tryParse(dateStr) ?? fallback;
  }

  // ── Utility ─────────────────────────────────────────────────────

  /// Whether two [DateTime]s fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Whether [date] is today.
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Whether [date] was yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Returns the start of the day (midnight) for [date].
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Returns the end of the day (23:59:59.999) for [date].
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  /// Returns the first day of the month containing [date].
  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  /// Returns the last day of the month containing [date].
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = date.month == 12
        ? DateTime(date.year + 1, 1)
        : DateTime(date.year, date.month + 1);
    return nextMonth.subtract(const Duration(milliseconds: 1));
  }

  /// Returns the number of calendar days between [start] and [end].
  static int daysBetween(DateTime start, DateTime end) {
    final s = startOfDay(start);
    final e = startOfDay(end);
    return e.difference(s).inDays.abs();
  }

  /// Formats a duration as a human-readable string (e.g. "1h 30m").
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
