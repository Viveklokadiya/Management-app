import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/location_banner.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell>
    with LocationCaptureMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authStateProvider).value?.id;
      if (userId != null) captureLocation(userId);
    });
  }

  @override
  Widget build(BuildContext context) {

    final tabs = [
      AppRoutes.adminHome,
      AppRoutes.adminPartners,
      AppRoutes.adminSites,
      AppRoutes.adminTransactions,
      AppRoutes.adminProfile,
    ];

    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = tabs
        .indexWhere((t) => location.startsWith(t))
        .clamp(0, tabs.length - 1);

    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: Column(
        children: [
          const LocationPermissionBanner(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(tabs[i]),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.partners,
          ),
          NavigationDestination(
            icon: const Icon(Icons.location_city_outlined),
            selectedIcon: const Icon(Icons.location_city),
            label: l10n.sites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.transactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
