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
import '../../../auth/presentation/providers/auth_provider.dart';
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
              const Divider(height: 1, color: AppColors.border),
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

class _PartnersTab extends ConsumerStatefulWidget {
  const _PartnersTab({required this.siteId});
  final String siteId;

  @override
  ConsumerState<_PartnersTab> createState() => _PartnersTabState();
}

class _PartnersTabState extends ConsumerState<_PartnersTab> {
  late Future<List<SiteUserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    _usersFuture = ref.read(siteRepositoryProvider).getUsersForSite(widget.siteId);
  }

  void _refresh() {
    setState(() {
      _loadUsers();
    });
  }

  void _showAssignSheet(List<SiteUserModel> assignedUsers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AssignPartnerSheet(
        siteId: widget.siteId,
        assignedUserIds: assignedUsers.map((u) => u.userId).toSet(),
        onAssigned: () {
          Navigator.pop(ctx);
          _refresh();
        },
      ),
    );
  }

  Future<void> _removePartner(SiteUserModel siteUser) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Partner'),
        content: Text('Remove ${siteUser.userName} from this site?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(siteRepositoryProvider).removeUserFromSite(
            siteId: widget.siteId,
            userId: siteUser.userId,
          );
      _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SiteUserModel>>(
      future: _usersFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (snap.hasError) {
          return ErrorStateWidget(message: snap.error.toString());
        }
        final users = snap.data ?? [];
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: EmptyStateWidget(
                        title: 'No partners assigned',
                        message: 'Assign partners to this site to allow them to add transactions',
                        icon: Icons.people_outline,
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _PartnerRow(
                        siteUser: users[i],
                        onRemove: () => _removePartner(users[i]),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: users.isEmpty ? 0 : 20),
                    child: InkWell(
                      onTap: () => _showAssignSheet(users),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            '+ Assign Partner',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PartnerRow extends StatelessWidget {
  const _PartnerRow({required this.siteUser, this.onRemove});
  final SiteUserModel siteUser;
  final VoidCallback? onRemove;

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
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.error),
              onPressed: onRemove,
            )
          else
            const Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
    );
  }
}

class _AssignPartnerSheet extends ConsumerWidget {
  const _AssignPartnerSheet({
    required this.siteId,
    required this.assignedUserIds,
    required this.onAssigned,
  });

  final String siteId;
  final Set<String> assignedUserIds;
  final VoidCallback onAssigned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnersStream = ref.watch(allPartnersStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assign Partner',
                    style: AppTextStyles.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: partnersStream.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (partners) {
                  final available = partners
                      .where((p) => !assignedUserIds.contains(p.id))
                      .toList();
                  
                  if (available.isEmpty) {
                    return const Center(
                      child: Text('All partners are already assigned.'),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: available.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final partner = available[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: AppColors.primary,
                              child: Text(partner.name.isNotEmpty ? partner.name[0].toUpperCase() : '?'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(partner.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                  if (partner.phone?.isNotEmpty == true)
                                    Text(partner.phone!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                              ),
                              onPressed: () async {
                                final currentUser = ref.read(authStateProvider).value;
                                if (currentUser == null) return;

                                final siteUser = SiteUserModel(
                                  id: '',
                                  siteId: siteId,
                                  userId: partner.id,
                                  userName: partner.name,
                                  userEmail: partner.email,
                                  assignedAt: DateTime.now(),
                                  assignedByUserId: currentUser.id,
                                );

                                try {
                                  await ref
                                      .read(siteRepositoryProvider)
                                      .assignUserToSite(siteUser);
                                  onAssigned();
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                              child: Text('Assign', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
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
