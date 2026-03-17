import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PartnerProfileScreen extends ConsumerStatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  ConsumerState<PartnerProfileScreen> createState() =>
      _PartnerProfileScreenState();
}

class _PartnerProfileScreenState
    extends ConsumerState<PartnerProfileScreen> {
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Dark Navy Header ────────────────────────────────────
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
                  // Avatar
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.amountLarge
                          .copyWith(color: Colors.white),
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
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      'PARTNER',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Info Card ───────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
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
                        label: 'Email',
                        value: user.email,
                      ),
                      const Divider(
                          height: 1,
                          indent: 64,
                          color: AppColors.border),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        value: user.phone?.isNotEmpty == true
                            ? user.phone!
                            : 'Not provided',
                      ),
                      const Divider(
                          height: 1,
                          indent: 64,
                          color: AppColors.border),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Last Location Updated',
                        value: user.lastLocationAt != null
                            ? DateFormat('d MMM y, h:mm a')
                                .format(user.lastLocationAt!)
                            : 'Not yet captured',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Logout ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
                  onPressed: _signingOut ? null : _signOut,
                  icon: _signingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    'Logout',
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

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content:
            const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

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
            child: Icon(icon,
                size: 22, color: AppColors.accent),
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
        ],
      ),
    );
  }
}
