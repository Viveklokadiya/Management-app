import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
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
          const Divider(height: 1, color: AppColors.border),
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
              const Divider(height: 1, color: AppColors.border),
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

class _LocationTab extends StatefulWidget {
  const _LocationTab({required this.partner});
  final AppUser partner;

  @override
  State<_LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<_LocationTab> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partner = widget.partner;
    final hasLocation =
        partner.lastLatitude != null && partner.lastLongitude != null;

    if (!hasLocation) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, size: 56, color: AppColors.textHint),
            SizedBox(height: 12),
            Text('No Location Data',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'This partner has not shared\ntheir location yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final point =
        LatLng(partner.lastLatitude!, partner.lastLongitude!);

    return Column(
      children: [
        // ─── Map ──────────────────────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15,
                  minZoom: 3,
                  maxZoom: 18,
                ),
                children: [
                  // OpenStreetMap tiles — free, no API key
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.shreegiriraj.managementapp',
                    maxNativeZoom: 18,
                  ),
                  // Partner marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 48,
                        height: 48,
                        child: Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  partner.name.isNotEmpty
                                      ? partner.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            CustomPaint(
                              size: const Size(12, 8),
                              painter: _TrianglePainter(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ─── Zoom controls ──────────────────────────────────────────
              Positioned(
                bottom: 16,
                right: 12,
                child: Column(
                  children: [
                    _MapButton(
                      icon: Icons.add,
                      onTap: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _MapButton(
                      icon: Icons.remove,
                      onTap: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _MapButton(
                      icon: Icons.my_location,
                      onTap: () {
                        _mapController.move(point, 15);
                      },
                    ),
                  ],
                ),
              ),

              // ─── OSM attribution (required by OSM license) ──────────────
              Positioned(
                bottom: 4,
                left: 8,
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.black.withValues(alpha: 0.5),
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ─── Info card below map ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${partner.lastLatitude!.toStringAsFixed(5)}, '
                      '${partner.lastLongitude!.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (partner.lastLocationAt != null)
                      Text(
                        'Updated ${DateFormat('d MMM yyyy, HH:mm').format(partner.lastLocationAt!)}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Map zoom button ──────────────────────────────────────────────────────────

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
            )
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

// ─── Marker triangle pointer ──────────────────────────────────────────────────

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
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
          const Divider(height: 1, color: AppColors.border),
          tabBar,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}
