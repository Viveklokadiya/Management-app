import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../sites/domain/models/site_model.dart';

class AddEditUserScreen extends ConsumerStatefulWidget {
  /// If [existingUser] is provided → Edit mode. Otherwise → Add mode.
  const AddEditUserScreen({super.key, this.existingUser});
  final AppUser? existingUser;

  @override
  ConsumerState<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends ConsumerState<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.partner;
  bool _isActive = true;
  bool _saving = false;

  // site_users assignment
  final Set<String> _selectedSiteIds = {};

  bool get _isEdit => widget.existingUser != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final u = widget.existingUser!;
      _nameCtrl.text = u.name;
      _emailCtrl.text = u.email;
      _selectedRole = u.role;
      _isActive = u.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(
      // Use a simple StreamProvider inline via stream from site repo
      _allSitesProvider,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEdit ? 'Edit User' : 'Add User',
              style: AppTextStyles.headlineSmall,
            ),
            Text(
              'Shree Giriraj Engineering Management',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary, fontSize: 10),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ─── User Profile section ────────────────────────────────────
            const _SectionHeader(
              icon: Icons.person_outlined,
              label: 'User Profile',
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'e.g. Rajesh Kumar',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _emailCtrl,
              label: 'Email (Google Account)',
              hint: 'rajesh.kumar@gmail.com',
              keyboardType: TextInputType.emailAddress,
              readOnly: _isEdit,
              helperText: 'Used for SSO authentication',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),

            const SizedBox(height: 32),

            // ─── Access & Permissions section ────────────────────────────
            const _SectionHeader(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Access & Permissions',
            ),
            const SizedBox(height: 16),

            // Role dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Role', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  initialValue: _selectedRole,
                  decoration: _inputDecoration(hint: ''),
                  items: const [
                    DropdownMenuItem(
                      value: UserRole.partner,
                      child: Text('Partner'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.admin,
                      child: Text('Admin'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.superAdmin,
                      child: Text('Super Admin'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedRole = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sites checkboxes
            sitesAsync.when(
              loading: () => const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (sites) => _SiteCheckboxList(
                sites: sites,
                selectedIds: _selectedSiteIds,
                onChanged: (id, checked) => setState(() {
                  if (checked) {
                    _selectedSiteIds.add(id);
                  } else {
                    _selectedSiteIds.remove(id);
                  }
                }),
              ),
            ),

            const SizedBox(height: 32),

            // ─── Status toggle ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User Status',
                            style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          'Enable or disable user access to the platform',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Switch.adaptive(
                        value: _isActive,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isActive ? 'Active' : 'Inactive',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_outlined,
                          color: Colors.white, size: 20),
                  label: Text(
                    'Save User',
                    style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          validator: validator,
          decoration: _inputDecoration(hint: hint, helperText: helperText),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
          {required String hint, String? helperText}) =>
      InputDecoration(
        hintText: hint,
        helperText: helperText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final db = ref.read(firestoreProvider);
      final now = Timestamp.now();

      if (_isEdit) {
        // Update existing doc
        await db.collection('users').doc(widget.existingUser!.id).update({
          'name': _nameCtrl.text.trim(),
          'role': _selectedRole.name,
          'isActive': _isActive,
          'updatedAt': now,
        });
      } else {
        // Create new user doc
        await db.collection('users').add({
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim().toLowerCase(),
          'phone': null,
          'role': _selectedRole.name,
          'isActive': _isActive,
          'createdAt': now,
          'updatedAt': now,
          'lastLatitude': null,
          'lastLongitude': null,
          'lastLocationAt': null,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  _isEdit ? 'User updated successfully' : 'User created successfully')),
        );
        Navigator.pop(context);
      }
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
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _SiteCheckboxList extends StatelessWidget {
  const _SiteCheckboxList({
    required this.sites,
    required this.selectedIds,
    required this.onChanged,
  });
  final List<SiteModel> sites;
  final Set<String> selectedIds;
  final void Function(String id, bool checked) onChanged;

  @override
  Widget build(BuildContext context) {
    if (sites.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No sites available',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assigned Sites', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: sites.map((site) {
              final selected = selectedIds.contains(site.id);
              return CheckboxListTile(
                value: selected,
                onChanged: (v) => onChanged(site.id, v ?? false),
                title: Text(site.name, style: AppTextStyles.bodySmall),
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.leading,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Local provider for all sites (reuses site repository)
final _allSitesProvider = StreamProvider<List<SiteModel>>((ref) {
  return ref.read(siteRepositoryProvider).getAllSites();
});
