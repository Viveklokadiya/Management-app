import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/unauthorized_screen.dart';
import '../../features/partner/presentation/shell/partner_shell.dart';
import '../../features/partner/presentation/screens/partner_home_screen.dart';
import '../../features/partner/presentation/screens/partner_transactions_screen.dart';
import '../../features/partner/presentation/screens/partner_profile_screen.dart';
import '../../features/partner/presentation/screens/add_transaction_screen.dart';
import '../../features/partner/presentation/screens/transaction_detail_screen.dart';
import '../../features/admin/presentation/shell/admin_shell.dart';
import '../../features/transactions/domain/models/transaction_model.dart';
import 'route_guard.dart';
import 'routes.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final notifier = _AuthChangeNotifier(ref);

  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    redirect: (context, state) => routeGuard(ref, state),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.unauthorized,
        builder: (context, state) => const UnauthorizedScreen(),
      ),

      // ─── Add Transaction (outside shell — full-screen) ─────────────
      GoRoute(
        path: AppRoutes.addTransaction,
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          final type = extra?['type'] as TransactionType?;
          return AddTransactionScreen(initialType: type);
        },
      ),

      // ─── Transaction Detail (outside shell — full-screen) ──────────
      GoRoute(
        path: '/partner/transaction/:id',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          return TransactionDetailScreen(
            transactionId: s.pathParameters['id']!,
            siteId: extra?['siteId'] as String? ?? '',
          );
        },
      ),

      // ─── Partner shell ─────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => PartnerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.partnerHome,
            builder: (c, s) => const PartnerHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.partnerTransactions,
            builder: (c, s) => const PartnerTransactionsScreen(),
          ),
          GoRoute(
            path: AppRoutes.partnerProfile,
            builder: (c, s) => const PartnerProfileScreen(),
          ),
        ],
      ),

      // ─── Admin shell ───────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.adminHome,
            builder: (c, s) => const AdminHomePlaceholder(),
          ),
          GoRoute(
            path: AppRoutes.adminPartners,
            builder: (c, s) => const AdminPartnersPlaceholder(),
          ),
          GoRoute(
            path: AppRoutes.adminSites,
            builder: (c, s) => const AdminSitesPlaceholder(),
          ),
          GoRoute(
            path: AppRoutes.adminTransactions,
            builder: (c, s) => const AdminTransactionsPlaceholder(),
          ),
          GoRoute(
            path: AppRoutes.adminProfile,
            builder: (c, s) => const AdminProfilePlaceholder(),
          ),
          GoRoute(
            path: AppRoutes.superAdminUsers,
            builder: (c, s) => const SuperAdminUsersPlaceholder(),
          ),
        ],
      ),
    ],
  );
}

// Notifier that tells GoRouter to re-evaluate redirect when auth changes
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    _sub = ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

// ─── Admin Placeholder screens (replaced in Phases 6–7) ─────────────────────

class AdminHomePlaceholder extends StatelessWidget {
  const AdminHomePlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Admin Home\n(Phase 6)', textAlign: TextAlign.center)),
      );
}

class AdminPartnersPlaceholder extends StatelessWidget {
  const AdminPartnersPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Admin Partners\n(Phase 6)', textAlign: TextAlign.center)),
      );
}

class AdminSitesPlaceholder extends StatelessWidget {
  const AdminSitesPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Admin Sites\n(Phase 6)', textAlign: TextAlign.center)),
      );
}

class AdminTransactionsPlaceholder extends StatelessWidget {
  const AdminTransactionsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Admin Transactions\n(Phase 6)', textAlign: TextAlign.center)),
      );
}

class AdminProfilePlaceholder extends StatelessWidget {
  const AdminProfilePlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Admin Profile\n(Phase 6)', textAlign: TextAlign.center)),
      );
}

class SuperAdminUsersPlaceholder extends StatelessWidget {
  const SuperAdminUsersPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Users Management\n(Phase 7)', textAlign: TextAlign.center)),
      );
}
