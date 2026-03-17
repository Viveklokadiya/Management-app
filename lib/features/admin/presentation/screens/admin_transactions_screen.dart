import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../transactions/domain/models/transaction_model.dart';

class AdminTransactionsScreen extends ConsumerStatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  ConsumerState<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState
    extends ConsumerState<AdminTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0; // 0=All, 1=Income, 2=Expense

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging == false) {
          setState(() => _tabIndex = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filter(List<TransactionModel> all) {
    if (_tabIndex == 1) return all.where((t) => t.type == TransactionType.income).toList();
    if (_tabIndex == 2) return all.where((t) => t.type == TransactionType.expense).toList();
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final txnAsync = ref.watch(allTransactionsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.transactions),
            Text(
              'Shree Giriraj Engineering',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle:
              AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: AppLocalizations.of(context)!.all),
            Tab(text: AppLocalizations.of(context)!.income),
            Tab(text: AppLocalizations.of(context)!.expense),
          ],
        ),
      ),
      body: txnAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (allTxns) {
          final filtered = _filter(allTxns);
          final totalIncome = filtered
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (s, t) => s + t.amountRupees);
          final totalExpense = filtered
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (s, t) => s + t.amountRupees);
          final netBalance = totalIncome - totalExpense;

          // Group by date
          final grouped = <String, List<TransactionModel>>{};
          for (final t in filtered) {
            final key = DateFormat('EEEE, MMM d').format(t.transactionDate);
            grouped.putIfAbsent(key, () => []).add(t);
          }

          return Column(
            children: [
              // Monthly Balance card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.netBalance,
                              style: AppTextStyles.labelSmall
                                  .copyWith(
                                      color: Colors.white, fontSize: 9),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyFormatter.format(netBalance.abs()),
                            style: AppTextStyles.amountLarge
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.trending_up,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.totalTransactionsCount(filtered.length),
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? EmptyStateWidget(
                        title: AppLocalizations.of(context)!.noTransactions,
                        message: AppLocalizations.of(context)!.nothingToShowFilter,
                        icon: Icons.receipt_long_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: grouped.length,
                        itemBuilder: (context, i) {
                          final key = grouped.keys.elementAt(i);
                          final items = grouped[key]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  key.toUpperCase(),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.8,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              ...items.map((t) => _AdminTxnTile(txn: t)),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.addTransaction),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _AdminTxnTile extends StatelessWidget {
  const _AdminTxnTile({required this.txn});
  final TransactionModel txn;

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.type == TransactionType.income;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isIncome ? AppColors.incomeLight : AppColors.expenseLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.north_east_rounded
                  : Icons.south_west_rounded,
              color: isIncome ? AppColors.income : AppColors.expense,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyFormatter.format(txn.amountRupees),
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isIncome
                            ? AppColors.incomeLight
                            : AppColors.expenseLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isIncome ? AppLocalizations.of(context)!.income.toUpperCase() : AppLocalizations.of(context)!.expense.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isIncome ? AppColors.income : AppColors.expense,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.byUser(txn.createdByName ?? ''),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        txn.siteId,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textHint),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
