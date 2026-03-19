import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../sites/domain/models/site_model.dart';
import 'add_edit_site_screen.dart';
import 'admin_site_detail_screen.dart';

class AdminSitesScreen extends ConsumerStatefulWidget {
  const AdminSitesScreen({super.key});

  @override
  ConsumerState<AdminSitesScreen> createState() => _AdminSitesScreenState();
}

class _AdminSitesScreenState extends ConsumerState<AdminSitesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  // null = all, true = active, false = inactive
  bool? _activeFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SiteModel> _applyFilter(List<SiteModel> sites) {
    var list = sites;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((s) {
        return s.name.toLowerCase().contains(q) ||
            (s.city?.toLowerCase().contains(q) ?? false) ||
            (s.address?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    if (_activeFilter != null) {
      list = list.where((s) => s.isActive == _activeFilter).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.engineering,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).constructionSites),
                Text(
                  'Shree Giriraj Engineering',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: () =>
                  _showAddSiteDialog(context),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: StreamBuilder<List<SiteModel>>(
        stream: ref.read(siteRepositoryProvider).getAllSites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.hasError) {
            return ErrorStateWidget(message: snapshot.error.toString());
          }
          final filtered = _applyFilter(snapshot.data ?? []);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                ref.invalidate(siteRepositoryProvider),
            child: Column(
              children: [
                // Search + filter chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).searchSites,
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
                      const SizedBox(height: 12),
                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: AppLocalizations.of(context).allProjects,
                              selected: _activeFilter == null,
                              onTap: () =>
                                  setState(() => _activeFilter = null),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: AppLocalizations.of(context).active,
                              selected: _activeFilter == true,
                              onTap: () =>
                                  setState(() => _activeFilter = true),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: AppLocalizations.of(context).inactive,
                              selected: _activeFilter == false,
                              onTap: () =>
                                  setState(() => _activeFilter = false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Sites list
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyStateWidget(
                          title: AppLocalizations.of(context).noSitesFound,
                          message: _query.isNotEmpty
                              ? AppLocalizations.of(context).tryDifferentSearch
                              : AppLocalizations.of(context).tapToAddSite,
                          icon: Icons.factory_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, i) =>
                              _SiteCard(site: filtered[i]),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddSiteDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditSiteScreen()),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SiteCard extends StatelessWidget {
  const _SiteCard({required this.site});
  final SiteModel site;

  @override
  Widget build(BuildContext context) {
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
          // Site name header with status badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site.name,
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              [site.address, site.city, site.state]
                                  .where((s) => s?.isNotEmpty == true)
                                  .join(', '),
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: site.isActive
                        ? const Color(0xFF22C55E).withValues(alpha: 0.9)
                        : AppColors.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    site.isActive ? AppLocalizations.of(context).active.toUpperCase() : AppLocalizations.of(context).onHold.toUpperCase(),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Footer: recent activity + manage
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).siteIdUppercase,
                        style: AppTextStyles.labelSmall
                            .copyWith(fontSize: 9, color: AppColors.textHint),
                      ),
                      Text(
                        site.id,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AdminSiteDetailScreen(site: site)),
                    );
                  },
                  child: Text(AppLocalizations.of(context).manage,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
