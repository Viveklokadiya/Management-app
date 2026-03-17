import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─── Role Chip ─────────────────────────────────────────────────────────────

enum UserRole { superAdmin, admin, partner }

class RoleChip extends StatelessWidget {
  const RoleChip({super.key, required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final (label, bg) = switch (role) {
      UserRole.superAdmin => ('Super Admin', AppColors.superAdminChip),
      UserRole.admin => ('Admin', AppColors.adminChip),
      UserRole.partner => ('Partner', AppColors.partnerChip),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall
            .copyWith(color: AppColors.textOnPrimary),
      ),
    );
  }
}

// ─── Transaction Type Badge ─────────────────────────────────────────────────

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
            isIncome
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
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

// ─── Payment Method Chip ────────────────────────────────────────────────────

class PaymentMethodChip extends StatelessWidget {
  const PaymentMethodChip({super.key, required this.method});
  final String method;

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

// ─── Section Header ────────────────────────────────────────────────────────

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
              style:
                  AppTextStyles.labelMedium.copyWith(color: AppColors.accent),
            ),
          ),
      ],
    );
  }
}
