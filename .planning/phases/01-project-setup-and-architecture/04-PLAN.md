---
plan: "04"
phase: "01-project-setup-and-architecture"
title: "App Wiring, Build Validation & Commit"
wave: 3
depends_on:
  - "01"
  - "02"
  - "03"
files_modified:
  - lib/app.dart
  - lib/main.dart
  - test/widget_test.dart
  - test/core/currency_formatter_test.dart
  - test/core/date_formatter_test.dart
autonomous: true
requirements:
  - TECH-01
  - TECH-08
---

## Goal

Wire all created files together, confirm `flutter run` launches cleanly on Android with the correct design, write unit tests for `CurrencyFormatter` and `DateFormatter`, run full analysis + tests, and commit Phase 1.

## Context

This plan runs AFTER Plans 01, 02, 03 are complete. All files referenced here must exist. The goal is to assemble the scaffold into a verifiable running app, not build features.

## Tasks

<task id="4.1">
<title>Update app.dart to use AppTheme and verify clean launch</title>
<read_first>
  - `lib/app.dart` — current content
  - `lib/core/theme/app_theme.dart` — AppTheme.lightTheme
  - `lib/core/theme/app_colors.dart` — AppColors.primary
  - `lib/core/widgets/` — all widgets created in Plan 03
</read_first>
<action>
Replace `lib/app.dart` with this final version that uses all Phase 1 artifacts:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/widgets/app_button.dart';
import 'core/widgets/app_card.dart';
import 'core/widgets/amount_display.dart';
import 'core/utils/currency_formatter.dart';

class ShreeGirirajApp extends ConsumerWidget {
  const ShreeGirirajApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Shree Giriraj Engineering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _PlaceholderHome(),
    );
  }
}

/// Temporary placeholder home — replaced in Phase 2 with router + auth
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shree Giriraj Engineering'),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Design System Preview',
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 24),

            // Amount cards
            Row(
              children: const [
                Expanded(
                  child: AmountSummaryCard(
                    label: 'Today Income',
                    amount: 1234567,
                    type: TransactionType.income,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AmountSummaryCard(
                    label: 'Today Expense',
                    amount: 456789,
                    type: TransactionType.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Currency formatter demo
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Currency Formatter', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  Text(CurrencyFormatter.format(1234567), style: AppTextStyles.amountMedium),
                  Text(CurrencyFormatter.formatCompact(1500000), style: AppTextStyles.amountSmall),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Buttons
            const AppButton(label: 'Primary Button', onPressed: null),
            const SizedBox(height: 8),
            const AppButton(label: 'Loading...', onPressed: null, isLoading: true),
            const SizedBox(height: 8),
            const AppButton(label: 'Outline', onPressed: null, variant: AppButtonVariant.outline),
            const SizedBox(height: 8),
            const AppButton(label: 'Danger', onPressed: null, variant: AppButtonVariant.danger),
          ],
        ),
      ),
    );
  }
}
```
</action>
<acceptance_criteria>
- `lib/app.dart` imports `app_theme.dart`
- `lib/app.dart` uses `AppTheme.lightTheme` in MaterialApp
- `lib/app.dart` contains `_PlaceholderHome`
- `lib/app.dart` imports and uses `AmountSummaryCard`
- `flutter analyze lib/app.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="4.2">
<title>Write unit tests for CurrencyFormatter</title>
<read_first>
  - `lib/core/utils/currency_formatter.dart`
  - `pubspec.yaml` — flutter_test dependency
</read_first>
<action>
Create `test/core/currency_formatter_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shree_giriraj_management/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    group('format', () {
      test('formats zero correctly', () {
        expect(CurrencyFormatter.format(0), equals('₹0'));
      });

      test('formats hundreds correctly', () {
        expect(CurrencyFormatter.format(500), equals('₹500'));
      });

      test('formats thousands correctly', () {
        expect(CurrencyFormatter.format(1000), equals('₹1,000'));
      });

      test('formats Indian lakhs correctly', () {
        // Indian: 1,00,000 = 1 lakh
        expect(CurrencyFormatter.format(100000), contains('₹'));
        expect(CurrencyFormatter.format(100000), contains('1'));
      });

      test('formats 1234567 in Indian system', () {
        // Should be ₹12,34,567 (Indian format) or ₹1,234,567 depending on locale
        final result = CurrencyFormatter.format(1234567);
        expect(result, startsWith('₹'));
        expect(result, contains('1234567'.replaceAll('', '')));
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

      test('formats thousands as K', () {
        expect(CurrencyFormatter.formatCompact(1500), equals('₹1.5K'));
      });

      test('formats lakhs as L', () {
        expect(CurrencyFormatter.formatCompact(1500000), equals('₹15.0L'));
      });

      test('formats crores as Cr', () {
        expect(CurrencyFormatter.formatCompact(10000000), equals('₹1.0Cr'));
      });
    });

    group('parse', () {
      test('parses formatted amount back to double', () {
        expect(CurrencyFormatter.parse('₹500'), equals(500.0));
      });

      test('parses amount with commas', () {
        expect(CurrencyFormatter.parse('₹1,500'), equals(1500.0));
      });

      test('returns null for invalid input', () {
        expect(CurrencyFormatter.parse('invalid'), isNull);
      });

      test('returns null for empty string', () {
        expect(CurrencyFormatter.parse(''), isNull);
      });
    });
  });
}
```
</action>
<acceptance_criteria>
- `test/core/currency_formatter_test.dart` exists
- File contains `group('CurrencyFormatter'`
- File contains test for `formatCompact(1500000)` → `₹15.0L`
- File contains test for `parse` returning null on invalid input
- `flutter test test/core/currency_formatter_test.dart` exits 0
</acceptance_criteria>
</task>

