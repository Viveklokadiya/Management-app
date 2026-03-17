---
plan: "03"
phase: "01-project-setup-and-architecture"
title: "Reusable Widget Library"
wave: 2
depends_on:
  - "02"
files_modified:
  - lib/core/widgets/app_button.dart
  - lib/core/widgets/app_card.dart
  - lib/core/widgets/app_text_field.dart
  - lib/core/widgets/loading_widget.dart
  - lib/core/widgets/empty_state_widget.dart
  - lib/core/widgets/error_state_widget.dart
  - lib/core/widgets/amount_display.dart
  - lib/core/widgets/role_chip.dart
  - lib/core/widgets/transaction_type_badge.dart
  - lib/core/widgets/payment_method_chip.dart
  - lib/core/widgets/section_header.dart
autonomous: true
requirements:
  - TECH-06
---

## Goal

Build the complete reusable widget library that all feature screens will use. Every widget follows the design system from Plan 02 (AppColors, AppTextStyles, AppConstants). No screen should directly use `ElevatedButton`, raw `Card`, or raw `TextField` — they always compose from this library.

## Context

- All widgets import from `package:shree_giriraj_management/core/theme/app_colors.dart` etc.
- Widgets are `StatelessWidget` where possible; only use `StatefulWidget` if managing local state (e.g., password visibility toggle)
- Prefer `const` constructors
- Every widget has a `key` parameter via `super.key`

## Tasks

<task id="3.1">
<title>Create app_button.dart — primary action button</title>
<read_first>
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_text_styles.dart`
</read_first>
<action>
Create `lib/core/widgets/app_button.dart`:

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.size = AppButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: _loaderSize,
            width: _loaderSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_loaderColor),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: _iconSize),
                  const SizedBox(width: 8),
                  Text(label, style: _textStyle),
                ],
              )
            : Text(label, style: _textStyle);

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: _padding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
          ),
          child: child,
        ),
      AppButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textOnPrimary,
            padding: _padding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
          ),
          child: child,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: _padding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: child,
        ),
      AppButtonVariant.danger => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnPrimary,
            padding: _padding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
          ),
          child: child,
        ),
    };

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      };

  TextStyle get _textStyle => switch (size) {
        AppButtonSize.small => AppTextStyles.buttonMedium,
        AppButtonSize.medium => AppTextStyles.buttonLarge,
        AppButtonSize.large => AppTextStyles.buttonLarge,
      };

  double get _iconSize => size == AppButtonSize.small ? 16 : 20;
  double get _loaderSize => size == AppButtonSize.small ? 16 : 20;
  Color get _loaderColor => variant == AppButtonVariant.outline
      ? AppColors.primary
      : AppColors.textOnPrimary;
}

enum AppButtonSize { small, medium, large }
```
</action>
<acceptance_criteria>
- `lib/core/widgets/app_button.dart` exists
- File contains `enum AppButtonVariant { primary, secondary, outline, danger }`
- File contains `final bool isLoading`
- File contains `CircularProgressIndicator` inside isLoading branch
- `flutter analyze lib/core/widgets/app_button.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="3.2">
<title>Create app_card.dart — styled card wrapper</title>
<read_first>
  - `lib/core/theme/app_colors.dart`
  - `lib/core/constants/app_constants.dart`
</read_first>
<action>
Create `lib/core/widgets/app_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation = AppConstants.elevationS,
    this.borderRadius = AppConstants.radiusM,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final double elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppConstants.spacingM),
            child: child,
          ),
        ),
      ),
    );
  }
}
```
</action>
<acceptance_criteria>
- `lib/core/widgets/app_card.dart` exists
- File contains `final VoidCallback? onTap`
- File contains `BoxShadow`
- File contains `InkWell`
- `flutter analyze lib/core/widgets/app_card.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="3.3">
<title>Create app_text_field.dart — styled input with validation</title>
<read_first>
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_text_styles.dart`
</read_first>
<action>
Create `lib/core/widgets/app_text_field.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixText,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? prefixText;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: minLines,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          focusNode: focusNode,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            prefixStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
            fillColor: enabled ? AppColors.surface : AppColors.background,
          ),
        ),
      ],
    );
  }
}

