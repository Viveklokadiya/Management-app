import 'package:flutter_test/flutter_test.dart';
import 'package:shree_giriraj_management/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    final testDate = DateTime(2026, 3, 17, 20, 30);

    test('toDisplayDate formats correctly', () {
      expect(DateFormatter.toDisplayDate(testDate), equals('17 Mar 2026'));
    });

    test('toDisplayDateTime formats correctly', () {
      final result = DateFormatter.toDisplayDateTime(testDate);
      expect(result, contains('17 Mar 2026'));
      expect(result, contains('08:30 PM'));
    });

    test('toShortDate formats correctly', () {
      expect(DateFormatter.toShortDate(testDate), equals('17 Mar'));
    });

    test('toMonthYear formats correctly', () {
      expect(DateFormatter.toMonthYear(testDate), equals('Mar 2026'));
    });

    test('toApiDate formats correctly', () {
      expect(DateFormatter.toApiDate(testDate), equals('2026-03-17'));
    });

    test('toTimeOnly formats correctly', () {
      expect(DateFormatter.toTimeOnly(testDate), equals('08:30 PM'));
    });

    test('isToday returns true for DateTime.now()', () {
      expect(DateFormatter.isToday(DateTime.now()), isTrue);
    });

    test('isToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.isToday(yesterday), isFalse);
    });

    test('isToday returns false for a date in 2025', () {
      final pastDate = DateTime(2025, 3, 17);
      expect(DateFormatter.isToday(pastDate), isFalse);
    });

    test('fromTimestamp returns null for null input', () {
      expect(DateFormatter.fromTimestamp(null), isNull);
    });

    test('fromTimestamp handles DateTime input directly', () {
      final result = DateFormatter.fromTimestamp(testDate);
      expect(result, equals(testDate));
    });

    test('toRelative shows "Just now" for current time', () {
      final now = DateTime.now();
      expect(DateFormatter.toRelative(now), equals('Just now'));
    });

    test('toRelative shows minutes ago', () {
      final fiveMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 5));
      expect(DateFormatter.toRelative(fiveMinutesAgo), equals('5m ago'));
    });

    test('toRelative shows hours ago', () {
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      expect(DateFormatter.toRelative(twoHoursAgo), contains('h ago'));
    });

    test('toRelative shows "Yesterday" for 1 day ago', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.toRelative(yesterday), equals('Yesterday'));
    });

    test('toRelative shows days ago for recent past', () {
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
      expect(DateFormatter.toRelative(fiveDaysAgo), contains('days ago'));
    });

    test('toRelative shows formatted date for old dates', () {
      final oldDate = DateTime(2025, 1, 1);
      final result = DateFormatter.toRelative(oldDate);
      expect(result, contains('2025'));
    });
  });
}
