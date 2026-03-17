---
plan: "02"
phase: "01-project-setup-and-architecture"
title: "Centralized Theming & Core Utilities"
wave: 1
depends_on: []
files_modified:
  - lib/core/theme/app_colors.dart
  - lib/core/theme/app_text_styles.dart
  - lib/core/theme/app_theme.dart
  - lib/core/constants/app_constants.dart
  - lib/core/utils/currency_formatter.dart
  - lib/core/utils/date_formatter.dart
autonomous: true
requirements:
  - TECH-05
---

## Goal

Implement the centralized design system: colors (deep navy primary), typography, spacing constants, Indian currency formatter, and date formatter. This is the single source of truth for all visual styling across the app.

## Context

**Brand colors:**
- Primary: `#0D2137` (Deep Navy — inspired by steel/engineering)
- Primary Light: `#1A3A5C`
- Primary Dark: `#061120`
- Accent: `#1976D2` (Professional Blue)
- Income Green: `#2E7D32`
- Expense Red: `#C62828`
- Background: `#F8F9FA` (Very light grey)
- Surface: `#FFFFFF`
- Card: `#FFFFFF` with shadow
- Text Primary: `#1A1A2E`
- Text Secondary: `#6B7280`
- Border: `#E5E7EB`

**Typography:** Use `Roboto` (Flutter default) — optionally swap to `Inter` via google_fonts later.

**Indian currency:** ₹12,34,567 format (Indian number system with lakhs/crores). Use `intl` package's `NumberFormat.currency(locale: 'en_IN', symbol: '₹')`.

## Tasks

<task id="2.1">
<title>Create app_colors.dart</title>
<read_first>
  - `lib/core/theme/` — confirm directory exists (created in Plan 01)
</read_first>
<action>
Create `lib/core/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand — Deep Navy
  static const Color primary = Color(0xFF0D2137);
  static const Color primaryLight = Color(0xFF1A3A5C);
  static const Color primaryDark = Color(0xFF061120);

  // Accent Blue
  static const Color accent = Color(0xFF1976D2);
  static const Color accentLight = Color(0xFF42A5F5);

  // Transaction Types
  static const Color income = Color(0xFF2E7D32);
  static const Color incomeLight = Color(0xFFE8F5E9);
  static const Color expense = Color(0xFFC62828);
  static const Color expenseLight = Color(0xFFFFEBEE);

  // Backgrounds
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1976D2);

  // Role chips
  static const Color superAdminChip = Color(0xFF0D2137);
  static const Color adminChip = Color(0xFF1976D2);
  static const Color partnerChip = Color(0xFF6B7280);

  // Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
}
```
</action>
<acceptance_criteria>
- `lib/core/theme/app_colors.dart` exists
- File contains `static const Color primary = Color(0xFF0D2137)`
- File contains `static const Color income = Color(0xFF2E7D32)`
- File contains `static const Color expense = Color(0xFFC62828)`
- File contains `static const Color background = Color(0xFFF8F9FA)`
- `flutter analyze lib/core/theme/app_colors.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="2.2">
<title>Create app_text_styles.dart</title>
<read_first>
  - `lib/core/theme/app_colors.dart` — import colors
</read_first>
<action>
Create `lib/core/theme/app_text_styles.dart`:

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display — Large financial amounts
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );

  // Headings
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // Amount — Financial display (prominent)
  static const TextStyle amountLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Button text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );

  // Caption / timestamp
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );
}
```
</action>
<acceptance_criteria>
- `lib/core/theme/app_text_styles.dart` exists
- File contains `static const TextStyle amountLarge`
- File contains `FontFeature.tabularFigures()`
- File contains `static const TextStyle displayLarge`
- `flutter analyze lib/core/theme/app_text_styles.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="2.3">
<title>Create app_theme.dart with full MaterialTheme</title>
<read_first>
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_text_styles.dart`
</read_first>
<action>
Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accent,
        onSecondary: AppColors.textOnPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
        outline: AppColors.border,
        surfaceContainerHighest: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Card
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primaryLight,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // TabBar
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }
}
```
</action>
<acceptance_criteria>
- `lib/core/theme/app_theme.dart` exists
- File contains `static ThemeData get lightTheme`
- File contains `useMaterial3: true`
- File contains `backgroundColor: AppColors.primary` (AppBar)
- File contains `borderRadius: BorderRadius.circular(12)` (CardTheme)
- File contains `borderRadius: BorderRadius.circular(10)` (inputs)
- `flutter analyze lib/core/theme/app_theme.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="2.4">
<title>Create app_constants.dart</title>
<read_first>
  - `lib/core/constants/` — confirm directory exists
