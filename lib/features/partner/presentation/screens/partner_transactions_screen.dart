import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transactions/domain/models/transaction_model.dart';

class PartnerTransactionsScreen extends ConsumerStatefulWidget {
  const PartnerTransactionsScreen({super.key});

  @override
  ConsumerState<PartnerTransactionsScreen> createState() =>
      _PartnerTransactionsScreenState();
}

class _PartnerTransactionsScreenState
    extends ConsumerState<PartnerTransactionsScreen> {
  TransactionType? _typeFilter;
  DateTimeRange? _dateRange;

  List<TransactionModel> _applyFilters(List<TransactionModel> all) {
    var list = all;
    if (_dateRange != null) {
      list = list.where((t) {
        final d = t.transactionDate;
        return !d.isBefore(_dateRange!.start) &&
            !d.isAfter(
                _dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    } else {
      final now = DateTime.now();
      list = list
          .where((t) =>
              t.transactionDate.year == now.year &&
              t.transactionDate.month == now.month)
          .toList();
    }
    if (_typeFilter != null) {
      list = list.where((t) => t.type == _typeFilter).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    final txnStream = ref
        .watch(transactionRepositoryProvider)
        .getTransactionsByUser(user.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.transactions),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async =>
            ref.invalidate(transactionRepositoryProvider),
        child: StreamBuilder<List<TransactionModel>>(
          stream: txnStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }
            if (snapshot.hasError) {
              return ErrorStateWidget(message: snapshot.error.toString());
            }
            final filtered = _applyFilters(snapshot.data ?? []);
            final totalIncome = filtered
                .where((t) => t.type == TransactionType.income)
                .fold(0.0, (s, t) => s + t.amountRupees);
            final totalExpense = filtered
                .where((t) => t.type == TransactionType.expense)
                .fold(0.0, (s, t) => s + t.amountRupees);

            return Column(
              children: [
                // Totals strip
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: _TotalBadge(
                              'Income', totalIncome, AppColors.income)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _TotalBadge(
                              'Expense', totalExpense, AppColors.expense)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                // List
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyStateWidget(
                          title: 'No transactions',
                          message: _typeFilter != null || _dateRange != null
                              ? 'Try adjusting your filters'
                              : 'Tap + to add your first transaction',
                          icon: Icons.receipt_long_outlined,
                          actionLabel:
                              _typeFilter != null || _dateRange != null
                                  ? 'Clear Filters'
                                  : null,
                          onAction: () => setState(() {
                            _typeFilter = null;
                            _dateRange = null;
                          }),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) =>
                              _TransactionCard(txn: filtered[i]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.addTransaction),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Transactions',
                  style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              const Text('Type', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _typeFilter == null,
                    onTap: () {
                      setState(() => _typeFilter = null);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Income',
                    selected: _typeFilter == TransactionType.income,
                    color: AppColors.income,
                    onTap: () {
                      setState(
                          () => _typeFilter = TransactionType.income);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Expense',
                    selected: _typeFilter == TransactionType.expense,
                    color: AppColors.expense,
                    onTap: () {
                      setState(
                          () => _typeFilter = TransactionType.expense);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Date Range', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  _FilterChip(
                    label: 'This Month',
                    selected: _dateRange == null,
                    onTap: () {
                      setState(() => _dateRange = null);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Custom Range',
                    selected: _dateRange != null,
                    onTap: () async {
                      Navigator.pop(context);
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _dateRange,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context)
                                .colorScheme
                                .copyWith(primary: AppColors.primary),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() => _dateRange = picked);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalBadge extends StatelessWidget {
  const _TotalBadge(this.label, this.amount, this.color);
  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final active = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? active.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? active : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? active : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.txn});
  final TransactionModel txn;

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.type == TransactionType.income;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/partner/transaction/${txn.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: badge + title + site
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isIncome
                                ? AppColors.incomeLight
                                : AppColors.expenseLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isIncome ? 'INCOME' : 'EXPENSE',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isIncome
                                  ? AppColors.income
                                  : AppColors.expense,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          txn.remarks?.isNotEmpty == true
                              ? txn.remarks!
                              : (isIncome ? 'Income' : 'Expense'),
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          txn.siteName,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Right: amount + date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}${CurrencyFormatter.format(txn.amountRupees)}',
                        style: AppTextStyles.amountSmall.copyWith(
                          color: isIncome
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d, y')
                            .format(txn.transactionDate),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20, color: AppColors.divider),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _paymentColor(txn.paymentMethod),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _paymentLabel(txn.paymentMethod),
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _paymentColor(PaymentMethod m) => switch (m) {
        PaymentMethod.upi => const Color(0xFF8B5CF6),
        PaymentMethod.bank => const Color(0xFF3B82F6),
        PaymentMethod.other => const Color(0xFFF59E0B),
        PaymentMethod.cash => const Color(0xFF10B981),
      };

  String _paymentLabel(PaymentMethod m) => switch (m) {
        PaymentMethod.upi => 'UPI',
        PaymentMethod.bank => 'Bank Transfer',
        PaymentMethod.cash => 'Cash',
        PaymentMethod.other => 'Other',
      };
}
