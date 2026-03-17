import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';

enum AmountSize { small, medium, large }

enum TransactionType { income, expense }

/// Displays a formatted Indian currency amount with optional color by type
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

    return Text(
      '$sign${CurrencyFormatter.format(amount)}',
      style: textStyle.copyWith(color: color),
    );
  }
}

/// Summary card showing income/expense total with colored background
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
              : AmountDisplay(
                  amount: amount,
                  type: type,
                  size: AmountSize.medium,
                ),
        ],
      ),
    );
  }
}
