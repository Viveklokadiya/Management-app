import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrFormatWithDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format to Indian currency: 1234567 → ₹12,34,567
  static String format(num amount) {
    return _inrFormat.format(amount);
  }

  /// Format with 2 decimal places: 1234567.50 → ₹12,34,567.50
  static String formatWithDecimal(num amount) {
    return _inrFormatWithDecimal.format(amount);
  }

  /// Compact format for card display: 1500000 → ₹15.0L
  static String formatCompact(num amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  /// Parse a formatted string back to double
  static double? parse(String formattedAmount) {
    try {
      final cleaned = formattedAmount
          .replaceAll('₹', '')
          .replaceAll(',', '')
          .trim();
      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
