import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../transactions/domain/models/transaction_model.dart';

class AdminPartnerDetailScreen extends ConsumerStatefulWidget {
  const AdminPartnerDetailScreen({super.key, required this.partner});
  final AppUser partner;

  @override
  ConsumerState<AdminPartnerDetailScreen> createState() =>
      _AdminPartnerDetailScreenState();
}

class _AdminPartnerDetailScreenState
    extends ConsumerState<AdminPartnerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partner = widget.partner;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Partner Details'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverToBoxAdapter(child: _PartnerHero(partner: partner)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: AppTextStyles.labelMedium
                    .copyWith(fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Transactions'),
                  Tab(text: 'Location'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(partner: partner),
            _TransactionsTab(userId: partner.id),
            _LocationTab(partner: partner),
          ],
        ),
      ),
    );
  }
}

// ─── Hero section ─────────────────────────────────────────────────────────────

class _PartnerHero extends StatelessWidget {
  const _PartnerHero({required this.partner});
  final AppUser partner;

  @override
  Widget build(BuildContext context) {
    final sinceYear = DateFormat('MMM yyyy').format(partner.createdAt);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(
        children: [
          // Avatar + online dot
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadowLight, blurRadius: 8)
                  ],
                ),
                child: Center(
                  child: Text(
                    partner.name.isNotEmpty
                        ? partner.name[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: partner.isActive
                        ? const Color(0xFF22C55E)
                        : AppColors.textHint,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(partner.name, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'PARTNER',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Partner since $sinceYear',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Overview tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.partner});
  final AppUser partner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load user's transactions for summary
    final txnStream = ref
        .watch(transactionRepositoryProvider)
        .getTransactionsByUser(partner.id);

    return StreamBuilder<List<TransactionModel>>(
      stream: txnStream,
      builder: (ctx, snap) {
        final txns = snap.data ?? [];
        final totalIncome = txns
            .where((t) => t.type == TransactionType.income)
            .fold(0.0, (s, t) => s + t.amountRupees);
        final totalExpense = txns
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (s, t) => s + t.amountRupees);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Transaction summary
            Text('TRANSACTION SUMMARY',
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary, letterSpacing: 1)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Income',
                    value: CurrencyFormatter.formatCompact(totalIncome),
                    color: AppColors.income,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Expense',
                    value: CurrencyFormatter.formatCompact(totalExpense),
                    color: AppColors.textPrimary,
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact details card
            _InfoCard(
              title: 'Contact Details',
              children: [
                _InfoRow(icon: Icons.person_outline, label: 'Full Name', value: partner.name),
                _InfoRow(icon: Icons.mail_outline, label: 'Email', value: partner.email),
                if (partner.phone != null)
                  _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: partner.phone!),
              ],
            ),
            const SizedBox(height: 16),

            // Assigned sites
            _AssignedSitesCard(userId: partner.id),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label, value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.amountSmall.copyWith(color: color)),
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 2),
              Text('all time',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textHint, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Text(title,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700)),
          ),
          Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary)),
                Text(value,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedSitesCard extends ConsumerWidget {
  const _AssignedSitesCard({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(siteRepositoryProvider).getAssignedSites(userId),
      builder: (ctx, snap) {
        final sites = snap.data ?? [];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Row(
                  children: [
                    Text('Assigned Sites',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (sites.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${sites.length} SITES',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.border),
              if (sites.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No sites assigned',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                )
              else
                ...sites.map(
                  (site) => ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_city,
                          color: AppColors.textSecondary, size: 20),
                    ),
                    title: Text(site.name,
                        style: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w600)),
                    subtitle: site.city != null
                        ? Text(
                            [site.city, site.state]
                                .whereType<String>()
                                .join(', '),
                            style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary))
                        : null,
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textHint),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Transactions tab ─────────────────────────────────────────────────────────

class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnStream = ref
        .watch(transactionRepositoryProvider)
        .getTransactionsByUser(userId);
    return StreamBuilder<List<TransactionModel>>(
      stream: txnStream,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (snap.hasError) {
          return ErrorStateWidget(message: snap.error.toString());
        }
        final txns = snap.data ?? [];
        if (txns.isEmpty) {
          return const EmptyStateWidget(
            title: 'No transactions',
            message: 'This partner has no transactions yet',
            icon: Icons.receipt_long_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: txns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final txn = txns[i];
            final isIncome = txn.type == TransactionType.income;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isIncome
                          ? AppColors.incomeLight
                          : AppColors.expenseLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isIncome
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color:
                          isIncome ? AppColors.income : AppColors.expense,
                      size: 18,
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
                              : (isIncome ? 'Income' : 'Expense'),
                          style: AppTextStyles.bodySmall
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          DateFormat('d MMM yyyy')
                              .format(txn.transactionDate),
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}${CurrencyFormatter.format(txn.amountRupees)}',
                    style: AppTextStyles.amountSmall.copyWith(
                      color:
                          isIncome ? AppColors.income : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Location tab ─────────────────────────────────────────────────────────────

class _LocationTab extends StatelessWidget {
  const _LocationTab({required this.partner});
  final AppUser partner;

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        partner.lastLatitude != null && partner.lastLongitude != null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Location card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: hasLocation
                ? Column(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primary, size: 40),
                      const SizedBox(height: 10),
                      Text('Last Known Location',
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        '${partner.lastLatitude!.toStringAsFixed(5)}, '
                        '${partner.lastLongitude!.toStringAsFixed(5)}',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      if (partner.lastLocationAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Updated: ${DateFormat('d MMM yyyy, HH:mm').format(partner.lastLocationAt!)}',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textHint),
                        ),
                      ],
                    ],
                  )
                : Column(
                    children: [
                      const Icon(Icons.location_off,
                          color: AppColors.textHint, size: 40),
                      const SizedBox(height: 10),
                      Text('No Location Data',
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        'This partner has not shared their location yet.',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky tab bar delegate ──────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(height: 1, color: AppColors.border),
          tabBar,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}
