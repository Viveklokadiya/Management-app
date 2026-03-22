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
import '../../../../core/widgets/profile_photo_widget.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transactions/domain/models/transaction_model.dart';

class PartnerHomeScreen extends ConsumerWidget {
  const PartnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    final txnStream = ref
        .watch(transactionRepositoryProvider)
        .getTransactionsByUser(user.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(transactionRepositoryProvider),
        child: StreamBuilder<List<TransactionModel>>(
          stream: txnStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }
            if (snapshot.hasError) {
              return ErrorStateWidget(message: snapshot.error.toString());
            }
            final all = snapshot.data ?? [];
            final now = DateTime.now();
            final today = all.where((t) =>
                t.transactionDate.year == now.year &&
                t.transactionDate.month == now.month &&
                t.transactionDate.day == now.day);
            final todayIncome = today
                .where((t) => t.type == TransactionType.income)
                .fold(0.0, (s, t) => s + t.amountRupees);
            final todayExpense = today
                .where((t) => t.type == TransactionType.expense)
                .fold(0.0, (s, t) => s + t.amountRupees);
            final totalIncome = all
                .where((t) => t.type == TransactionType.income)
                .fold(0.0, (s, t) => s + t.amountRupees);
            final totalExpense = all
                .where((t) => t.type == TransactionType.expense)
                .fold(0.0, (s, t) => s + t.amountRupees);
            final netBalance = totalIncome - totalExpense;
            final recent = all.take(5).toList();

            return CustomScrollView(
              slivers: [
                // ─── Header ────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 24,
                      right: 24,
                      bottom: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting(context)}, ${user.name.split(' ').first}',
                              style: AppTextStyles.headlineMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context).welcomeBackDashboard,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        // Avatar → tap to open profile
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.partnerProfile),
                          child: ProfilePhotoWidget(
                            user: user,
                            radius: 24,
                            foregroundColor: AppColors.primary,
                            backgroundColor: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Summary Cards ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: AppLocalizations.of(context).todayIncome,
                                amount: todayIncome,
                                isIncome: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: AppLocalizations.of(context).todayExpense,
                                amount: todayExpense,
                                isIncome: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Net Balance card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: netBalance >= 0
                                ? AppColors.primary
                                : AppColors.expense,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (netBalance >= 0
                                        ? AppColors.primary
                                        : AppColors.expense)
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).netBalance,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${netBalance < 0 ? '-' : ''}${CurrencyFormatter.format(netBalance.abs())}',
                                    style: AppTextStyles.headlineLarge
                                        .copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        netBalance >= 0
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${all.length} transactions',
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                                color: Colors.white
                                                    .withValues(alpha: 0.8)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Quick Actions ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).quickActions, style: AppTextStyles.headlineSmall),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionTile(
                                label: AppLocalizations.of(context).addIncome,
                                icon: Icons.add,
                                color: AppColors.income,
                                bgColor: AppColors.incomeLight,
                                onTap: () => context.push(
                                  AppRoutes.addTransaction,
                                  extra: {'type': TransactionType.income},
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionTile(
                                label: AppLocalizations.of(context).addExpense,
                                icon: Icons.remove,
                                color: AppColors.textPrimary,
                                bgColor: const Color(0xFFF3F4F6),
                                onTap: () => context.push(
                                  AppRoutes.addTransaction,
                                  extra: {'type': TransactionType.expense},
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Recent Transactions ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context).recentTransactions,
                            style: AppTextStyles.headlineSmall),
                        TextButton(
                          onPressed: () =>
                              context.go(AppRoutes.partnerTransactions),
                          child: Text(
                            AppLocalizations.of(context).viewAll,
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
                        title: AppLocalizations.of(context).noTransactionsYet,
                        message: AppLocalizations.of(context).tapToAddFirstTransaction,
                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: _TransactionListTile(txn: recent[i]),
                      ),
                      childCount: recent.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppLocalizations.of(context).goodMorning;
    if (hour < 17) return AppLocalizations.of(context).goodAfternoon;
    return AppLocalizations.of(context).goodEvening;
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isIncome ? AppColors.income : AppColors.expense,
            width: 4,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: AppTextStyles.amountMedium.copyWith(
              color: isIncome ? AppColors.income : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Tile ────────────────────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style:
                    AppTextStyles.labelMedium.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Transaction List Tile ────────────────────────────────────────────────────

class _TransactionListTile extends StatelessWidget {
  const _TransactionListTile({required this.txn});
  final TransactionModel txn;

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.type == TransactionType.income;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push('/partner/transaction/${txn.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isIncome ? AppColors.incomeLight : AppColors.expenseLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isIncome
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: isIncome ? AppColors.income : AppColors.expense,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIncome ? AppLocalizations.of(context).income : AppLocalizations.of(context).expense,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      txn.remarks?.isNotEmpty == true
                          ? '${txn.remarks!} · ${txn.siteName} · ${DateFormat('d MMM').format(txn.transactionDate)}'
                          : '${txn.siteName} • ${DateFormat('d MMM').format(txn.transactionDate)}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textHint),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${CurrencyFormatter.format(txn.amountRupees)}',
                style: AppTextStyles.amountSmall.copyWith(
                  color: isIncome ? AppColors.income : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