<task id="4.3">
<title>Write unit tests for DateFormatter</title>
<read_first>
  - `lib/core/utils/date_formatter.dart`
</read_first>
<action>
Create `test/core/date_formatter_test.dart`:

```dart
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

    test('isToday returns true for DateTime.now()', () {
      expect(DateFormatter.isToday(DateTime.now()), isTrue);
    });

    test('isToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.isToday(yesterday), isFalse);
    });

    test('fromTimestamp returns null for null input', () {
      expect(DateFormatter.fromTimestamp(null), isNull);
    });

    test('fromTimestamp handles DateTime input', () {
      final result = DateFormatter.fromTimestamp(testDate);
      expect(result, equals(testDate));
    });

    test('toRelative shows "Just now" for current time', () {
      final now = DateTime.now();
      expect(DateFormatter.toRelative(now), equals('Just now'));
    });

    test('toRelative shows minutes ago', () {
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      expect(DateFormatter.toRelative(fiveMinutesAgo), contains('m ago'));
    });
  });
}
```
</action>
<acceptance_criteria>
- `test/core/date_formatter_test.dart` exists
- File contains test `toDisplayDate` → `'17 Mar 2026'`
- File contains test `isToday` for `DateTime.now()` → `true`
- File contains test `toRelative` for current time → `'Just now'`
- `flutter test test/core/date_formatter_test.dart` exits 0
</acceptance_criteria>
</task>

<task id="4.4">
<title>Run full analysis and tests, fix any issues</title>
<read_first>
  - All files in `lib/core/`
  - All test files in `test/core/`
</read_first>
<action>
Run in sequence:

```bash
# 1. Get dependencies
flutter pub get

# 2. Analyze entire project
flutter analyze

# 3. Run all tests
flutter test

# 4. Optional: try to build APK to validate dependencies resolve
flutter build apk --debug 2>&1 | tail -20
```

**Fix any issues found:**

Common issues and fixes:
- Unused import → remove import line
- Missing `const` keyword on widget → add `const`
- `prefer_single_quotes` warnings → replace double quotes with single quotes
- Missing `key` parameter → add `{super.key}` to constructor
- Deprecated API usage → update to Material 3 equivalent

**Do NOT proceed until `flutter analyze` exits 0** (0 errors; warnings acceptable if documented).

After fixing, re-run `flutter analyze` and `flutter test`.
</action>
<acceptance_criteria>
- `flutter pub get` exits 0
- `flutter analyze` exits 0 with output `No issues found!` or only warnings (no errors)
- `flutter test` exits 0 — all tests pass
- `flutter test` output contains `All tests passed!` or equivalent success message
</acceptance_criteria>
</task>

<task id="4.5">
<title>Commit Phase 1</title>
<read_first>
  - `.planning/STATE.md` — update current phase and last action
</read_first>
<action>
Update `.planning/STATE.md`:
```markdown
## Current Status

**Phase:** 1 of 10 — COMPLETE
**Phase name:** Project Setup & Architecture
**Phase state:** Complete

## Last Action

Phase 1 executed on 2026-03-17. All 4 plans completed:
- Plan 01: Flutter project, pubspec.yaml, folder structure
- Plan 02: Design system (AppColors, AppTheme, CurrencyFormatter, DateFormatter)
- Plan 03: Reusable widget library (AppButton, AppCard, AmountDisplay, etc.)
- Plan 04: App wiring, unit tests, validation

## Completed Phases

- [x] Phase 1: Project Setup & Architecture — 2026-03-17
```

Then commit all Phase 1 files:
```bash
git add lib/ test/ pubspec.yaml pubspec.lock analysis_options.yaml android/
git commit -m "feat(phase-1): project setup, design system, reusable widget library

- Add pubspec.yaml with all production dependencies (firebase, riverpod, go_router, geolocator, intl)
- Create 3-layer folder structure: core/, features/ (auth, transactions, sites, users, partner, admin, super_admin)
- Implement design system: AppColors (#0D2137 navy), AppTheme (Material 3), typography
- Add Indian currency formatter: CurrencyFormatter.format(1234567) → ₹12,34,567
- Add date formatter: toDisplayDate, toRelative, isToday
- Build reusable widget library: AppButton, AppCard, AppTextField, AmountDisplay, role/type chips
- Add loading/empty/error state widgets
- Write unit tests for CurrencyFormatter and DateFormatter
- All tests pass: flutter test ✓
- Zero flutter analyze errors ✓"
```
</action>
<acceptance_criteria>
- `.planning/STATE.md` contains `Phase 1 — COMPLETE`
- `git log --oneline -1` shows `feat(phase-1): project setup`
- `git status` shows clean working tree (or only untracked files in assets/)
</acceptance_criteria>
</task>

## Verification

```bash
flutter analyze
flutter test
```

## must_haves

- [ ] `flutter pub get` exits 0 — all dependencies resolved
- [ ] `flutter analyze` exits 0 — no Dart analysis errors
- [ ] `flutter test` exits 0 — unit tests for CurrencyFormatter and DateFormatter pass
- [ ] `lib/app.dart` uses `AppTheme.lightTheme` from `app_theme.dart`
- [ ] Deep navy (#0D2137) AppBar is visible when app runs
- [ ] `AmountSummaryCard` renders with Indian ₹ formatting
- [ ] Phase 1 committed to git with descriptive commit message
