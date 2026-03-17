import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayDate = DateFormat('dd MMM yyyy');
  static final DateFormat _displayDateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _shortDate = DateFormat('dd MMM');
  static final DateFormat _timeOnly = DateFormat('hh:mm a');
  static final DateFormat _monthYear = DateFormat('MMM yyyy');
  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');

  /// Format: "17 Mar 2026"
  static String toDisplayDate(DateTime date) => _displayDate.format(date);

  /// Format: "17 Mar 2026, 08:30 PM"
  static String toDisplayDateTime(DateTime date) => _displayDateTime.format(date);

  /// Format: "17 Mar"
  static String toShortDate(DateTime date) => _shortDate.format(date);

  /// Format: "08:30 PM"
  static String toTimeOnly(DateTime date) => _timeOnly.format(date);

  /// Format: "Mar 2026"
  static String toMonthYear(DateTime date) => _monthYear.format(date);

  /// Format: "2026-03-17" (for Firestore queries)
  static String toApiDate(DateTime date) => _apiDate.format(date);

  /// Convert Firestore Timestamp to DateTime safely
  static DateTime? fromTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    try {
      if (timestamp is DateTime) return timestamp;
      return (timestamp as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }

  /// Relative time: "Just now", "5m ago", "2h ago", "Yesterday", "17 Mar 2026"
  static String toRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return toDisplayDate(date);
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
