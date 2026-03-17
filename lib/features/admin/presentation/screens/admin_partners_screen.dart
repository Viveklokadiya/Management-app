import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/domain/models/app_user.dart';
import 'admin_partner_detail_screen.dart';

class AdminPartnersScreen extends ConsumerStatefulWidget {
  const AdminPartnersScreen({super.key});

  @override
  ConsumerState<AdminPartnersScreen> createState() =>
      _AdminPartnersScreenState();
}

class _AdminPartnersScreenState extends ConsumerState<AdminPartnersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AppUser> _filter(List<AppUser> users) {
    if (_query.isEmpty) return users;
    final q = _query.toLowerCase();
    return users.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          (u.phone?.contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final partnersAsync = ref.watch(allPartnersStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.engineering,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.partners),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: partnersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (users) {
          final filtered = _filter(users);

          return Column(
            children: [
              // Search + filter
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchPartners,
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Partner count strip
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.allPartnersCount(filtered.length),
                            style: AppTextStyles.labelSmall
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyStateWidget(
                        title: AppLocalizations.of(context)!.noPartnersFound,
                        message: _query.isNotEmpty
                            ? AppLocalizations.of(context)!.tryDifferentSearch
                            : AppLocalizations.of(context)!.noPartnersRegistered,
                        icon: Icons.people_outline,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, i) =>
                            _PartnerCard(user: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final isOnline = user.lastLocationAt != null &&
        DateTime.now().difference(user.lastLocationAt!).inMinutes < 30;
    final lastSeen = user.lastLocationAt;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(
                                          fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  user.email.split('@').first
                                      .toUpperCase()
                                      .substring(0,
                                          (user.id.length > 8 ? 8 : user.id.length)),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? AppColors.incomeLight
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isOnline
                                  ? AppLocalizations.of(context)!.online
                                  : lastSeen != null
                                      ? DateFormat('h:mm a')
                                          .format(lastSeen)
                                      : AppLocalizations.of(context)!.offline,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isOnline
                                    ? AppColors.income
                                    : AppColors.warning,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (user.phone?.isNotEmpty == true) ...[
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 14,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(user.phone!,
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lastSeen != null
                                  ? AppLocalizations.of(context)!.lastSeenDate(DateFormat('d MMM y').format(lastSeen))
                                  : AppLocalizations.of(context)!.noLocationData,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
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
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.factory_outlined,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.viewAssignedSites,
                  style: AppTextStyles.labelSmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(
                   onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AdminPartnerDetailScreen(partner: user)),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.viewDetails,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.primary),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 16, color: AppColors.primary),
                    ],
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
