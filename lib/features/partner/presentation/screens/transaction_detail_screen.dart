import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transactions/domain/models/transaction_model.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  final String transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  bool _isDeleting = false;

  Future<void> _confirmDelete(
      BuildContext context, TransactionModel txn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.expenseLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.expense, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Delete Transaction'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Are you sure you want to delete this transaction? This action cannot be undone.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: txn.type == TransactionType.income
                          ? AppColors.incomeLight
                          : AppColors.expenseLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      txn.type == TransactionType.income
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 14,
                      color: txn.type == TransactionType.income
                          ? AppColors.income
                          : AppColors.expense,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CurrencyFormatter.format(txn.amountRupees),
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          txn.siteName,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Capture before async gap
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isDeleting = true);
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      await ref.read(transactionRepositoryProvider).deleteTransaction(
            transactionId: txn.id,
            userId: user?.id ?? '',
            userName: user?.name ?? '',
          );
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Transaction deleted successfully'),
          backgroundColor: AppColors.income,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      navigator.pop();
    } catch (e) {
      if (mounted) setState(() => _isDeleting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final canDelete = currentUser?.role == UserRole.admin ||
        currentUser?.role == UserRole.superAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<TransactionModel?>(
        future: ref
            .read(transactionRepositoryProvider)
            .getTransactionById(widget.transactionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.hasError) {
            return ErrorStateWidget(message: snapshot.error.toString());
          }
          final txn = snapshot.data;
          if (txn == null) {
            return const ErrorStateWidget(message: 'Transaction not found');
          }

          final isIncome = txn.type == TransactionType.income;

          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                title: Text(l10n.transactionDetails),
                leading: const BackButton(),
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(1),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                actions: [
                  if (canDelete)
                    _isDeleting
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.expense),
                            ),
                          )
                        : IconButton(
                            tooltip: 'Delete transaction',
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.expense),
                            onPressed: () => _confirmDelete(context, txn),
                          ),
                ],
              ),
            ],
            body: SingleChildScrollView(
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
                          _DetailRow('Type', isIncome ? 'Income' : 'Expense'),
                          _Divider(),
                          _DetailRow('Site Name', txn.siteName),
                          if (txn.projectName != null &&
                              txn.projectName!.isNotEmpty) ...[
                            _Divider(),
                            _DetailRow('Project Name', txn.projectName!),
                          ],
                          if (txn.clientName != null &&
                              txn.clientName!.isNotEmpty) ...[
                            _Divider(),
                            _DetailRow('Client Name', txn.clientName!),
                          ],
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
                              size: 16, color: AppColors.textSecondary),
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
                                  '${txn.latitude!.toStringAsFixed(5)}, '
                                  '${txn.longitude!.toStringAsFixed(5)}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
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
  Widget build(BuildContext context) => const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.divider);
}