/// Amount field with ₹ prefix and numeric keyboard
class AppAmountField extends StatelessWidget {
  const AppAmountField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.onChanged,
    this.hint = '0',
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Amount is required' : null,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      prefixText: '₹ ',
    );
  }
}
```
</action>
<acceptance_criteria>
- `lib/core/widgets/app_text_field.dart` exists
- File contains `class AppTextField extends StatelessWidget`
- File contains `class AppAmountField extends StatelessWidget`
- File contains `prefixText: '₹ '` in AppAmountField
- File contains `FilteringTextInputFormatter.allow`
- `flutter analyze lib/core/widgets/app_text_field.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="3.4">
<title>Create loading_widget.dart, empty_state_widget.dart, error_state_widget.dart</title>
<read_first>
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_text_styles.dart`
</read_first>
<action>
Create `lib/core/widgets/loading_widget.dart`:
```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: AppTextStyles.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Full-screen loading overlay
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, required this.child, required this.isLoading});
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x80FFFFFF),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
          ),
      ],
    );
  }
}
```

Create `lib/core/widgets/empty_state_widget.dart`:
```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.headlineMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

Create `lib/core/widgets/error_state_widget.dart`:
```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    this.message = 'Something went wrong',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: 'Try Again',
                onPressed: onRetry,
                isFullWidth: false,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```
</action>
<acceptance_criteria>
- `lib/core/widgets/loading_widget.dart` exists and contains `class LoadingWidget` and `class LoadingOverlay`
- `lib/core/widgets/empty_state_widget.dart` exists and contains `class EmptyStateWidget`
- `lib/core/widgets/error_state_widget.dart` exists and contains text `'Something went wrong'`
- `flutter analyze lib/core/widgets/loading_widget.dart` reports 0 errors
- `flutter analyze lib/core/widgets/empty_state_widget.dart` reports 0 errors
- `flutter analyze lib/core/widgets/error_state_widget.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="3.5">
<title>Create amount_display.dart — financial value display widget</title>
<read_first>
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_text_styles.dart`
  - `lib/core/utils/currency_formatter.dart`
</read_first>
<action>
Create `lib/core/widgets/amount_display.dart`:

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';

enum AmountSize { small, medium, large }
enum TransactionType { income, expense }

class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    this.type,
    this.size = AmountSize.medium,
    this.showSign = false,
  });

  final double amount;
  final TransactionType? type;
  final AmountSize size;
  final bool showSign;

  @override
  Widget build(BuildContext context) {
    final color = type == null
        ? AppColors.textPrimary
        : type == TransactionType.income
            ? AppColors.income
            : AppColors.expense;

    final textStyle = switch (size) {
      AmountSize.small => AppTextStyles.amountSmall,
      AmountSize.medium => AppTextStyles.amountMedium,
      AmountSize.large => AppTextStyles.amountLarge,
    };

    final sign = showSign
        ? (type == TransactionType.income ? '+' : '-')
        : '';
    final formattedAmount = CurrencyFormatter.format(amount);

    return Text(
      '$sign$formattedAmount',
      style: textStyle.copyWith(color: color),
    );
  }
}

