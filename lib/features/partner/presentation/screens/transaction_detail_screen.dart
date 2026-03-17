import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../transactions/domain/models/transaction_model.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    required this.siteId,
  });

  final String transactionId;
  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Transaction Details'),
        leading: const BackButton(),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: FutureBuilder<TransactionModel?>(
        future: ref.read(transactionRepositoryProvider).getTransactionById(
              siteId: siteId,
              transactionId: transactionId,
            ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.hasError) {
            return ErrorStateWidget(message: snapshot.error.toString());
          }
          final txn = snapshot.data;
          if (txn == null) {
            return const ErrorStateWidget(
                message: 'Transaction not found');
          }

          final isIncome = txn.type == TransactionType.income;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ─── Hero ─────────────────────────────────────────────
                Container(
                  color: AppColors.surface,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Text(
                        'Total Amount',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        CurrencyFormatter.format(txn.amountRupees),
                        style: AppTextStyles.amountLarge.copyWith(
                          color: isIncome
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isIncome
                              ? AppColors.incomeLight
                              : AppColors.expenseLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isIncome ? 'Income' : 'Expense',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isIncome
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Detail Card ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                            'Type', isIncome ? 'Income' : 'Expense'),
                        _Divider(),
                        _DetailRow('Site Name', txn.siteId),
                        _Divider(),
                        _DetailRow(
                          'Payment Method',
                          _paymentLabel(txn.paymentMethod),
                        ),
                        _Divider(),
                        _DetailRow(
                          'Date',
                          DateFormat('MMM d, yyyy')
                              .format(txn.transactionDate),
                        ),
                        _Divider(),
                        _DetailRow(
                          'Recorded At',
                          DateFormat('h:mm a').format(txn.createdAt),
                        ),
                        if (txn.remarks != null &&
                            txn.remarks!.isNotEmpty) ...[
                          _Divider(),
                          _RemarksRow(txn.remarks!),
                        ],
                      ],
                    ),
                  ),
                ),

                // ─── Location ─────────────────────────────────────────
                if (txn.latitude != null && txn.longitude != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '${txn.latitude!.toStringAsFixed(5)}, ${txn.longitude!.toStringAsFixed(5)}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  String _paymentLabel(PaymentMethod m) => switch (m) {
        PaymentMethod.upi => 'UPI',
        PaymentMethod.bank => 'Bank Transfer',
        PaymentMethod.cash => 'Cash',
        PaymentMethod.other => 'Other',
      };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RemarksRow extends StatelessWidget {
  const _RemarksRow(this.remarks);
  final String remarks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Remarks',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(remarks, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider);
}