</read_first>
<action>
Create `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Shree Giriraj Engineering';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String sitesCollection = 'sites';
  static const String siteUsersCollection = 'site_users';
  static const String transactionsCollection = 'transactions';
  static const String auditLogsCollection = 'audit_logs';

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Card elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  // Pagination
  static const int defaultPageSize = 20;
  static const int recentTransactionLimit = 5;

  // Timeouts
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration locationTimeout = Duration(seconds: 10);
}
```
</action>
<acceptance_criteria>
- `lib/core/constants/app_constants.dart` exists
- File contains `static const String usersCollection = 'users'`
- File contains `static const String transactionsCollection = 'transactions'`
- File contains `static const double spacingM = 16.0`
- `flutter analyze lib/core/constants/app_constants.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="2.5">
<title>Create currency_formatter.dart (Indian number system)</title>
<read_first>
  - `pubspec.yaml` — confirm `intl:` dependency is declared
</read_first>
<action>
Create `lib/core/utils/currency_formatter.dart`:

```dart
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

  /// Format a double/int amount to Indian currency string.
  /// Example: 1234567 → ₹12,34,567
  static String format(num amount) {
    return _inrFormat.format(amount);
  }

  /// Format with 2 decimal places.
  /// Example: 1234567.50 → ₹12,34,567.50
  static String formatWithDecimal(num amount) {
    return _inrFormatWithDecimal.format(amount);
  }

  /// Format a compact amount for card display.
  /// Example: 1234567 → ₹12.3L
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

  /// Parse a formatted string back to double.
  static double? parse(String formattedAmount) {
    try {
      final cleaned = formattedAmount.replaceAll('₹', '').replaceAll(',', '').trim();
      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
```
</action>
<acceptance_criteria>
- `lib/core/utils/currency_formatter.dart` exists
- File contains `NumberFormat.currency(locale: 'en_IN', symbol: '₹'`
- File contains `static String format(num amount)`
- File contains `static String formatCompact(num amount)`
- `flutter analyze lib/core/utils/currency_formatter.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="2.6">
<title>Create date_formatter.dart</title>
<read_first>
  - `pubspec.yaml` — confirm `intl:` dependency
</read_first>
<action>
Create `lib/core/utils/date_formatter.dart`:

```dart
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

  /// Format: "2026-03-17" (for API/Firestore queries)
  static String toApiDate(DateTime date) => _apiDate.format(date);

  /// Convert Firestore Timestamp to DateTime safely
  static DateTime? fromTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    try {
      // Handles both Timestamp and DateTime
      if (timestamp is DateTime) return timestamp;
      return (timestamp as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }

  /// Relative time display: "2 hours ago", "Yesterday", "17 Mar 2026"
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
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
```
</action>
<acceptance_criteria>
- `lib/core/utils/date_formatter.dart` exists
- File contains `static String toDisplayDate(DateTime date)`
- File contains `static String toRelative(DateTime date)`
- File contains `static bool isToday(DateTime date)`
- `flutter analyze lib/core/utils/date_formatter.dart` reports 0 errors
</acceptance_criteria>
</task>

## Verification

```bash
flutter analyze lib/core/theme/ lib/core/constants/ lib/core/utils/
```

Expected: 0 errors. Warnings about unused imports acceptable if files reference types from Phase 2+.

## must_haves

- [ ] `AppColors` has `primary = Color(0xFF0D2137)`, `income`, `expense`, `background` defined
- [ ] `AppTheme.lightTheme` is a valid `ThemeData` with `useMaterial3: true`
- [ ] `CurrencyFormatter.format(1234567)` produces `₹12,34,567` (Indian locale)
- [ ] `CurrencyFormatter.formatCompact(1500000)` produces `₹15.0L`
- [ ] `DateFormatter.toDisplayDate(DateTime(2026, 3, 17))` produces `17 Mar 2026`
- [ ] `DateFormatter.isToday` returns `true` for `DateTime.now()`
- [ ] All files pass `flutter analyze` with 0 errors
