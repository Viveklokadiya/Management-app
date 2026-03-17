import 'package:flutter_test/flutter_test.dart';
import 'package:shree_giriraj_management/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    group('format', () {
      test('formats zero correctly', () {
        final result = CurrencyFormatter.format(0);
        expect(result, contains('₹'));
        expect(result, contains('0'));
      });

      test('formats hundreds correctly', () {
        final result = CurrencyFormatter.format(500);
        expect(result, startsWith('₹'));
        expect(result, contains('500'));
      });

      test('formats thousands with comma', () {
        final result = CurrencyFormatter.format(1000);
        expect(result, startsWith('₹'));
        expect(result, contains('1,000'));
      });

      test('formats amount starting with rupee symbol', () {
        expect(CurrencyFormatter.format(1234567), startsWith('₹'));
      });

      test('formats negative amounts', () {
        final result = CurrencyFormatter.format(-5000);
        expect(result, contains('5,000'));
      });
    });

    group('formatCompact', () {
      test('formats below 1000 as full amount', () {
        expect(CurrencyFormatter.formatCompact(500), equals('₹500'));
      });

      test('formats 1500 as 1.5K', () {
        expect(CurrencyFormatter.formatCompact(1500), equals('₹1.5K'));
      });

      test('formats 1500000 as 15.0L', () {
        expect(CurrencyFormatter.formatCompact(1500000), equals('₹15.0L'));
      });

      test('formats 10000000 as 1.0Cr', () {
        expect(CurrencyFormatter.formatCompact(10000000), equals('₹1.0Cr'));
      });

      test('formats 100000 as 1.0L', () {
        expect(CurrencyFormatter.formatCompact(100000), equals('₹1.0L'));
      });
    });

    group('parse', () {
      test('parses simple amount', () {
        expect(CurrencyFormatter.parse('₹500'), equals(500.0));
      });

      test('parses amount with commas', () {
        expect(CurrencyFormatter.parse('₹1,500'), equals(1500.0));
      });

      test('returns null for empty string', () {
        expect(CurrencyFormatter.parse(''), isNull);
      });

      test('returns null for non-numeric string', () {
        expect(CurrencyFormatter.parse('invalid'), isNull);
      });

      test('parses amount without rupee symbol', () {
        expect(CurrencyFormatter.parse('5000'), equals(5000.0));
      });
    });
  });
}
