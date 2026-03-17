import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/domain/models/app_user.dart';

class SuperAdminUsersScreen extends ConsumerStatefulWidget {
  const SuperAdminUsersScreen({super.key});

  @override
  ConsumerState<SuperAdminUsersScreen> createState() =>
      _SuperAdminUsersScreenState();
}

class _SuperAdminUsersScreenState extends ConsumerState<SuperAdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0; // 0=All, 1=Admins, 2=Partners
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() => _tabIndex = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AppUser> _filter(List<AppUser> users) {
    var list = users;
    if (_tabIndex == 1) {
      list = list
          .where((u) => u.role == UserRole.admin || u.role == UserRole.superAdmin)
          .toList();
    } else if (_tabIndex == 2) {
      list = list.where((u) => u.role == UserRole.partner).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((u) {
        return u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersStreamProvider);

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
              child: const Icon(Icons.manage_accounts,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Users'),
                Text(
                  'Shree Giriraj Engineering',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
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
                  Tab(text: 'All Users'),
                  Tab(text: 'Admins'),
                  Tab(text: 'Partners'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: usersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (users) {
          final filtered = _filter(users);
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
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
              ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyStateWidget(
                        title: 'No users found',
                        message: _query.isNotEmpty
                            ? 'Try a different search'
                            : 'Tap + to add a user',
                        icon: Icons.people_outline,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (ctx, i) =>
                            _UserCard(user: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.superAdminAddUser),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  const _UserCard({required this.user});
  final AppUser user;

  Color _roleColor(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => AppColors.primary,
      UserRole.admin => AppColors.primary,
      UserRole.partner => AppColors.textSecondary,
    };
  }

  Color _roleBg(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => AppColors.primary,
      UserRole.admin => AppColors.primaryLight,
      UserRole.partner => const Color(0xFFF1F5F9),
    };
  }

  Color _roleTextColor(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => Colors.white,
      UserRole.admin => AppColors.primary,
      UserRole.partner => AppColors.textSecondary,
    };
  }

  String _roleLabel(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => 'Super Admin',
      UserRole.admin => 'Admin',
      UserRole.partner => 'Partner',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inactive = !user.isActive;
    return Opacity(
      opacity: inactive ? 0.75 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowLight, blurRadius: 4)
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar (initials)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: inactive
                          ? const Color(0xFFE2E8F0)
                          : AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: inactive
                            ? const Color(0xFFCBD5E1)
                            : AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: inactive
                              ? AppColors.textSecondary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name + email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: inactive
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Active/Inactive badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: user.isActive
                                  ? const Color(0xFF22C55E)
                                  : AppColors.textHint,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.isActive ? 'Active' : 'Inactive',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10,
                              color: user.isActive
                                  ? const Color(0xFF22C55E)
                                  : AppColors.textHint,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _roleBg(user.role),
                      borderRadius: BorderRadius.circular(20),
                      border: user.role != UserRole.superAdmin
                          ? Border.all(
                              color: _roleColor(user.role)
                                  .withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Text(
                      _roleLabel(user.role),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _roleTextColor(user.role),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 3-dot menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.textSecondary),
                    onSelected: (val) => _onMenuAction(context, ref, val),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ])),
                      PopupMenuItem(
                          value: 'toggle',
                          child: Row(children: [
                            Icon(
                              user.isActive
                                  ? Icons.block_outlined
                                  : Icons.check_circle_outline,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(user.isActive ? 'Deactivate' : 'Activate'),
                          ])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMenuAction(
      BuildContext context, WidgetRef ref, String action) async {
    if (action == 'edit') {
      context.push('/admin/edit-user/${user.id}', extra: user);
      return;
    }
    if (action == 'toggle') {
      final db = ref.read(firestoreProvider);
      await db
          .collection('users')
          .doc(user.id)
          .update({'isActive': !user.isActive});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(user.isActive
                  ? '${user.name} deactivated'
                  : '${user.name} activated')),
        );
      }
    }
  }
}
