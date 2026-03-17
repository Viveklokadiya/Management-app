import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../sites/domain/models/site_model.dart';
import '../../../sites/domain/models/site_user_model.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import 'add_edit_site_screen.dart';

class AdminSiteDetailScreen extends ConsumerStatefulWidget {
  const AdminSiteDetailScreen({super.key, required this.site});
  final SiteModel site;

  @override
  ConsumerState<AdminSiteDetailScreen> createState() =>
      _AdminSiteDetailScreenState();
}

class _AdminSiteDetailScreenState extends ConsumerState<AdminSiteDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;

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
        title: const Text('Site Details'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AddEditSiteScreen(existingSite: site)),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Site'),
                  ])),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Divider(height: 1, color: AppColors.border),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: AppTextStyles.labelMedium
                    .copyWith(fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'Partners'),
                  Tab(text: 'Transactions'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── Site Hero ────────────────────────────────────────────────
          _SiteHero(site: site),

          // ─── Tab content ──────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PartnersTab(siteId: site.id),
                _TransactionsTab(siteId: site.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Site Hero ────────────────────────────────────────────────────────────────

class _SiteHero extends StatelessWidget {
  const _SiteHero({required this.site});
  final SiteModel site;

  @override
  Widget build(BuildContext context) {
    final location = [site.city, site.state].whereType<String>().join(', ');
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.location_city,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(site.name,
                    style: AppTextStyles.headlineSmall,
                    overflow: TextOverflow.ellipsis),
                if (location.isNotEmpty)
                  Text(location,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  site.isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: site.isActive
                        ? const Color(0xFF22C55E)
                        : AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  site.isActive ? 'Active' : 'Inactive',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: site.isActive
                        ? const Color(0xFF16A34A)
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Partners Tab ─────────────────────────────────────────────────────────────

class _PartnersTab extends ConsumerWidget {
  const _PartnersTab({required this.siteId});
  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<SiteUserModel>>(
      future: ref.read(siteRepositoryProvider).getUsersForSite(siteId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (snap.hasError) {
          return ErrorStateWidget(message: snap.error.toString());
        }
        final users = snap.data ?? [];
        if (users.isEmpty) {
          return const EmptyStateWidget(
            title: 'No partners assigned',
            message: 'Assign partners to this site via the Users screen',
            icon: Icons.people_outline,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _PartnerRow(siteUser: users[i]),
        );
      },
    );
  }
}

class _PartnerRow extends StatelessWidget {
  const _PartnerRow({required this.siteUser});
  final SiteUserModel siteUser;

  @override
  Widget build(BuildContext context) {
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                siteUser.userName.isNotEmpty
                    ? siteUser.userName[0].toUpperCase()
                    : '?',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(siteUser.userName,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(
                  'Partner',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
    );
  }
}

// ─── Transactions Tab ─────────────────────────────────────────────────────────

class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab({required this.siteId});
  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnStream =
        ref.watch(transactionRepositoryProvider).getTransactionsForSite(siteId);
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
            message: 'Transactions for this site will appear here',
            icon: Icons.receipt_long_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: txns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _TxnRow(txn: txns[i]),
        );
      },
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});
  final TransactionModel txn;

  @override
  Widget build(BuildContext context) {
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
          // dot + line (timeline style from design)
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isIncome ? AppColors.income : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d MMM yyyy • HH:mm')
                      .format(txn.transactionDate),
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  txn.remarks?.isNotEmpty == true
                      ? txn.remarks!
                      : (isIncome ? 'Income' : 'Expense'),
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  txn.createdByName,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
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
    );
  }
}