/// Summary card for home screen showing income/expense totals
class AmountSummaryCard extends StatelessWidget {
  const AmountSummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.type,
    this.isLoading = false,
  });

  final String label;
  final double amount;
  final TransactionType type;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bgColor = type == TransactionType.income
        ? AppColors.incomeLight
        : AppColors.expenseLight;
    final iconColor = type == TransactionType.income
        ? AppColors.income
        : AppColors.expense;
    final icon = type == TransactionType.income
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: 8),
          isLoading
              ? const SizedBox(
                  height: 24,
                  width: 80,
                  child: LinearProgressIndicator(),
                )
              : AmountDisplay(amount: amount, type: type, size: AmountSize.medium),
        ],
      ),
    );
  }
}
```
</action>
<acceptance_criteria>
- `lib/core/widgets/amount_display.dart` exists
- File contains `class AmountDisplay extends StatelessWidget`
- File contains `class AmountSummaryCard extends StatelessWidget`
- File contains `CurrencyFormatter.format(amount)`
- File contains `TransactionType.income` and `TransactionType.expense` handling
- `flutter analyze lib/core/widgets/amount_display.dart` reports 0 errors
</acceptance_criteria>
</task>

<task id="3.6">
<title>Create role_chip.dart, transaction_type_badge.dart, payment_method_chip.dart, section_header.dart</title>
<read_first>
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_text_styles.dart`
</read_first>
<action>
Create `lib/core/widgets/role_chip.dart`:
```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum UserRole { superAdmin, admin, partner }

class RoleChip extends StatelessWidget {
  const RoleChip({super.key, required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final (label, bg, text) = switch (role) {
      UserRole.superAdmin => ('Super Admin', AppColors.superAdminChip, AppColors.textOnPrimary),
      UserRole.admin => ('Admin', AppColors.adminChip, AppColors.textOnPrimary),
      UserRole.partner => ('Partner', AppColors.partnerChip, AppColors.textOnPrimary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: text)),
    );
  }
}
```

Create `lib/core/widgets/transaction_type_badge.dart`:
```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TransactionTypeBadge extends StatelessWidget {
  const TransactionTypeBadge({super.key, required this.isIncome});
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isIncome ? AppColors.incomeLight : AppColors.expenseLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 12,
            color: isIncome ? AppColors.income : AppColors.expense,
          ),
          const SizedBox(width: 4),
          Text(
            isIncome ? 'Income' : 'Expense',
            style: AppTextStyles.labelSmall.copyWith(
              color: isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}
```

Create `lib/core/widgets/payment_method_chip.dart`:
```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PaymentMethodChip extends StatelessWidget {
  const PaymentMethodChip({super.key, required this.method});
  final String method; // 'cash', 'upi', 'bank', 'other'

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (method.toLowerCase()) {
      'cash' => (Icons.payments_outlined, 'Cash'),
      'upi' => (Icons.smartphone_outlined, 'UPI'),
      'bank' => (Icons.account_balance_outlined, 'Bank'),
      _ => (Icons.more_horiz, 'Other'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
```

Create `lib/core/widgets/section_header.dart`:
```dart
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.actionLabel,
  });

  final String title;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headlineSmall),
        if (action != null && actionLabel != null)
          TextButton(
            onPressed: action,
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent),
            ),
          ),
      ],
    );
  }
}
```
</action>
<acceptance_criteria>
- `lib/core/widgets/role_chip.dart` exists and contains `enum UserRole`
- `lib/core/widgets/transaction_type_badge.dart` exists and contains `final bool isIncome`
- `lib/core/widgets/payment_method_chip.dart` exists and contains `switch (method.toLowerCase())`
- `lib/core/widgets/section_header.dart` exists
- `flutter analyze lib/core/widgets/` reports 0 errors
</acceptance_criteria>
</task>

## Verification

```bash
flutter analyze lib/core/widgets/
```

Expected: 0 errors across all widget files.

## must_haves

- [ ] `AppButton` renders with loading spinner when `isLoading: true`
- [ ] `AppButton` supports all 4 variants: primary, secondary, outline, danger
- [ ] `AppCard` has tap ripple effect via `InkWell`
- [ ] `AppTextField` + `AppAmountField` have proper label + validation support
- [ ] `LoadingWidget`, `EmptyStateWidget`, `ErrorStateWidget` all exist with retry action
- [ ] `AmountDisplay` uses `CurrencyFormatter` for ₹ formatting
- [ ] `AmountSummaryCard` shows income/expense in colored containers (green/red)
- [ ] `RoleChip`, `TransactionTypeBadge`, `PaymentMethodChip` exist with correct colors
- [ ] All widgets pass `flutter analyze` with 0 errors
