import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/location_banner.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PartnerShell extends ConsumerStatefulWidget {
  final Widget child;
  const PartnerShell({super.key, required this.child});

  @override
  ConsumerState<PartnerShell> createState() => _PartnerShellState();
}

class _PartnerShellState extends ConsumerState<PartnerShell>
    with LocationCaptureMixin {
  @override
  void initState() {
    super.initState();
    // Capture location on app open (after auth confirmed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authStateProvider).value?.id;
      if (userId != null) captureLocation(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final tabs = [
      AppRoutes.partnerHome,
      AppRoutes.partnerTransactions,
      AppRoutes.partnerProfile,
    ];
    final selectedIndex =
        tabs.indexWhere((t) => location.startsWith(t)).clamp(0, tabs.length - 1);

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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
