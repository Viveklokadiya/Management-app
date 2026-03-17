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
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transactions/domain/models/transaction_model.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    final txnAsync = ref.watch(allTransactionsStreamProvider);


    return Scaffold(
      backgroundColor: AppColors.background,
      body: txnAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (allTxns) {
          final now = DateTime.now();
          final today = allTxns.where((t) =>
              t.transactionDate.year == now.year &&
              t.transactionDate.month == now.month &&
              t.transactionDate.day == now.day);
          final todayIncome = today
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (s, t) => s + t.amountRupees);
          final todayExpense = today
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (s, t) => s + t.amountRupees);
          final netBalance = todayIncome - todayExpense;
          final recent = allTxns.take(5).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                ref.invalidate(allTransactionsStreamProvider),
            child: CustomScrollView(
              slivers: [
                // ─── Sticky Header ────────────────────────────────────
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: AppColors.surface,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  titleSpacing: 16,
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.name)}&background=EC5B13&color=fff&size=80',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.hello}, ${user.name.split(' ').first}',
                              style: AppTextStyles.headlineSmall,
                            ),
                            Text(
                              'Shree Giriraj Engineering',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.notifications_outlined),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 4),
                  ],
                ),

                // ─── Main Summary Cards ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Net Balance — full-width orange card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.netBalance,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyFormatter.format(netBalance.abs()),
                                style: AppTextStyles.amountLarge
                                    .copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.trending_up,
                                        color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!.totalTransactionsCount(allTxns.length),
                                      style: AppTextStyles.labelSmall
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Income / Expense 2-column
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStatCard(
                                label: AppLocalizations.of(context)!.todayIncome,
                                amount: todayIncome,
                                isIncome: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MiniStatCard(
                                label: AppLocalizations.of(context)!.todayExpense,
                                amount: todayExpense,
                                isIncome: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Quick Actions ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.quickActions,
                            style: AppTextStyles.headlineSmall),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                label: AppLocalizations.of(context)!.addIncome,
                                icon: Icons.add_circle_outline,
                                onTap: () => context.push(
                                  AppRoutes.addTransaction,
                                  extra: {
                                    'type': TransactionType.income
                                  },
                                ),
                                filled: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                label: AppLocalizations.of(context)!.addExpense,
                                icon: Icons.remove_circle_outline,
                                onTap: () => context.push(
                                  AppRoutes.addTransaction,
                                  extra: {
                                    'type': TransactionType.expense
                                  },
                                ),
                                filled: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Secondary Info (Transactions + Sites) ────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.receipt_long_outlined,
                            title: AppLocalizations.of(context)!.totalTransactions,
                            subtitle: AppLocalizations.of(context)!.itemsCount(allTxns.length),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StreamBuilder(
                            stream: ref
                                .read(siteRepositoryProvider)
                                .getAllSites(),
                            builder: (context, snapshot) {
                              final count = snapshot.data?.length ?? 0;
                              return _InfoTile(
                                icon: Icons.factory_outlined,
                                title: AppLocalizations.of(context)!.activeSites,
                                subtitle: AppLocalizations.of(context)!.locationsCount(count),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Recent Transactions ──────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.recentTransactions,
                            style: AppTextStyles.headlineSmall),
                        TextButton(
                          onPressed: () =>
                              context.go(AppRoutes.adminTransactions),
                          child: Text(
                            AppLocalizations.of(context)!.viewAll,
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (recent.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: EmptyStateWidget(
                        title: AppLocalizations.of(context)!.noTransactionsYet,
                        message: AppLocalizations.of(context)!.addYourFirstTransaction,
                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _RecentTxnTile(txn: recent[i]),
                      childCount: recent.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.amount,
    required this.isIncome,
  });
  final String label;
  final double amount;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: AppTextStyles.amountSmall.copyWith(
              color:
                  isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isIncome
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 12,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
              const SizedBox(width: 2),
              Text(
                isIncome ? AppLocalizations.of(context)!.income : AppLocalizations.of(context)!.expense,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isIncome ? AppColors.income : AppColors.expense,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(subtitle,
                    style: AppTextStyles.labelSmall
                        .copyWith(fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.filled,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled
          ? AppColors.accent
          : AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: filled
                ? null
                : Border.all(color: AppColors.primaryLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: filled ? Colors.white : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: filled ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTxnTile extends StatelessWidget {
  const _RecentTxnTile({required this.txn});
  final TransactionModel txn;

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.type == TransactionType.income;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowLight, blurRadius: 4)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isIncome
                    ? AppColors.incomeLight
                    : AppColors.expenseLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: isIncome ? AppColors.income : AppColors.expense,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.remarks?.isNotEmpty == true
                        ? txn.remarks!
                        : '${isIncome ? AppLocalizations.of(context)!.income : AppLocalizations.of(context)!.expense} · ${txn.siteId}',
                    style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('d MMM · h:mm a')
                        .format(txn.transactionDate),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${CurrencyFormatter.formatCompact(txn.amountRupees)}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isIncome ? AppColors.income : AppColors.expense,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _paymentLabel(txn.paymentMethod, context),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 9,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _paymentLabel(PaymentMethod m, BuildContext context) => switch (m) {
        PaymentMethod.upi => AppLocalizations.of(context)!.upi,
        PaymentMethod.bank => AppLocalizations.of(context)!.bank,
        PaymentMethod.cash => AppLocalizations.of(context)!.cash,
        PaymentMethod.other => AppLocalizations.of(context)!.other,
      };
}
