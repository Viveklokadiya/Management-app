import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/language_tile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() =>
      _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final l10n = AppLocalizations.of(context);
    if (user == null) return const SizedBox.shrink();

    final isSuperAdmin = user.role == UserRole.superAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Dark header ─────────────────────────────────────────
            Container(
              width: double.infinity,
              color: AppColors.accent,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                bottom: 32,
                left: 24,
                right: 24,
              ),
              child: Column(
                children: [
                  // Avatar with primary border
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.amountLarge
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.name,
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      isSuperAdmin
                          ? l10n.superAdmin.toUpperCase()
                          : l10n.admin.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showEditSheet(context),
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: Colors.white),
                    label: Text(
                      'Edit Profile',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.6)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Info card ───────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: l10n.email,
                        value: user.email,
                        locked: true,
                      ),
                      const Divider(
                          height: 1,
                          indent: 64,
                          color: AppColors.border),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: l10n.phoneNumber,
                        value: user.phone?.isNotEmpty == true
                            ? user.phone!
                            : l10n.notProvided,
                      ),
                      const Divider(
                          height: 1,
                          indent: 64,
                          color: AppColors.border),
                      _InfoRow(
                        icon: Icons.business_outlined,
                        label: l10n.organization,
                        value: 'Shree Giriraj Engineering',
                      ),
                      const Divider(
                          height: 1,
                          indent: 64,
                          color: AppColors.border),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: l10n.memberSince,
                        value: DateFormat('MMMM yyyy')
                            .format(user.createdAt),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Settings Card ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const LanguageTile(),
              ),
            ),

            // ─── Manage Users Card (Super Admin only) ────────────────
            if (isSuperAdmin)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.superAdminUsers),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.manage_accounts_outlined,
                                size: 22,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MANAGE USERS',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      letterSpacing: 0.5,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'View & manage all users',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ─── Logout ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _signingOut ? null : () => _signOut(context),
                  icon: _signingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    l10n.logout,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(ref: ref),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _signingOut = true);
    try {
      await ref.read(authStateProvider.notifier).signOut();
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }
}

// ─── Edit Profile Bottom Sheet ───────────────────────────────────────────────
class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.ref.read(authStateProvider).value;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(authStateProvider.notifier).updateProfile(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Edit Profile',
                style: AppTextStyles.headlineSmall
                    .copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(
              'Gmail ID cannot be changed.',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('Full Name', Icons.person_outline),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                  'Phone Number (optional)', Icons.phone_outlined),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.locked = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E1DD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          if (locked)
            const Icon(Icons.lock_outline,
                size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
